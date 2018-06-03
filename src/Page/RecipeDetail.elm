module Page.RecipeDetail exposing (ExternalMsg(..), Model, Msg, update, view, init)

-- CONTEXT --
-- TODO: Make this file build, and enable the highlighting feature thing.
-- ELM-LANG MODULES --

import Html exposing (Html, a, div, text, button, h1, ul, li, img, i, span, p)
import Html.Attributes exposing (src, style, class)
import Html.Events exposing (onClick)
import Task exposing (Task)


-- APPLICATION MODULES --

import Data.AuthToken exposing (AuthToken, getTokenString, blankToken)
import Data.Recipe
    exposing
        ( Ingredient
        , RecipeFull
        , RecipeFullResponse
        , RecipeId
        , RecipeQueryMsg(..)
        , Slug(..)
        , slugToString
        , createRecipeQueryTask
        )
import Data.Session exposing (Session)
import Page.Errored exposing (PageLoadError(..), pageLoadError)
import Views.Page as Page
import Util exposing (getImageUrl)
import Route as Route exposing (Route(..), href)


type ExternalMsg
    = NoOp


type alias Model =
    { mRecipe : RecipeFullResponse
    , token : AuthToken
    , recipeId : RecipeId
    , focusedIngredient : Maybe IngredientId
    }


init : Session -> Slug -> String -> Task PageLoadError Model
init session slug apiUrl =
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
    in
        (createRecipeQueryTask token recipeIdInt apiUrl)
            |> Task.mapError (\_ -> pageLoadError Page.Other "Unable to load recipe")
            |> Task.map (initResultMap token recipeIdInt)


initResultMap : AuthToken -> RecipeId -> RecipeFull -> Model
initResultMap token id recipeFull =
    { mRecipe = Ok recipeFull, token = token, recipeId = id, focusedIngredient = Nothing }


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        Query subMsg ->
            case subMsg of
                ReceiveRecipeFull r ->
                    ( ( { model | mRecipe = r }, Cmd.none ), NoOp )

                _ ->
                    ( ( model, Cmd.none ), NoOp )

        IngredientFocus ingredientId ->
            let
                oldFocus =
                    model.focusedIngredient

                newFocus =
                    if Just ingredientId == oldFocus then
                        Nothing
                    else
                        Just ingredientId
            in
                ( ( { model | focusedIngredient = newFocus }, Cmd.none ), NoOp )


type alias IngredientId =
    String


type Msg
    = Query RecipeQueryMsg
      -- UI
    | IngredientFocus IngredientId


view : Session -> Model -> Html Msg
view session model =
    --case model.mRecipe of
    case model.mRecipe of
        Ok r ->
            viewDetailSuccess r model.focusedIngredient

        Err r ->
            text ("asf, you has err: " ++ (toString r))


viewDetailSuccess : RecipeFull -> Maybe IngredientId -> Html Msg
viewDetailSuccess r focusedRecipeId =
    let
        noImage =
            String.isEmpty r.imageUrl

        mImg =
            if noImage then
                (text "")
            else
                div [] [ img [ class "ui medium centered image", src (getImageUrl r.imageUrl) ] [] ]
    in
        div
            [ class "ui container" ]
            [ a [ class "link", Route.href (EditRecipe (Slug r.id)) ] [ text "Edit recipe" ]
            , div
                [ class "slideInLeft"
                , style [ ( "padding-bottom", "3px" ), ( "margin-top", "25px" ) ]
                ]
                [ div [ class "ui fluid card" ]
                    [ mImg
                    , div [ class "content" ]
                        [ div [ class "header" ] [ text r.name ]
                        , div [ class "meta" ] [ text r.author ]
                        , div [ class "meta" ]
                            [ div [ style [ ( "display", "flex" ), ( "margin-top", "5px" ) ] ]
                                []
                            ]
                        , div [ class "description" ]
                            [ div [ style [ ( "margin-top", "15px" ), ( "white-space", "pre-wrap" ) ] ] []
                            , ul [] (List.map (viewIngredient focusedRecipeId) r.ingredients)
                            , p [ style [ ( "white-space", "pre-wrap" ) ] ] [ text r.instructions ]
                            ]
                        , div
                            [ class "description"
                            , style
                                [ ( "display", "flex" )
                                , ( "justify-content", "space-between" )
                                , ( "align-items", "center" )
                                ]
                            ]
                            [ span []
                                [ i
                                    [ class <|
                                        "favorite big icon "
                                            ++ (if r.youLike then
                                                    "teal"
                                                else
                                                    "grey"
                                               )
                                    ]
                                    []
                                , span [] [ text (likesText r.likes) ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]


likesText : List a -> String
likesText l =
    let
        likes =
            List.length l
    in
        (toString likes)
            ++ " like"
            ++ if likes == 1 then
                ""
               else
                "s"


formatIngredient : Ingredient -> String
formatIngredient i =
    i.displayQuantity ++ " " ++ i.unit.abbr ++ " " ++ i.name


viewIngredient : Maybe IngredientId -> Ingredient -> Html Msg
viewIngredient focusedIngredientId ingredient =
    let
        isFocused =
            case focusedIngredientId of
                Nothing ->
                    False

                Just id ->
                    ingredient.id == id
    in
        li
            [ style
                [ ( "margin-top", "5px" )
                , ( "white-space", "pre-wrap" )
                , ( "background-color"
                  , (if isFocused then
                        "#f9f9f9"
                     else
                        "initial"
                    )
                  )
                ]
            , onClick (IngredientFocus ingredient.id)
            ]
            [ text (formatIngredient ingredient)
            ]
