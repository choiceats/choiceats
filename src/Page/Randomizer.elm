module Page.Randomizer exposing (ExternalMsg(..), Model, Msg, update, view, init)

-- ELM-LANG MODULES --

import Html exposing (Html, div, a, text, label, input, button, h1, form, img, i)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id, href, src)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (Error, send, post, stringBody)
import Json.Decode as JD exposing (bool, decodeString, field, int, map4, string)
import Json.Encode as JE exposing (object, string, encode)
import Task exposing (Task)
import Result exposing (withDefault)


-- THIRD PARTY MODULES --

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Client.Http as GraphQLClient


-- APPLICATION MODULES --

import Data.AuthToken as AuthToken exposing (AuthToken, getTokenString, blankToken)
import Data.Session exposing (Session)
import Data.Recipe
    exposing
        ( mapFilterTypeToString
        , requestOptions
        , RecipeSummary
        , SearchFilter(..)
        , gqlRecipeSummary
        )
import Data.User exposing (User, decoder)
import Route exposing (Route)


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
    }


init : Session -> ( Model, Cmd Msg )
init session =
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
          , token = authToken
          }
        , sendRecipeQuery authToken All
        )


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        RequestRecipe ->
            ( ( model, sendRecipeQuery model.token model.currentFilter ), NoOp )

        SetFilterType msg ->
            ( ( { model | currentFilter = msg }, Cmd.none ), NoOp )

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
        |> GqlB.request { searchFilter = (mapFilterTypeToString buttonFilter) }


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request


sendRecipeQuery : AuthToken -> SearchFilter -> Cmd Msg
sendRecipeQuery authToken buttonFilter =
    sendQueryRequest authToken (recipeQueryRequest buttonFilter)
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
            (if (choice == currentFilter) then
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
        [ style
            [ ( "width", "100%" )
            , ( "text-align", "center" )
            , ( "margin-top", "15px" )
            ]
        ]
        [ button
            [ type_ "submit"
            , class "ui primary button"
            , onClick RequestRecipe
            ]
            [ text "NEW IDEA!" ]
        ]


viewRecipeSummary : Maybe RecipeResponse -> Html Msg
viewRecipeSummary mRecipeSummary =
    case mRecipeSummary of
        Just res ->
            case res of
                Ok r ->
                    a [ href <| "/recipe/" ++ r.id ]
                        [ div [ class "ui fluid card", style [ ( "margin-bottom", "15px" ) ] ]
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

                Err r ->
                    div [] [ text ("ruh rohr, you has err: " ++ (toString r)) ]

        Nothing ->
            viewLoading


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


viewLoading : Html Msg
viewLoading =
    div
        [ class "ui massive active text centered inline loader" ]
        [ text "Loading" ]
