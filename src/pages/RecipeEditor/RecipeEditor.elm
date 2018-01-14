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
import Recipes.Types
import RecipeQueries exposing (sendUnitsQuery, sendRecipeQuery, RecipeFullResponse, UnitsResponse)


type alias Model =
    { recipe : Maybe Recipes.Types.RecipeFull
    , flags : RecipeFlags
    , units : Maybe (List Recipes.Types.Unit)
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


queryForRecipe flags =
    sendRecipeQuery flags.token flags.recipeId ReceiveRecipeFull


queryForTags flags =
    sendUnitsQuery flags.token ReceiveUnits


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestRecipe ->
            ( model, queryForRecipe model.flags )

        ReceiveRecipeFull res ->
            ( { model | recipe = Result.toMaybe res }, Cmd.none )

        ReceiveUnits res ->
            ( { model | units = Result.toMaybe res }, Cmd.none )

        None ->
            ( model, Cmd.none )


init : RecipeFlags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = Nothing, units = Nothing, flags = flags }
    , Cmd.batch
        [ queryForRecipe flags
        , queryForTags flags
        ]
    )


view : Model -> Html Msg
view model =
    case model.recipe of
        Nothing ->
            div [ class "editor" ] [ text "loading..." ]

        Just recipe ->
            recipeFormView model recipe


recipeFormView :
    Model
    -> Recipes.Types.RecipeFull
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


viewIngredientList : Model -> Recipes.Types.RecipeFull -> Html Msg
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


measuringUnit : Recipes.Types.Unit -> Html Msg
measuringUnit unit =
    div
        [ class "item", style [ ( "pointer-events", "all" ) ] ]
        [ span [ class "text" ] [ text unit.abbr ] ]



-- measuringUnit need eventing for on click
