module Page.RecipeEditor exposing (update, view, initNew, initEdit, Model, Msg(..))

-- ELM-LANG MODULES --

import Array exposing (Array, fromList, toList)
import Html exposing (Html, a, button, div, form, h1, i, input, label, span, text, textarea)
import Html.Attributes exposing (attribute, class, for, href, id, name, placeholder, rows, src, style, tabindex, type_, value)
import Html.Attributes.Aria exposing (role)
import Html.Events exposing (defaultOptions, onClick, onInput, onWithOptions)
import Json.Decode as Decode
import Task exposing (Task)


-- THIRD PARTY MODULES --
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
    , units : Maybe (List Unit)
    , ingredients : Maybe (List IngredientRaw)
    , recipeId : Int
    , token : AuthToken
    , userId : UserId

    -- UI
    , uiOpenDropdown : Maybe DropdownKey
    }


type Msg
    = None
    | Query RecipeQueryMsg
      -- UI Events
    | AddIngredient
    | BodyClick
    | DeleteIngredient Int
    | SelectIngredient Int IngredientRaw
    | SelectIngredientUnit Int Unit
    | Submit
    | ToggleIngredientDropdown (Maybe DropdownKey)
    | UpdateIngredient IngredientField Int String
    | UpdateTextField TextField String


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

        SelectIngredient index rawIngredient ->
            let
                editingRecipe =
                    model.editingRecipe
            in
                case Array.get index editingRecipe.ingredients of
                    Just foundIngredient ->
                        let
                            newIngredient =
                                { foundIngredient | ingredientId = rawIngredient.id }

                            newIngredients =
                                Array.set index newIngredient editingRecipe.ingredients

                            newEditingRecipe =
                                { editingRecipe | ingredients = newIngredients }
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

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

                beforeIngredientList =
                    Array.slice 0 index editingRecipe.ingredients

                afterIngredientList =
                    Array.slice (index + 1) (Array.length editingRecipe.ingredients) editingRecipe.ingredients

                newIngredientList =
                    Array.append beforeIngredientList afterIngredientList

                newEditingRecipe =
                    { editingRecipe | ingredients = newIngredientList }
            in
                ( { model | editingRecipe = newEditingRecipe }, Cmd.none )


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
    , ingredientId = getIngredientId model.ingredients recipeIngredient
    , unitId = recipeIngredient.unit.id
    }


getIngredientId : Maybe (List IngredientRaw) -> Ingredient -> String
getIngredientId ingredients recipeIngredient =
    case ingredients of
        Just ingredients ->
            case List.head (List.filter (\i -> i.name == recipeIngredient.name) ingredients) of
                Just foundIT ->
                    foundIT.id

                Nothing ->
                    ""

        Nothing ->
            ""


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

            -- , div [ class "field" ]
            --     [ label [ class "field" ] [ text "Tags" ]
            --     , div [ class "ui multiple selection dropdown", tabindex 0, role "listbox" ]
            --         [ a [ class "ui label", value "0" ] [ text "Spicy", i [ class "delete icon" ] [] ] ]
            --     , div [ class "text", role "alert" ] []
            --     , i [ class "dropdown icon" ] []
            --     , div [ class "menu transition" ] []
            --     ]
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
            [ ingredientTypeAhead model ingredientIndex ingredient model.uiOpenDropdown ]
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


ingredientTypeAhead : Model -> Int -> EditingIngredient -> Maybe DropdownKey -> Html Msg
ingredientTypeAhead model ingredientIndex ingredient openDropdown =
    let
        isVisible =
            case openDropdown of
                Just (IngredientDropdown dd) ->
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
            , onWithOptions "click" { defaultOptions | stopPropagation = True } (Decode.succeed (ToggleIngredientDropdown (Just (IngredientDropdown ingredientIndex))))
            ]
            [ input [ type_ "hidden", name "gender" ] []
            , i [ class "dropdown icon" ] []
            , div [ class "default text" ] [ text (getIngredientName model.ingredients ingredient.ingredientId) ]
            , div [ class ("menu " ++ visible ++ " transition") ]
                (case model.ingredients of
                    Nothing ->
                        [ div [] [ text "Na uh uh.  You didn't say the magic word" ] ]

                    Just ingred ->
                        List.map (ingredientItem ingredientIndex ingredient) ingred
                )
            ]


ingredientItem : Int -> EditingIngredient -> IngredientRaw -> Html Msg
ingredientItem index ingredient ingredientRaw =
    div
        [ class "item"
        , attribute "data-value" "42"
        , onClick (SelectIngredient index ingredientRaw)
        ]
        [ text ingredientRaw.name ]


measuringUnit : Int -> Unit -> Html Msg
measuringUnit index unit =
    div
        [ class "item"
        , style [ ( "pointer-events", "all" ) ]
        , onClick (SelectIngredientUnit index unit)
        ]
        --, onClick (SelectUnit unit.id) ]
        [ span [ class "text" ] [ text unit.abbr ] ]
