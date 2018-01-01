port module RecipeDetail exposing (main)

--  ELM-LANG MODULES
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (Html, div, text, button, h1, ul, li, img, i, span)
import Html.Attributes exposing (src, style, class)
import Http
import Task exposing (Task)
import Recipes.Types exposing(..)

type alias Model =
  { mRecipe: Maybe RecipeFullResponse
  , flags: Flags
  }

main : Program Flags Model Msg
main =
  Html.programWithFlags
  { update        = update
  , view          = viewDetail
  , init          = init
  , subscriptions = subscriptions
  }

init : Flags -> (Model, Cmd Msg)
init initFlags = 
  ({ mRecipe = Nothing
  ,  flags   = initFlags
  }, sendRecipeQuery initFlags.token initFlags.recipeId)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of

    NoOp ->
      (model, Cmd.none)

    RequestRecipeFull ->
      (model, sendRecipeQuery model.flags.token model.flags.recipeId)

    (ReceiveRecipeFull res) ->
      ({ model | mRecipe = Just res }, Cmd.none)


type Msg
  = NoOp
  | RequestRecipeFull
  | ReceiveRecipeFull RecipeFullResponse


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


type alias AuthToken = String
type alias RecipeId = Int

sendRecipeQuery : AuthToken -> RecipeId -> Cmd Msg
sendRecipeQuery authToken recipeId =
    sendQueryRequest authToken (recipeQueryRequest recipeId )
        |> Task.attempt ReceiveRecipeFull

sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request

requestOptions token =
  { method          = "POST"
  , headers         = [(Http.header "Authorization" ("Bearer " ++ token))]
  , url             = "http://localhost:4000/graphql/"
  , timeout         = Nothing
  , withCredentials = False -- value of True makes CORS active, breaking the request
  }

recipeQueryRequest : RecipeId -> GqlB.Request GqlB.Query RecipeFull
recipeQueryRequest recipeId =
  recipeRequest
    |> GqlB.request { recipeId = recipeId }

recipeRequest : GqlB.Document GqlB.Query RecipeFull { vars | recipeId: Int }
recipeRequest =
  let
    recipeIdVar =
      Var.required "recipeId" .recipeId Var.int

    builtUnit = 
      GqlB.object IngredientUnit
        |> GqlB.with (GqlB.field "abbr" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)

    builtTag = 
      GqlB.object RecipeTag
        |> GqlB.with (GqlB.field "id"   [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)

    builtIngredient = 
      GqlB.object Ingredient
        |> GqlB.with (GqlB.field "quantity"        [] GqlB.float)
        |> GqlB.with (GqlB.field "displayQuantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "name"            [] GqlB.string)
        |> GqlB.with (GqlB.field "unit"            [] builtUnit)

    recFull =
      GqlB.object RecipeFull
        |> GqlB.with (GqlB.field "author"       [] GqlB.string)
        |> GqlB.with (GqlB.field "authorId"     [] GqlB.string)
        |> GqlB.with (GqlB.field "description"  [] GqlB.string)
        |> GqlB.with (GqlB.field "id"           [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl"     [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredients"  [] (GqlB.list builtIngredient))
        |> GqlB.with (GqlB.field "instructions" [] GqlB.string)
        |> GqlB.with (GqlB.field "likes"        [] GqlB.int)
        |> GqlB.with (GqlB.field "name"         [] GqlB.string)
        |> GqlB.with (GqlB.field "tags"         [] (GqlB.list builtTag))
        |> GqlB.with (GqlB.field "youLike"      [] GqlB.bool)

    queryRoot =
      GqlB.extract
        (GqlB.field "recipe"
          [ ("recipeId", Arg.variable recipeIdVar ) ]
          recFull
        )
  in
      GqlB.queryDocument queryRoot

viewDetail : Model -> Html Msg
viewDetail model =
  case model.mRecipe of
    (Just res) ->
      case res of
        (Ok r) ->
          div []
          [ viewDetailSuccess r
          , div [] [text <| toString res]
          ]

        (Err r) -> text ("asf, you has err: " ++ (toString r))
    (Nothing) ->
      text "loading..."

viewDetailSuccess : RecipeFull -> Html Msg
viewDetailSuccess r =
  div
  [style [
    ("height", "calc(100vh - 50px)"),
    ("overflow", "auto"),
    ("padding", "20px")
  ]]
  [ div [style [
    ("margin", "auto"),
    ("max-width", "1000px"),
    ("margin-top", "10px")
    ]]
    [ div [style [("margin-top", "25px")]]
      [ div
        [ class "slideInLeft"
        , style [ ("padding-bottom", "3px") ] 
        ]
        [ div [class "ui fluid card"]
          [ img [class "ui image", src "/zorak-picture.jpg"] []
          , div [class "content"]
            [ div [class "header"][text r.name]
            , div [class "meta"][text r.author]
            , div [class "meta"]
              [ div [style [("display", "flex"), ("margin-top", "5px") ]]
                []
              ]
            , div [class "description"]
              [ div [style [("margin-top", "15px"), ("white-space", "pre-wrap")]][]
              , ul [] (List.map (\i -> viewIngredient <| formatIngredient i ) r.ingredients )
              ]
            ]
            , div
              [ class "description"
              , style
                [ ("display", "flex")
                , ("justify-content", "space-between")
                , ("align-items", "center")
                ]
              ]
            [
              span []
              [ i [class <| "favorite big icon " ++ (if r.youLike then "teal" else "grey" )][]
              , span [] [text ("Likes: " ++ toString r.likes)]
              ]
            ]
          ]
        ]
      ]
    ]
  ]

formatIngredient : Ingredient -> String
formatIngredient i =
  i.displayQuantity ++ " " ++ i.unit.name ++ " " ++ i.name

viewIngredient : String -> Html Msg
viewIngredient ingredientText =
  li [style [
       ("margin-top", "5px"),
       ("white-space", "pre-wrap")
     ]]
     [
       text ingredientText
     ]

-- See the recipe
-- See the likes of the recipe
-- See if you like the recipe.
-- Click on the like recipe star
-- Click to delete the recipe
