module Page.RecipeEditor exposing (update, view, initNew, initEdit, Model, Msg(..))

-- ELM-LANG MODULES --

import Debug
import Array exposing (Array, fromList, toList)
import Html exposing (Html, a, button, div, form, h1, i, input, label, span, text, textarea)
import Html.Attributes exposing (attribute, class, classList, for, href, id, name, placeholder, rows, src, style, tabindex, type_, value)
import Html.Attributes.Aria exposing (role)
import Html.Events exposing (defaultOptions, onClick, onInput, onFocus, onWithOptions)
import Json.Decode as Decode
import Task exposing (Task)


-- THIRD PARTY MODULES --

import Autocomplete


-- APPLICATION MODULES --

import Data.User as User exposing (UserId, blankUserId)
import Data.AuthToken as AuthToken exposing (AuthToken, getTokenString, blankToken)
import Page.Errored as Errored exposing (PageLoadError(..), pageLoadError)
import Data.Recipe as Recipe
    exposing
        ( EditingIngredient
        , EditingRecipeFull
        , Ingredient
        , IngredientRaw
        , RecipeId
        , RecipeFull
        , RecipeQueryMsg(..)
        , Slug
        , Unit
          -- QUERIES --
        , createIngredientsQueryTask
        , createRecipeQueryTask
        , createUnitsQueryTask
        , sendIngredientsQuery
        , sendRecipeQuery
        , sendUnitsQuery
        , slugToString
        , submitRecipeMutation
        )
import Data.Session exposing (Session)
import Views.Page as Page


type DropdownKey
    = UnitsDropdown Int
    | IngredientDropdown Int


type TextField
    = RecipeName
    | RecipeDescription
    | RecipeInstructions


type IngredientField
    = IngredientQuanity
    | IngredientName
    | IngredientUnits


type alias UI a =
    { a | uiOpenDropdown : Maybe DropdownKey }


type alias Model =
    { recipe : Maybe RecipeFull
    , editingRecipe : EditingRecipeFull
    , ingredients : Maybe (List IngredientRaw)
    , units : Maybe (List Unit)
    , recipeId : Int
    , token : AuthToken
    , userId : UserId

    -- UI
    , uiOpenDropdown : Maybe DropdownKey
    , ingredientAutoComplete : Autocomplete.State
    , ingredientFilter : String
    , selectedIngredientIndex : Maybe Int
    }


type Msg
    = None
    | Query RecipeQueryMsg
      -- UI Events
    | AddIngredient
    | BodyClick
    | DeleteIngredient Int
    | SetAutocompleteState Autocomplete.Msg
    | SelectIngredient String
    | SelectIngredientUnit Int Unit
    | Submit
    | ToggleIngredientDropdown (Maybe DropdownKey)
    | UpdateTypeaheadFilter String
    | UpdateIngredient IngredientField Int String
    | UpdateTextField TextField String
    | ResetAutocomplete Bool
    | IngredientFocused Int


emptyRecipe : EditingRecipeFull
emptyRecipe =
    { description = ""
    , id = ""
    , imageUrl = ""
    , ingredients = Array.empty
    , instructions = ""
    , name = ""
    , tags = []
    }


queryForRecipe : AuthToken -> RecipeId -> Cmd RecipeQueryMsg
queryForRecipe token recipeId =
    sendRecipeQuery token recipeId ReceiveRecipeFull


queryForTags : AuthToken -> Cmd RecipeQueryMsg
queryForTags token =
    sendUnitsQuery token ReceiveUnits


queryForIngredients flags =
    sendIngredientsQuery flags.token ReceiveIngredients


submitRecipe : Model -> Cmd RecipeQueryMsg
submitRecipe model =
    submitRecipeMutation model.token model.editingRecipe ReceiveRecipeFull


convertToLocalCmd : Cmd RecipeQueryMsg -> Cmd Msg
convertToLocalCmd recipeQueryCmd =
    Cmd.map (\queryCmd -> Query queryCmd) recipeQueryCmd


autocompleteViewConfig : Autocomplete.ViewConfig IngredientRaw
autocompleteViewConfig =
    let
        customizedLi keySelected mouseSelected ingredient =
            { attributes =
                [ classList [ ( "autocomplete-item", True ), ( "key-selected", keySelected || mouseSelected ) ]
                , id ingredient.id
                ]
            , children = [ Html.text ingredient.name ]
            }
    in
        Autocomplete.viewConfig
            { toId = .id
            , ul = [ class "autocomplete-list" ]
            , li = customizedLi
            }


autocompleteUpdateConfig : Autocomplete.UpdateConfig Msg IngredientRaw
autocompleteUpdateConfig =
    Autocomplete.updateConfig
        { toId = .id
        , onKeyDown =
            \code ingredient ->
                if code == 13 then
                    Maybe.map SelectIngredient ingredient
                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \ingredient -> Just <| SelectIngredient ingredient
        , separateSelections = False
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Submit ->
            ( model, convertToLocalCmd (submitRecipe model) )

        Query subMsg ->
            case subMsg of
                RequestRecipe ->
                    ( model, convertToLocalCmd (queryForRecipe model.token model.recipeId) )

                ReceiveRecipeFull res ->
                    ( { model | recipe = Result.toMaybe res, editingRecipe = (recipeFullToEditingRecipe model (Result.toMaybe res)) }, Cmd.none )

                ReceiveUnits res ->
                    ( { model | units = Result.toMaybe res }, Cmd.none )

                ReceiveIngredients res ->
                    let
                        _ =
                            Debug.log "Incoming ingredients" res
                    in
                        ( { model | ingredients = Result.toMaybe res }, Cmd.none )

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

        IngredientFocused index ->
            ( { model | selectedIngredientIndex = Just index }, Cmd.none )

        UpdateTextField textfield value ->
            let
                editingRecipe =
                    model.editingRecipe
            in
                case textfield of
                    RecipeName ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | name = value })

                            newEditingRecipe =
                                updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    RecipeDescription ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | description = value })

                            newEditingRecipe =
                                updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    RecipeInstructions ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | instructions = value })

                            newEditingRecipe =
                                updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

        UpdateIngredient field ingredientIndex value ->
            let
                editingRecipe =
                    model.editingRecipe
            in
                case Array.get ingredientIndex editingRecipe.ingredients of
                    Just foundIngredient ->
                        let
                            newIngredient =
                                { foundIngredient | quantity = value }

                            newIngredients =
                                Array.set ingredientIndex newIngredient editingRecipe.ingredients

                            newEditingRecipe =
                                { editingRecipe | ingredients = newIngredients }
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        SelectIngredientUnit ingredientIndex unit ->
            let
                editingRecipe =
                    model.editingRecipe
            in
                case Array.get ingredientIndex editingRecipe.ingredients of
                    Just foundIngredient ->
                        let
                            newIngredient =
                                { foundIngredient | unitId = unit.id }

                            newIngredients =
                                Array.set ingredientIndex newIngredient editingRecipe.ingredients

                            newEditingRecipe =
                                { editingRecipe | ingredients = newIngredients }
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        SelectIngredient ingredientId ->
            let
                editingRecipe =
                    model.editingRecipe
            in
                case model.selectedIngredientIndex of
                    Just selectedIngredient ->
                        case Array.get selectedIngredient editingRecipe.ingredients of
                            Just foundIngredient ->
                                let
                                    newIngredient =
                                        { foundIngredient | ingredientId = ingredientId }

                                    newIngredients =
                                        Array.set selectedIngredient newIngredient editingRecipe.ingredients

                                    newEditingRecipe =
                                        { editingRecipe | ingredients = newIngredients }
                                in
                                    ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )

                    Nothing ->
                        ( model, Cmd.none )

        AddIngredient ->
            let
                editingRecipe =
                    model.editingRecipe

                newIngredientList =
                    Array.push
                        { quantity = ""
                        , ingredientId = ""
                        , unitId = ""
                        }
                        editingRecipe.ingredients

                newEditingRecipe =
                    { editingRecipe | ingredients = newIngredientList }
            in
                ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

        DeleteIngredient index ->
            let
                editingRecipe =
                    model.editingRecipe

                newIngredientList =
                    removeIndexFromArray index editingRecipe.ingredients

                newEditingRecipe =
                    { editingRecipe | ingredients = newIngredientList }
            in
                ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

        SetAutocompleteState autocompleteMsg ->
            let
                ( newState, maybeMsg ) =
                    Autocomplete.update
                        autocompleteUpdateConfig
                        autocompleteMsg
                        10
                        model.ingredientAutoComplete
                        (filteredIngredients model)

                newModel =
                    { model | ingredientAutoComplete = newState }
            in
                case maybeMsg of
                    Nothing ->
                        newModel ! []

                    Just updateMsg ->
                        update updateMsg newModel

        UpdateTypeaheadFilter filter ->
            ( { model | ingredientFilter = filter }, Cmd.none )

        ResetAutocomplete toTop ->
            ( model, Cmd.none )



{--Reset index toTop ->--}
--let
--    autocomleteState =
--        Maybe.withDefault Autocomplete.empty (Array.get index model.ingredientAutoComplete)
--
--    nextStates =
--
--( { model | autoState =
--    if toTop then
--        Autocomplete.resetToFirstItem
{----}


removeIndexFromArray : Int -> Array a -> Array a
removeIndexFromArray index fromArray =
    let
        arrayUpToIndex =
            Array.slice 0 index fromArray

        arrayAfterIndex =
            Array.slice (index + 1) (Array.length fromArray) fromArray
    in
        Array.append arrayUpToIndex arrayAfterIndex


makeShellModel : Session -> Model
makeShellModel session =
    let
        token =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token

        userId =
            case session.user of
                Nothing ->
                    blankUserId

                Just user ->
                    user.userId
    in
        { recipe = Nothing
        , editingRecipe = emptyRecipe
        , units = Nothing
        , ingredients = Nothing
        , recipeId = 0
        , userId = userId
        , token = token
        , uiOpenDropdown = Nothing
        , ingredientAutoComplete = Autocomplete.empty
        , ingredientFilter = ""
        , selectedIngredientIndex = Nothing
        }


initNew : Session -> Task PageLoadError Model
initNew session =
    let
        token =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token

        userId =
            case session.user of
                Nothing ->
                    blankUserId

                Just user ->
                    user.userId

        mapResponses resultIngredients resultTags =
            { recipe = Nothing
            , editingRecipe = emptyRecipe
            , units = Just resultTags
            , ingredients = Just resultIngredients
            , token = token
            , recipeId = 0
            , userId = userId
            , uiOpenDropdown = Nothing
            , ingredientAutoComplete = Autocomplete.empty
            , ingredientFilter = ""
            , selectedIngredientIndex = Nothing
            }
    in
        Task.mapError (\_ -> pageLoadError Page.Other "Failed to load some needed pieces of recipe editor") <|
            Task.map2
                (mapResponses)
                (createIngredientsQueryTask token)
                (createUnitsQueryTask token)


initEdit : Session -> Recipe.Slug -> Task PageLoadError Model
initEdit session slug =
    let
        token =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token

        recipeIdInt =
            case (String.toInt (slugToString slug)) of
                Ok int ->
                    int

                _ ->
                    0

        userId =
            case session.user of
                Nothing ->
                    blankUserId

                Just user ->
                    user.userId

        shellModel =
            -- Enables conversion to EditingRecipeFull
            makeShellModel session

        mapResponses resultRecipe resultIngredients resultTags =
            { recipe = Just resultRecipe
            , editingRecipe = recipeFullToEditingRecipe shellModel (Just resultRecipe)
            , units = Just resultTags
            , ingredients = Just resultIngredients
            , token = token
            , recipeId = recipeIdInt
            , userId = userId
            , uiOpenDropdown = Nothing
            , ingredientAutoComplete = Autocomplete.empty
            , ingredientFilter = ""
            , selectedIngredientIndex = Nothing
            }
    in
        Task.mapError (\_ -> pageLoadError Page.Other "Failed to load some needed pieces of recipe editor") <|
            Task.map3
                (mapResponses)
                (createRecipeQueryTask token recipeIdInt)
                (createIngredientsQueryTask token)
                (createUnitsQueryTask token)


recipeFullToEditingRecipe : Model -> Maybe RecipeFull -> EditingRecipeFull
recipeFullToEditingRecipe model recipeFull =
    case recipeFull of
        Just recipe ->
            { description = recipe.description
            , id = recipe.id
            , imageUrl = recipe.imageUrl
            , instructions = recipe.instructions
            , name = recipe.name
            , tags = recipe.tags
            , ingredients = ingredientsToEditingIngredients model recipe.ingredients
            }

        Nothing ->
            model.editingRecipe


ingredientsToEditingIngredients model recipeIngredients =
    fromList (List.map (ingredientToEditingIngredient model) recipeIngredients)


ingredientToEditingIngredient : Model -> Ingredient -> EditingIngredient
ingredientToEditingIngredient model recipeIngredient =
    { quantity = toString recipeIngredient.quantity
    , ingredientId = recipeIngredient.id
    , unitId = recipeIngredient.unit.id
    }


getIngredientName : Maybe (List IngredientRaw) -> String -> String
getIngredientName ingredients ingredientId =
    case ingredients of
        Just ingredients ->
            case List.head (List.filter (\i -> i.id == ingredientId) ingredients) of
                Just foundIT ->
                    foundIT.name

                Nothing ->
                    ""

        Nothing ->
            ""


view : Model -> Html Msg
view model =
    recipeFormView model model.editingRecipe


recipeFormView :
    Model
    -> EditingRecipeFull
    -> Html Msg
recipeFormView model r =
    div
        [ style [ ( "-webkit-animation", "slideInLeft 0.25s linear" ), ( "animation", "slideInLeft 0.25s linear" ), ( "min-width", "260px" ) ]
        , onClick BodyClick
        ]
        [ div [ class "ui form recipe-editor-form" ]
            [ h1 [] [ text "Recipe Editor" ]
            , textInput r.name RecipeName False
            , textInput r.description RecipeDescription True
            , viewIngredientList model r
            , div
                [ class "field" ]
                []
            , div
                [ class "field" ]
                [ button [ class "ui primary button", role "button", onClick AddIngredient ] [ text "Add Ingredient" ] ]
            , textInput r.instructions RecipeInstructions True
            , button [ class "ui button", onClick Submit ] [ text "Save" ]
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
                [ rows 5 ]
            else
                [ type_ "text" ]
    in
        div [ class "field" ]
            [ label [ for inputId ] [ text inputLabel ]
            , div [ class "ui input" ]
                [ inputType ([ id inputId, value modelData, onInput (UpdateTextField textField) ] ++ moreAttrs) [] ]
            ]


viewIngredientList : Model -> EditingRecipeFull -> Html Msg
viewIngredientList model r =
    let
        ingredientForms =
            (label [] [ text "Ingredients" ])
                :: (Array.toList
                        (Array.indexedMap
                            (ingredientRow model)
                            r.ingredients
                        )
                   )
    in
        div []
            ingredientForms


ingredientRow : Model -> Int -> EditingIngredient -> Html Msg
ingredientRow model ingredientIndex ingredient =
    div [ class "fields recipe-editor-group" ]
        [ div [ class "two wide field" ]
            [ div [ class "ui input" ] [ input [ type_ "text", value ingredient.quantity, placeholder "#", onInput (UpdateIngredient IngredientQuanity ingredientIndex) ] [] ] ]
        , div [ class "four wide field" ]
            [ unitsDropdown model.units ingredientIndex ingredient.unitId model.uiOpenDropdown ]
        , div [ class "six wide field" ]
            [ ingredientView model ingredientIndex ingredient ]
        , div [ class "six wide field" ]
            [ button [ class "ui negative button", role "button", onClick (DeleteIngredient ingredientIndex) ] [ text "X" ] ]
        ]


unitsDropdown : Maybe (List Unit) -> Int -> String -> Maybe DropdownKey -> Html Msg
unitsDropdown units ingredientIndex ingredientUnitId openDropdown =
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

        displayUnit =
            case units of
                Nothing ->
                    ""

                Just res ->
                    case (List.head (List.filter (\n -> n.id == ingredientUnitId) res)) of
                        Nothing ->
                            ""

                        Just foundUnit ->
                            foundUnit.abbr
    in
        div
            [ class ("ui " ++ active ++ " selection dropdown")
            , tabindex 0
            , onWithOptions "click" { defaultOptions | stopPropagation = True } (Decode.succeed (ToggleIngredientDropdown (Just (UnitsDropdown ingredientIndex))))
            ]
            -- needs attr of role "listbox"
            [ div [ class "text" ] [ text displayUnit ] -- needs role of alert. This div represent the head of the list/the active element
            , i [ class "dropdown icon" ] []
            , div
                [ class
                    ("menu " ++ visible ++ " transition ")
                ]
                (case units of
                    Nothing ->
                        [ div [] [ text "no display units..." ] ]

                    Just res ->
                        List.map (measuringUnit ingredientIndex) res
                )
            ]


ingredientView : Model -> Int -> EditingIngredient -> Html Msg
ingredientView model ingredientIndex ingredient =
    let
        _ =
            Debug.log "Render ingredient" ingredient
    in
        div [ class "ingredient-view", onClick (IngredientFocused ingredientIndex) ]
            [ case model.selectedIngredientIndex of
                Just selectedIndex ->
                    if selectedIndex == ingredientIndex then
                        ingredientTypeAhead model ingredientIndex ingredient
                    else
                        text
                            (Maybe.withDefault "" (getIngredientNameFromId ingredient.ingredientId model.ingredients))

                Nothing ->
                    text (Maybe.withDefault "" (getIngredientNameFromId ingredient.ingredientId model.ingredients))
            ]


getIngredientNameFromId : String -> Maybe (List IngredientRaw) -> Maybe String
getIngredientNameFromId id ingredients =
    let
        _ =
            Debug.log "Hmmm" id

        maybeIngredient =
            findInList (\ingredient -> ingredient.id == id) (Maybe.withDefault [] ingredients)
    in
        case maybeIngredient of
            Just foundIngredient ->
                Just foundIngredient.name

            Nothing ->
                Nothing


findInList : (a -> Bool) -> List a -> Maybe a
findInList filter list =
    List.head
        (List.filter filter list)


ingredientTypeAhead : Model -> Int -> EditingIngredient -> Html Msg
ingredientTypeAhead model ingredientIndex ingredient =
    div [ class "ingredient-typeahead" ]
        [ input [ type_ "text", name "ingredientName", onInput UpdateTypeaheadFilter, onFocus (IngredientFocused ingredientIndex) ] []
        , div [ class "autocomplete-menu" ]
            [ Html.map
                SetAutocompleteState
                (Autocomplete.view
                    autocompleteViewConfig
                    10
                    model.ingredientAutoComplete
                    (filteredIngredients model)
                )
            ]
        ]


filteredIngredients : Model -> List IngredientRaw
filteredIngredients model =
    let
        ingredientList =
            Maybe.withDefault [] model.ingredients
    in
        List.filter (\a -> (String.contains model.ingredientFilter a.name)) ingredientList


measuringUnit : Int -> Unit -> Html Msg
measuringUnit index unit =
    div
        [ class "item"
        , style [ ( "pointer-events", "all" ) ]
        , onClick (SelectIngredientUnit index unit)
        ]
        --, onClick (SelectUnit unit.id) ]
        [ span [ class "text" ] [ text unit.abbr ] ]
