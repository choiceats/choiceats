module Page.Randomizer exposing (ExternalMsg(..), Model, Msg, init, update, view)

-- ELM-LANG MODULES --
-- THIRD PARTY MODULES --
-- APPLICATION MODULES --

import Data.AuthToken as AuthToken exposing (AuthToken, blankToken, getTokenString)
import Data.Recipe
    exposing
        ( RecipeSummary
        , SearchFilter(..)
        , gqlRecipeSummary
        , mapFilterTypeToString
        , requestOptions
        )
import Data.Session exposing (Session)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (Html, a, button, div, form, h1, i, img, input, label, text)
import Html.Attributes exposing (class, disabled, for, href, id, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Result exposing (withDefault)
import Route exposing (Route, href)
import Task exposing (Task)
import Util exposing (graphQlErrorToString)


words =
    { new = "NEW IDEA!"
    , errorPrefix = "ruh rohr, you has err: "
    , like = "like"
    , likes = "likes"
    }


type Msg
    = RequestRecipe
    | SetFilterType SearchFilter
    | ReceiveQueryResponse RecipeResponse


type alias RecipeResponse =
    Result GraphQLClient.Error RecipeSummary


type ExternalMsg
    = NoOp



-- Types.elm --


type alias Model =
    { currentFilter : SearchFilter
    , mRecipeSummary : Maybe RecipeResponse
    , token : AuthToken
    , apiUrl : String
    }


init : Session -> String -> ( Model, Cmd Msg )
init session apiUrl =
    let
        authToken =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token
    in
    ( { currentFilter = All
      , mRecipeSummary = Nothing
      , apiUrl = apiUrl
      , token = authToken
      }
    , sendRecipeQuery authToken All apiUrl
    )


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        RequestRecipe ->
            ( ( model, sendRecipeQuery model.token model.currentFilter model.apiUrl ), NoOp )

        SetFilterType filter ->
            ( ( { model | currentFilter = filter }, Cmd.none ), NoOp )

        ReceiveQueryResponse res ->
            ( ( { model | mRecipeSummary = Just res }, Cmd.none ), NoOp )


view : Session -> Model -> Html Msg
view session model =
    div [ class "ui container" ]
        [ viewFilterButtons model
        , viewRecipeSummary model.mRecipeSummary
        , viewGetNewRecipe model
        ]



-- Effects.elm --


recipeRequest : GqlB.Document GqlB.Query RecipeSummary { vars | searchFilter : String }
recipeRequest =
    let
        searchFilterVar =
            Var.required "searchFilter" .searchFilter Var.string

        queryRoot =
            GqlB.extract
                (GqlB.field "randomRecipe"
                    [ ( "searchFilter", Arg.variable searchFilterVar ) ]
                    gqlRecipeSummary
                )
    in
    GqlB.queryDocument queryRoot


recipeQueryRequest : SearchFilter -> GqlB.Request GqlB.Query RecipeSummary
recipeQueryRequest buttonFilter =
    recipeRequest
        |> GqlB.request { searchFilter = mapFilterTypeToString buttonFilter }


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> String -> Task GraphQLClient.Error a
sendQueryRequest authToken request apiUrl =
    GraphQLClient.customSendQuery (requestOptions authToken apiUrl) request


sendRecipeQuery : AuthToken -> SearchFilter -> String -> Cmd Msg
sendRecipeQuery authToken buttonFilter apiUrl =
    sendQueryRequest authToken (recipeQueryRequest buttonFilter) apiUrl
        |> Task.attempt ReceiveQueryResponse



-- ViewFilterButtons.elm --


viewFilterButtons : Model -> Html Msg
viewFilterButtons model =
    div
        [ class "ui fluid buttons"
        ]
        [ filterButton All model.currentFilter
        , filterButton Fav model.currentFilter
        , filterButton My model.currentFilter
        ]


filterButton : SearchFilter -> SearchFilter -> Html Msg
filterButton choice currentFilter =
    button
        [ class
            (if choice == currentFilter then
                "ui active button"

             else
                "ui button"
            )
        , onClick (SetFilterType choice)

        --  , role "button"
        ]
        [ text (mapFilterTypeToString choice) ]



-- ViewGetNewRecipe.elm --


viewGetNewRecipe : Model -> Html Msg
viewGetNewRecipe model =
    div
        [ style "width" "100%"
        , style "text-align" "center"
        , style "margin-top" "15px"
        ]
        [ button
            [ type_ "submit"
            , class "ui primary button"
            , onClick RequestRecipe
            ]
            [ text words.new ]
        ]


viewRecipeSummary : Maybe RecipeResponse -> Html Msg
viewRecipeSummary mRecipeSummary =
    case mRecipeSummary of
        Just res ->
            case res of
                Ok r ->
                    a [ Route.href (Route.RecipeDetail (Data.Recipe.Slug r.id)) ]
                        [ div [ class "ui fluid card", style "margin-bottom" "15px" ]
                            [ img [ class "ui image", src r.imageUrl ] []
                            , div [ class "content" ]
                                [ div [ class "header" ] [ text r.name ]
                                , div [ class "meta" ] [ text r.author ]
                                , div [ class "meta" ]
                                    [ i
                                        [ class <|
                                            if r.youLike then
                                                "green"

                                            else
                                                "grey" ++ " favorite large icon"
                                        ]
                                        []
                                    , text (likesText r.likes)
                                    ]
                                ]
                            , div [ class "description" ] [ text r.description ]
                            ]
                        ]

                Err err ->
                    div [] [ text (words.errorPrefix ++ graphQlErrorToString err) ]

        Nothing ->
            viewLoading


likesText : List a -> String
likesText l =
    let
        likes =
            List.length l
    in
    String.fromInt likes
        ++ " "
        ++ (if likes == 1 then
                words.like

            else
                words.likes
           )


viewLoading : Html Msg
viewLoading =
    div
        [ class "ui massive active text centered inline loader" ]
        [ text "Loading" ]
