port module RecipeEditor exposing (main)

import Html exposing (Html, h1, label, button, textarea, form, div, input, text, a, img, i, option, select)
import Html.Attributes exposing (type_, class, style, href, src, placeholder, value)
import Http
import Task exposing (Task)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Recipes.Types exposing (..)


type alias Model =
    { recipe : Maybe RecipeFullResponse
    , flags : RecipeFlags
    }


type alias RecipeFlags =
    { recipeId : Int
    , token : String
    , userId : String
    }


type Msg
    = None
    | RequestRecipe
    | ReceiveRecipeFull RecipeFullResponse


main : Program RecipeFlags Model Msg
main =
    Html.programWithFlags
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestRecipe ->
            ( model, sendRecipeQuery model.flags.token model.flags.recipeId )

        ReceiveRecipeFull res ->
            ( { model | recipe = Just res }, Cmd.none )

        None ->
            ( model, Cmd.none )


init : RecipeFlags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = Nothing, flags = flags }
    , sendRecipeQuery flags.token flags.recipeId
    )


type alias AuthToken =
    String


type alias RecipeId =
    Int


sendRecipeQuery : AuthToken -> RecipeId -> Cmd Msg
sendRecipeQuery authToken recipeId =
    sendQueryRequest authToken (recipeQueryRequest recipeId)
        |> Task.attempt ReceiveRecipeFull


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request


requestOptions token =
    { method = "POST"
    , headers = [ (Http.header "Authorization" ("Bearer " ++ token)) ]
    , url = "http://localhost:4000/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }


recipeQueryRequest : RecipeId -> GqlB.Request GqlB.Query RecipeFull
recipeQueryRequest recipeId =
    recipeRequest
        |> GqlB.request { recipeId = recipeId }


builtUnit =
    GqlB.object IngredientUnit
        |> GqlB.with (GqlB.field "abbr" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)


builtTag =
    GqlB.object RecipeTag
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)


builtIngredient =
    GqlB.object Ingredient
        |> GqlB.with (GqlB.field "quantity" [] GqlB.float)
        |> GqlB.with (GqlB.field "displayQuantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "unit" [] builtUnit)


recFull =
    GqlB.object RecipeFull
        |> GqlB.with (GqlB.field "author" [] GqlB.string)
        |> GqlB.with (GqlB.field "authorId" [] GqlB.string)
        |> GqlB.with (GqlB.field "description" [] GqlB.string)
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredients" [] (GqlB.list builtIngredient))
        |> GqlB.with (GqlB.field "instructions" [] GqlB.string)
        |> GqlB.with (GqlB.field "likes" [] (GqlB.list GqlB.int))
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "tags" [] (GqlB.list builtTag))
        |> GqlB.with (GqlB.field "youLike" [] GqlB.bool)


recipeRequest : GqlB.Document GqlB.Query RecipeFull { vars | recipeId : Int }
recipeRequest =
    let
        recipeIdVar =
            Var.required "recipeId" .recipeId Var.int

        queryRoot =
            GqlB.extract
                (GqlB.field "recipe"
                    [ ( "recipeId", Arg.variable recipeIdVar ) ]
                    recFull
                )
    in
        GqlB.queryDocument queryRoot


view : Model -> Html Msg
view model =
    case model.recipe of
        Nothing ->
            div [ class "editor" ] [ text "loading..." ]

        Just res ->
            case res of
                Ok r ->
                    div [ class "editor" ]
                        [ form [ class "recipe-form" ]
                            [ h1 [] [ text "Recipe Editor" ] ]
                        , div [ class "form-field" ]
                            [ label [] [ text "Recipe Name" ]
                            , input [ placeholder "Recipe Name", value r.name ] []
                            ]
                        , div [ class "form-field" ]
                            [ label [] [ text "Description" ]
                            , input [ placeholder "description" ] []
                            ]
                        , div [ class "form-field" ]
                            [ label [] [ text "Instructions" ]
                            , textarea [] []
                            ]
                        , div [ class "form-field" ]
                            [ label [] [ text "Ingredients" ]
                            , div [ class "recipe-field-group" ]
                                [ div [ class "recipe-field" ]
                                    [ input [ type_ "number" ] [] ]
                                , div [ class "recipe-field" ]
                                    [ select [] [ option [ value "cups" ] [ text "Cups" ] ] ]
                                , div [ class "recipe-field" ]
                                    [ input [] [] ]
                                , div [ class " recipe-field" ]
                                    [ button [] [ text "X" ] ]
                                ]
                            ]
                        ]

                Err r ->
                    div [ class "error" ] [ text "ERROR DUDE " ]
