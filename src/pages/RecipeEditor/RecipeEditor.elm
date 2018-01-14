port module RecipeEditor exposing (main)

import Html exposing (Html, h1, label, button, textarea, form, div, input, text, a, img, i, option, select, span)
import Html.Attributes exposing (type_, class, style, href, src, placeholder, value, for, id, rows, tabindex)
import Html.Attributes.Aria exposing (role)
import Http
import Task exposing (Task)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Recipes.Types exposing (..)


type alias Model =
    { recipe : Maybe RecipeFull
    , flags : RecipeFlags
    , units : Maybe (List Unit)
    }


type alias RecipeFlags =
    { recipeId : Int
    , token : String
    , userId : String
    }


type alias Unit =
    { id : String
    , name : String
    , abbr : String
    }


type alias UnitsResponse =
    Result GraphQLClient.Error (List Unit)


type Msg
    = None
    | RequestRecipe
    | ReceiveRecipeFull RecipeFullResponse
    | ReceiveUnits UnitsResponse


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
            ( { model | recipe = Result.toMaybe res }, Cmd.none )

        ReceiveUnits res ->
            ( { model | units = Result.toMaybe res }, Cmd.none )

        None ->
            ( model, Cmd.none )


init : RecipeFlags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = Nothing, units = Nothing, flags = flags }
    , Cmd.batch [ sendRecipeQuery flags.token flags.recipeId, sendUnitsQuery flags.token ]
    )


type alias AuthToken =
    String


type alias RecipeId =
    Int


sendUnitsQuery : AuthToken -> Cmd Msg
sendUnitsQuery authToken =
    Task.attempt
        ReceiveUnits
        (GraphQLClient.customSendQuery
            (requestOptions authToken)
            (GqlB.request {} unitsRequest)
        )


builtUnitList =
    GqlB.list
        (GqlB.object Unit
            |> GqlB.with (GqlB.field "id" [] GqlB.string)
            |> GqlB.with (GqlB.field "name" [] GqlB.string)
            |> GqlB.with (GqlB.field "abbr" [] GqlB.string)
        )


unitsRequest : GqlB.Document GqlB.Query (List Unit) {}
unitsRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "units"
                []
                builtUnitList
            )
        )


sendRecipeQuery : AuthToken -> RecipeId -> Cmd Msg
sendRecipeQuery authToken recipeId =
    Task.attempt
        ReceiveRecipeFull
        (GraphQLClient.customSendQuery
            (requestOptions authToken)
            (GqlB.request { recipeId = recipeId } recipeRequest)
        )


recipeRequest : GqlB.Document GqlB.Query RecipeFull { vars | recipeId : Int }
recipeRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "recipe"
                [ ( "recipeId"
                  , Arg.variable (Var.required "recipeId" .recipeId Var.int)
                  )
                ]
                recFull
            )
        )


requestOptions token =
    { method = "POST"
    , headers = [ (Http.header "Authorization" ("Bearer " ++ token)) ]
    , url = "http://localhost:4000/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }


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


view : Model -> Html Msg
view model =
    case model.recipe of
        Nothing ->
            div [ class "editor" ] [ text "loading..." ]

        Just recipe ->
            recipeFormView model recipe


recipeFormView :
    Model
    -> RecipeFull
    -> Html Msg -- need model for list of units
recipeFormView model r =
    div [ style [ ( "-webkit-animation", "slideInLeft 0.25s linear" ), ( "animation", "slideInLeft 0.25s linear" ), ( "min-width", "260px" ) ] ]
        [ form [ class "ui form recipe-editor-form" ]
            [ h1 [] [ text "Recipe Editor" ]
            , viewInput r.name "Recipe Name" "recipe-name" False
            , viewInput r.description "Description" "recipe-description" True
            , viewIngredientList model r
            , div
                [ class "field" ]
                [ button [ class "ui negative button", role "button" ] [ text "X" ] ]
            , div
                [ class "field" ]
                [ button [ class "ui primary button", role "button" ] [ text "Add Ingredient" ] ]
            , div [ class "field" ]
                [ label [ class "field" ] [ text "Tags" ]
                , div [ class "ui multiple selection dropdown", tabindex 0, role "listbox" ]
                    [ a [ class "ui label", value "0" ] [ text "Spicy", i [ class "delete icon" ] [] ] ]
                , div [ class "text", role "alert" ] []
                , i [ class "dropdown icon" ] []
                , div [ class "menu transition" ] []
                ]
            , viewInput r.instructions "Instructions" "recipe-instructions" True
            , button [ class "ui button", role "button" ] [ text "Save" ]
            ]
        ]


type alias ModelData =
    String


type alias FieldLabel =
    String


type alias FieldId =
    String


type alias IsTextarea =
    Bool


viewInput : ModelData -> FieldLabel -> FieldId -> IsTextarea -> Html Msg
viewInput modelData fieldLabel fieldId isTextarea =
    let
        inputType =
            if isTextarea then
                textarea
            else
                input

        moreAttrs =
            if isTextarea then
                [ rows 3 ]
            else
                [ type_ "text" ]
    in
        div [ class "field" ]
            [ label [ for fieldId ] [ text fieldLabel ]
            , div [ class "ui input" ]
                [ inputType ([ id fieldId, value modelData ] ++ moreAttrs) [] ]
            ]


viewIngredientList : Model -> RecipeFull -> Html Msg
viewIngredientList model r =
    div []
        [ label [] [ text "Ingredients" ]
        , div [ class "fields recipe-editor-group" ]
            [ div [ class "two wide field" ]
                [ div [ class "ui input" ] [ input [ type_ "text", value "1", placeholder "#" ] [] ] ]
            , div [ class "four wide field" ]
                [ div [ class "ui active visible selection dropdown", tabindex 0 ]
                    -- needs attr of role "listbox"
                    [ div [ class "text" ] [ text "cm." ] -- needs role of alert. This div represent the head of the list/the active element
                    , i [ class "dropdown icon" ] []
                    , div [ class "menu transition visible" ]
                        (case model.units of
                            Nothing ->
                                [ div [] [ text "no display units..." ] ]

                            Just res ->
                                List.map measuringUnit res
                        )
                    ]
                ]
            , div [ class "six wide field" ]
                [ div
                    [ class "typeahead" ]
                    [ input [ type_ "text", placeholder "", class "", value "Can of Soup" ] [] ]
                ]
            ]
        ]



-- need the typeahead list display thing.
-- TODO: find how to add role attribute to wrapping div


measuringUnit : Unit -> Html Msg
measuringUnit unit =
    div
        [ class "item", style [ ( "pointer-events", "all" ) ] ]
        [ span [ class "text" ] [ text unit.abbr ] ]



-- measuringUnit need eventing for on click
