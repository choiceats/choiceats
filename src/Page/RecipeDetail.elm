module Page.RecipeDetail exposing (ExternalMsg(..), Model, Msg(..), update, view, init)

-- ELM-LANG MODULES --

import Json.Decode as Decode
import Html exposing (Html, a, div, text, button, h1, ul, li, img, i, span, p)
import Html.Attributes exposing (src, style, class, tabindex, href)
import Html.Events exposing (onClick, onWithOptions)
import Task exposing (Task)


-- APPLICATION MODULES --

import Data.AuthToken exposing (AuthToken, getTokenString, blankToken)
import Data.Recipe
    exposing
        ( Ingredient
        , RecipeFull
        , RecipeFullResponse
        , DeleteRecipeResponse
        , RecipeId
        , RecipeQueryMsg(..)
        , Slug(..)
        , slugToString
        , createRecipeQueryTask
        , submitLikeMutation
        , submitDeleteMutation
        )
import Data.Session exposing (Session)
import Data.User exposing (UserId(..))
import Page.Errored exposing (PageLoadError(..), pageLoadError)
import Views.Page as Page
import Util exposing (getImageUrl, getDetailsLikesText)
import Route as Route exposing (Route(..), href)


type ExternalMsg
    = NoOp


type alias Model =
    { mRecipe : RecipeFullResponse
    , session : Session
    , token : AuthToken
    , recipeId : RecipeId
    , focusedIngredient : Maybe IngredientId
    , showConfirmDelete : Bool
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
    , showConfirmDelete = False
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

        DeleteRecipe recipeId ->
            ( ( { model | showConfirmDelete = False }, (submitDeleteMutation model.token ReceiveDeleteRecipe recipeId model.apiUrl) ), NoOp )

        ReceiveDeleteRecipe res ->
            ( ( model, Cmd.none ), NoOp )

        ShowConfirmDelete ->
            ( ( { model | showConfirmDelete = True }, Cmd.none ), NoOp )

        CancelDelete ->
            ( ( { model | showConfirmDelete = False }, Cmd.none ), NoOp )


type alias IngredientId =
    String


type Msg
    = Query RecipeQueryMsg
      -- UI
    | IngredientFocus IngredientId
    | ToggleLike IngredientId
    | DeleteRecipe IngredientId
    | ShowConfirmDelete
    | CancelDelete
    | ReceiveDeleteRecipe DeleteRecipeResponse


convertToLocalCmd : Cmd RecipeQueryMsg -> Cmd Msg
convertToLocalCmd recipeQueryCmd =
    Cmd.map (\queryCmd -> Query queryCmd) recipeQueryCmd


convertToLocalDeleteMessage : Cmd DeleteRecipeResponse -> Cmd Msg
convertToLocalDeleteMessage x =
    Cmd.map (\y -> ReceiveDeleteRecipe y) x



-- map cu


view : Session -> Model -> Html Msg
view session model =
    case model.mRecipe of
        Ok r ->
            viewDetailSuccess r model.focusedIngredient model.session model.showConfirmDelete

        Err r ->
            text ("you has err: " ++ (toString r))


adminLinks : Session -> String -> String -> Html Msg
adminLinks session authorId recipeId =
    let
        userId =
            case session.user of
                Just user ->
                    case user.userId of
                        UserId x ->
                            x

                Nothing ->
                    "0"
    in
        if (userId == authorId) then
            div [ class "recipe-detail__admin-links" ]
                [ a [ class "link", Route.href (EditRecipe (Slug recipeId)) ] [ text "Edit recipe" ]
                , a
                    [ class "link recipe-detail__delete-link"
                    , Html.Attributes.href "/"
                    , onWithOptions "click" { stopPropagation = False, preventDefault = True } (Decode.succeed ShowConfirmDelete)
                    ]
                    [ text "Delete recipe" ]
                ]
        else
            text ""


confirmDeleteModal : Bool -> String -> Html Msg
confirmDeleteModal showConfirmDelete recipeId =
    if showConfirmDelete then
        div [ class "ui dimmer modals page transition visible active" ]
            [ div
                [ class "ui fullscreen modal visible active recipe-detail__confirm-delete" ]
                [ div
                    [ class "content" ]
                    [ div [] [ text "Are you sure you want to delete this recipe?" ]
                    ]
                , div [ class "actions" ]
                    [ button [ class "ui button", onClick CancelDelete ] [ text "No" ]
                    , button [ class "ui button danger", onClick (DeleteRecipe recipeId) ] [ text "Yes" ]
                    ]
                ]
            ]
    else
        text ""


viewDetailSuccess : RecipeFull -> Maybe IngredientId -> Session -> Bool -> Html Msg
viewDetailSuccess r focusedRecipeId session showConfirmDelete =
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
            [ class "ui container recipe-detail" ]
            [ adminLinks session r.authorId r.id
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
                                , ( "margin-top", "15px" )
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
                                , tabindex 0
                                ]
                                []
                            , span [] [ text (getDetailsLikesText (List.length r.likes) r.youLike) ]
                            ]
                        ]
                    ]
                ]
            , confirmDeleteModal showConfirmDelete r.id
            ]


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
