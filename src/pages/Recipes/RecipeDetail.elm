port module Recipes.RecipeDetail exposing (main)

--  ELM-LANG MODULES

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (Html, div, text, button, h1, ul, li, img, i, span)
import Html.Attributes exposing (src, style, class)
import Http
import Task exposing (Task)
import Recipes.Types exposing (..)
import RecipeQueries
    exposing
        ( RecipeQueryMsg(..)
        , sendUnitsQuery
        , sendRecipeQuery
        , sendIngredientsQuery
        , submitRecipeMutation
        )


type alias Model =
    { mRecipe : Maybe RecipeFullResponse
    , flags : Flags
    }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { update = update
        , view = viewDetail
        , init = init
        , subscriptions = subscriptions
        }


convertToLocalCmd : Cmd RecipeQueryMsg -> Cmd Msg
convertToLocalCmd recipeQueryCmd =
    Cmd.map (\queryCmd -> Query queryCmd) recipeQueryCmd


queryForRecipe flags =
    sendRecipeQuery flags.token flags.recipeId ReceiveRecipeFull


init : Flags -> ( Model, Cmd Msg )
init initFlags =
    ( { mRecipe = Nothing
      , flags = initFlags
      }
    , convertToLocalCmd (queryForRecipe initFlags)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Query subMsg ->
            case subMsg of
                -- RequestRecipeFull ->
                --     ( model, sendRecipeQuery model.flags.token model.flags.recipeId )
                ReceiveRecipeFull res ->
                    ( { model | mRecipe = Just res }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


type Msg
    = NoOp
    | Query RecipeQueryMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias AuthToken =
    String


type alias RecipeId =
    Int


viewDetail : Model -> Html Msg
viewDetail model =
    case model.mRecipe of
        Just res ->
            case res of
                Ok r ->
                    div []
                        [ viewDetailSuccess r
                        , div [] [ text <| toString res ]
                        ]

                Err r ->
                    text ("asf, you has err: " ++ (toString r))

        Nothing ->
            text "loading..."


viewDetailSuccess : RecipeFull -> Html Msg
viewDetailSuccess r =
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
                        [ img [ class "ui image", src "/zorak-picture.jpg" ] []
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
