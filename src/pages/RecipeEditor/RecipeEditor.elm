module RecipeEditor exposing (main)

import Html exposing (Html, h1, label, button, textarea, form, div, input, text, a, img, i, option, select, span)
import Html.Attributes exposing (type_, class, style, href, src, placeholder, value, for, id, rows, tabindex)
import Html.Attributes.Aria exposing (role)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Recipes.Types
import RecipeQueries
    exposing
        ( RecipeQueryMsg(..)
        , sendUnitsQuery
        , sendRecipeQuery
        )


type DropdownKey
    = UnitsDropdown Int
    | IngredientDropdown Int


type TextField
    = RecipeName
    | RecipeDescription
    | RecipeInstructions


type alias UI a =
    { a | uiOpenDropdown : Maybe DropdownKey }


type alias Model =
    { recipe : Maybe Recipes.Types.RecipeFull
    , editingRecipe : Maybe Recipes.Types.RecipeFull
    , flags : RecipeFlags
    , units : Maybe (List Recipes.Types.Unit)

    -- UI
    , uiOpenDropdown : Maybe DropdownKey
    }


type alias RecipeFlags =
    { recipeId : Int
    , token : String
    , userId : String
    }


type Msg
    = None
    | Query RecipeQueryMsg
      -- UI Events
    | BodyClick
    | ToggleIngredientDropdown (Maybe DropdownKey)
    | UpdateTextField TextField String


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


queryForRecipe :
    { a | recipeId : Int, token : String }
    -> Cmd RecipeQueryMsg
queryForRecipe flags =
    sendRecipeQuery flags.token flags.recipeId ReceiveRecipeFull


queryForTags : { a | token : String } -> Cmd RecipeQueryMsg
queryForTags flags =
    sendUnitsQuery flags.token ReceiveUnits


convertToLocalCmd : Cmd RecipeQueryMsg -> Cmd Msg
convertToLocalCmd recipeQueryCmd =
    Cmd.map (\queryCmd -> Query queryCmd) recipeQueryCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Query subMsg ->
            case subMsg of
                RequestRecipe ->
                    ( model, convertToLocalCmd (queryForRecipe model.flags) )

                ReceiveRecipeFull res ->
                    ( { model | recipe = Result.toMaybe res, editingRecipe = Result.toMaybe res }, Cmd.none )

                ReceiveUnits res ->
                    ( { model | units = Result.toMaybe res }, Cmd.none )

        ToggleIngredientDropdown dropdown ->
            let
                key =
                    if dropdown == model.uiOpenDropdown then
                        Nothing
                    else
                        dropdown
            in
                ( { model | uiOpenDropdown = key }, Cmd.none )

        BodyClick ->
            ( { model | uiOpenDropdown = Nothing }, Cmd.none )

        None ->
            ( model, Cmd.none )

        UpdateTextField textfield value ->
            case model.editingRecipe of
                Just editingRecipe ->
                    case textfield of
                        RecipeName ->
                            let 
                                updatedEditingRecipeModel = ({ editingRecipe | name = value })
                                newEditingRecipe = Just updatedEditingRecipeModel
                            in
                                ( {model | editingRecipe = newEditingRecipe}, Cmd.none)

                        RecipeDescription ->
                            let 
                                updatedEditingRecipeModel = ({ editingRecipe | description = value })
                                newEditingRecipe = Just updatedEditingRecipeModel
                            in
                                ( {model | editingRecipe = newEditingRecipe}, Cmd.none)

                        RecipeInstructions ->
                            let
                                updatedEditingRecipeModel = ({ editingRecipe | instructions = value })
                                newEditingRecipe = Just updatedEditingRecipeModel
                            in
                                ( {model | editingRecipe = newEditingRecipe}, Cmd.none)

                Nothing ->
                    ( model, Cmd.none)

           



init : RecipeFlags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = Nothing, editingRecipe = Nothing, units = Nothing, flags = flags, uiOpenDropdown = Nothing }
    , Cmd.batch
        [ convertToLocalCmd (queryForRecipe flags)
        , convertToLocalCmd (queryForTags flags)
        ]
    )


view : Model -> Html Msg
view model =
    case model.editingRecipe of
        Nothing ->
            div [ class "editor" ] [ text "loading..." ]

        Just recipe ->
            recipeFormView model recipe


recipeFormView :
    Model
    -> Recipes.Types.RecipeFull
    -> Html Msg
recipeFormView model r =
    div
        [ style [ ( "-webkit-animation", "slideInLeft 0.25s linear" ), ( "animation", "slideInLeft 0.25s linear" ), ( "min-width", "260px" ) ]
        , onClick BodyClick
        ]
        [ form [ class "ui form recipe-editor-form" ]
            [ h1 [] [ text "Recipe Editor" ]
            , textInput r.name RecipeName False
            , textInput r.description RecipeDescription True
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
            , textInput r.instructions RecipeInstructions True
            , button [ class "ui button", role "button" ] [ text "Save" ]
            ]
        ]


textFieldToLabel : TextField -> String
textFieldToLabel field =
    case field of
        RecipeName ->
            "Recipe Name"

        RecipeDescription ->
            "Description"

        RecipeInstructions ->
            "Instructions"


textFieldToInputId : TextField -> String
textFieldToInputId field =
    case field of
        RecipeName ->
            "recipe-name"

        RecipeDescription ->
            "recipe-description"

        RecipeInstructions ->
            "recipe-instructions"


textInput : String -> TextField -> Bool -> Html Msg
textInput modelData textField isTextarea =
    let
        inputId =
            textFieldToInputId textField

        inputLabel =
            textFieldToLabel textField

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
            [ label [ for inputId ] [ text inputLabel ]
            , div [ class "ui input" ]
                [ inputType ([ id inputId, value modelData, onInput (UpdateTextField textField) ] ++ moreAttrs) [] ]
            ]


viewIngredientList : Model -> Recipes.Types.RecipeFull -> Html Msg
viewIngredientList model r =
    let
        ingredientsLabel =
            (label [] [ text "Ingredients" ])
                :: (List.indexedMap
                        (ingredientRow model.units model)
                        r.ingredients
                   )
    in
        div []
            ingredientsLabel


ingredientRow : Maybe (List Recipes.Types.Unit) -> UI a -> Int -> Recipes.Types.Ingredient -> Html Msg
ingredientRow units ui ingredientIndex ingredient =
    div [ class "fields recipe-editor-group" ]
        [ div [ class "two wide field" ]
            [ div [ class "ui input" ] [ input [ type_ "text", value (toString ingredient.quantity), placeholder "#" ] [] ] ]
        , div [ class "four wide field" ]
            [ unitsDropdown units ingredientIndex ingredient.unit ui.uiOpenDropdown ]
        , div [ class "six wide field" ]
            [ div
                [ class "typeahead" ]
                [ input [ type_ "text", placeholder "", class "", value ingredient.name ] [] ]
            ]
        ]


unitsDropdown : Maybe (List Recipes.Types.Unit) -> Int -> Recipes.Types.IngredientUnit -> Maybe DropdownKey -> Html Msg
unitsDropdown units ingredientIndex ingredientUnit openDropdown =
    let
        isVisible =
            case openDropdown of
                Just (UnitsDropdown dd) ->
                    if dd == ingredientIndex then
                        True
                    else
                        False

                _ ->
                    False

        active =
            if isVisible then
                "active"
            else
                ""

        visible =
            if isVisible then
                "visible"
            else
                ""
    in
        div
            [ class ("ui " ++ active ++ " selection dropdown")
            , tabindex 0
            , onWithOptions "click" { defaultOptions | stopPropagation = True } (Decode.succeed (ToggleIngredientDropdown (Just (UnitsDropdown ingredientIndex))))
            ]
            -- needs attr of role "listbox"
            [ div [ class "text" ] [ text ingredientUnit.name ] -- needs role of alert. This div represent the head of the list/the active element
            , i [ class "dropdown icon" ] []
            , div
                [ class
                    ("menu " ++ visible ++ " transition ")
                ]
                (case units of
                    Nothing ->
                        [ div [] [ text "no display units..." ] ]

                    Just res ->
                        List.map measuringUnit res
                )
            ]


measuringUnit : Recipes.Types.Unit -> Html Msg
measuringUnit unit =
    div
        [ class "item", style [ ( "pointer-events", "all" ) ] ]
        --, onClick (SelectUnit unit.id) ]
        [ span [ class "text" ] [ text unit.abbr ] ]
