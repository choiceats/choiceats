module Page.RecipeDetail exposing (ExternalMsg(..), Model, Msg, update, view, init)

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
        , submitLikeMutation
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
    , session : Session
    , token : AuthToken
    , recipeId : RecipeId
    , focusedIngredient : Maybe IngredientId
    , isChangingLike : Bool
    , apiUrl : String
    }


toggleLike : AuthToken -> String -> RecipeId -> String -> Cmd RecipeQueryMsg
toggleLike token userId recipeId apiUrl =
    submitLikeMutation token ReceiveRecipeFull userId recipeId apiUrl


init : Session -> Slug -> String -> Task PageLoadError Model
init session slug apiUrl =
    let
        token =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token

        recipeId =
            (slugToString slug)
    in
        (createRecipeQueryTask token recipeId apiUrl)
            |> Task.mapError (\_ -> pageLoadError Page.Other "Unable to load recipe")
            |> Task.map (initResultMap apiUrl session token recipeId)


initResultMap : String -> Session -> AuthToken -> RecipeId -> RecipeFull -> Model
initResultMap apiUrl session token id recipeFull =
    { mRecipe = Ok recipeFull
    , token = token
    , session = session
    , recipeId = id
    , focusedIngredient = Nothing
    , isChangingLike = False
    , apiUrl = apiUrl
    }


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        Query subMsg ->
            case subMsg of
                ReceiveRecipeFull r ->
                    ( ( { model | mRecipe = r, isChangingLike = False }, Cmd.none ), NoOp )

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

        ToggleLike ingredientId ->
            ( ( { model | isChangingLike = True }, convertToLocalCmd (toggleLike model.token "DUMMY_USER_ID" model.recipeId model.apiUrl) ), NoOp )


type alias IngredientId =
    String


type Msg
    = Query RecipeQueryMsg
      -- UI
    | IngredientFocus IngredientId
    | ToggleLike IngredientId


convertToLocalCmd : Cmd RecipeQueryMsg -> Cmd Msg
convertToLocalCmd recipeQueryCmd =
    Cmd.map (\queryCmd -> Query queryCmd) recipeQueryCmd


view : Session -> Model -> Html Msg
view session model =
    --case model.mRecipe of
    case model.mRecipe of
        Ok r ->
            viewDetailSuccess r model.focusedIngredient

        Err r ->
            text ("you has err: " ++ (toString r))


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
                                , ( "justify-content", "flex-start" )
                                , ( "align-items", "center" )
                                ]
                            , onClick (ToggleLike r.id)
                            ]
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
                            , span [] [ text (likesText (List.length r.likes) r.youLike) ]
                            ]
                        ]
                    ]
                ]
            ]


likesText : Int -> Bool -> String
likesText likes youLike =
    case ( likes, youLike ) of
        ( 0, _ ) ->
            "Be the first to like this."

        ( 1, True ) ->
            "You like this."

        ( 1, False ) ->
            "1 person likes this."

        ( _, True ) ->
            let
                otherLikes =
                    likes - 1
            in
                "You and "
                    ++ (toString otherLikes)
                    ++ " other"
                    ++ (if (otherLikes > 0) then
                            "s"
                        else
                            ""
                       )
                    ++ " like this."

        ( _, False ) ->
            (toString (likes - 1)) ++ " others like this."


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
