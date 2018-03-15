module RecipeEditor exposing (main)

import Array exposing (Array, fromList, toList)
import Html exposing (Html, h1, label, button, textarea, form, div, input, text, a, img, i, option, select, span)
import Html.Attributes exposing (type_, class, style, href, src, placeholder, value, for, id, rows, tabindex, name, attribute)
import Html.Attributes.Aria exposing (role)
import Html.Events exposing (onClick, onInput, onWithOptions, defaultOptions)
import Json.Decode as Decode
import Recipes.Types
import RecipeQueries
    exposing
        ( RecipeQueryMsg(..)
        , sendUnitsQuery
        , sendRecipeQuery
        , sendIngredientsQuery
        , submitRecipeMutation
        )


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
    { recipe : Maybe Recipes.Types.RecipeFull
    , editingRecipe : Recipes.Types.EditingRecipeFull
    , flags : RecipeFlags
    , units : Maybe (List Recipes.Types.Unit)
    , ingredients : Maybe (List Recipes.Types.IngredientRaw)

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
    | Submit
    | UpdateIngredient IngredientField Int String
    | SelectIngredientUnit Int Recipes.Types.Unit
    | SelectIngredient Int Recipes.Types.IngredientRaw
    | AddIngredient
    | DeleteIngredient Int

emptyRecipe : Recipes.Types.EditingRecipeFull 
emptyRecipe = 
    { description = ""
    , id = ""
    , imageUrl = ""
    , ingredients = Array.empty
    , instructions = ""
    , name = ""
    , tags = []

    }

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


queryForIngredients flags =
    sendIngredientsQuery flags.token ReceiveIngredients


submitRecipe : Model -> Cmd RecipeQueryMsg
submitRecipe model =
    submitRecipeMutation model.flags.token model.editingRecipe ReceiveRecipeFull


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
                    ( model, convertToLocalCmd (queryForRecipe model.flags) )

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
                editingRecipe = model.editingRecipe
            in
                case textfield of
                    RecipeName ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | name = value })

                            newEditingRecipe = updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    RecipeDescription ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | description = value })

                            newEditingRecipe = updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

                    RecipeInstructions ->
                        let
                            updatedEditingRecipeModel =
                                ({ editingRecipe | instructions = value })

                            newEditingRecipe = updatedEditingRecipeModel
                        in
                            ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

        UpdateIngredient field ingredientIndex value ->
            let
                 editingRecipe = model.editingRecipe
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
                 editingRecipe = model.editingRecipe
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
                editingRecipe = model.editingRecipe
            
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
                editingRecipe = model.editingRecipe
                newIngredientList =
                    Array.push
                        { quantity = ""
                        , ingredientId = ""
                        , unitId = ""
                        }
                        editingRecipe.ingredients

                newEditingRecipe = { editingRecipe | ingredients = newIngredientList }
            in
                ( { model | editingRecipe = newEditingRecipe }, Cmd.none )

        DeleteIngredient index ->
            let
                editingRecipe = model.editingRecipe
                beforeIngredientList =
                    Array.slice 0 index editingRecipe.ingredients

                afterIngredientList =
                    Array.slice (index + 1) (Array.length editingRecipe.ingredients) editingRecipe.ingredients

                newIngredientList =
                    Array.append beforeIngredientList afterIngredientList

                newEditingRecipe = { editingRecipe | ingredients = newIngredientList }
            in
                ( { model | editingRecipe = newEditingRecipe }, Cmd.none )



init : RecipeFlags -> ( Model, Cmd Msg )
init flags =
    ( { recipe = Nothing, editingRecipe = emptyRecipe, units = Nothing, ingredients = Nothing, flags = flags, uiOpenDropdown = Nothing }
    , Cmd.batch
        [ convertToLocalCmd (queryForRecipe flags)
        , convertToLocalCmd (queryForTags flags)
        , convertToLocalCmd (queryForIngredients flags)
        ]
    )


recipeFullToEditingRecipe : Model -> Maybe Recipes.Types.RecipeFull -> Recipes.Types.EditingRecipeFull
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


ingredientToEditingIngredient : Model -> Recipes.Types.Ingredient -> Recipes.Types.EditingIngredient
ingredientToEditingIngredient model recipeIngredient =
    { quantity = toString recipeIngredient.quantity
    , ingredientId = getIngredientId model.ingredients recipeIngredient
    , unitId = recipeIngredient.unit.id
    }


getIngredientId : Maybe (List Recipes.Types.IngredientRaw) -> Recipes.Types.Ingredient -> String
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


getIngredientName : Maybe (List Recipes.Types.IngredientRaw) -> String -> String
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
    -> Recipes.Types.EditingRecipeFull
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


viewIngredientList : Model -> Recipes.Types.EditingRecipeFull -> Html Msg
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


ingredientRow : Model -> Int -> Recipes.Types.EditingIngredient -> Html Msg
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


unitsDropdown : Maybe (List Recipes.Types.Unit) -> Int -> String -> Maybe DropdownKey -> Html Msg
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


ingredientTypeAhead : Model -> Int -> Recipes.Types.EditingIngredient -> Maybe DropdownKey -> Html Msg
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


ingredientItem : Int -> Recipes.Types.EditingIngredient -> Recipes.Types.IngredientRaw -> Html Msg
ingredientItem index ingredient ingredientRaw =
    div
        [ class "item"
        , attribute "data-value" "42"
        , onClick (SelectIngredient index ingredientRaw)
        ]
        [ text ingredientRaw.name ]


measuringUnit : Int -> Recipes.Types.Unit -> Html Msg
measuringUnit index unit =
    div
        [ class "item"
        , style [ ( "pointer-events", "all" ) ]
        , onClick (SelectIngredientUnit index unit)
        ]
        --, onClick (SelectUnit unit.id) ]
        [ span [ class "text" ] [ text unit.abbr ] ]
