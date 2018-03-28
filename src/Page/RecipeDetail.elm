module Page.RecipeDetail exposing (ExternalMsg(..), Model, Msg, update, view, init)

-- ELM-LANG MODULES --

import Html exposing (Html, div, text, button, h1, ul, li, img, i, span, p)
import Html.Attributes exposing (src, style, class)
import Http
import Task exposing (Task)


-- THIRD PARTY MODULES --

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


-- APPLICATION MODULES --

import Data.AuthToken exposing (AuthToken, getTokenString, blankToken)
import Data.Recipe
    exposing
        ( Ingredient
        , RecipeFull
        , RecipeFullResponse
        , RecipeId
        , RecipeQueryMsg(..)
        , Slug
        , slugToString
        , createRecipeQueryTask
        )
import Data.Session exposing (Session)
import Page.Errored exposing (PageLoadError(..), pageLoadError)
import Views.Page as Page
import Util exposing (getImageUrl)


type ExternalMsg
    = NoOp


type alias Model =
    { mRecipe : RecipeFullResponse
    , token : AuthToken
    , recipeId : RecipeId
    }


init : Session -> Slug -> Task PageLoadError Model
init session slug =
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
        (createRecipeQueryTask token recipeIdInt)
            |> Task.mapError (\_ -> pageLoadError Page.Other "Unable to load recipe")
            |> Task.map (initResultMap token recipeIdInt)


initResultMap : AuthToken -> RecipeId -> RecipeFull -> Model
initResultMap token id recipeFull =
    { mRecipe = Ok recipeFull, token = token, recipeId = id }


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        Query subMsg ->
            case subMsg of
                ReceiveRecipeFull r ->
                    ( ( { model | mRecipe = r }, Cmd.none ), NoOp )

                _ ->
                    ( ( model, Cmd.none ), NoOp )


type Msg
    = Query RecipeQueryMsg


view : Session -> Model -> Html Msg
view session model =
    --case model.mRecipe of
    case model.mRecipe of
        Ok r ->
            div []
                [ viewDetailSuccess r
                ]

        Err r ->
            text ("asf, you has err: " ++ (toString r))


viewDetailSuccess : RecipeFull -> Html Msg
viewDetailSuccess r =
    let
        noImage =
            String.isEmpty r.imageUrl

        mImg =
            if noImage then
                (text "")
            else
                img [ class "ui image", src (getImageUrl r.imageUrl) ] []
    in
        div
            [ style
                [ ( "height", "calc(100vh - 50px)" )
                , ( "overflow", "auto" )
                , ( "padding", "20px" )
                ]
            ]
            [ div
                [ style
                    [ ( "margin", "auto" )
                    , ( "max-width", "1000px" )
                    , ( "margin-top", "10px" )
                    ]
                ]
                [ div [ style [ ( "margin-top", "25px" ) ] ]
                    [ div
                        [ class "slideInLeft"
                        , style [ ( "padding-bottom", "3px" ) ]
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
                                    , ul [] (List.map (\i -> viewIngredient <| formatIngredient i) r.ingredients)
                                    , p [ style [ ( "white-space", "pre-wrap" ) ] ] [ text r.instructions ]
                                    ]
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
                                    , span [] [ text ("Likes: " ++ toString r.likes) ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]


formatIngredient : Ingredient -> String
formatIngredient i =
    i.displayQuantity ++ " " ++ i.unit.name ++ " " ++ i.name


viewIngredient : String -> Html Msg
viewIngredient ingredientText =
    li
        [ style
            [ ( "margin-top", "5px" )
            , ( "white-space", "pre-wrap" )
            ]
        ]
        [ text ingredientText
        ]
