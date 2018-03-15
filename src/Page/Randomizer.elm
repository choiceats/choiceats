module Page.Randomizer exposing (ExternalMsg(..), Model, Msg, update, view, init)

-- ELM-LANG MODULES

import Data.User exposing (User)
import Data.AuthToken as AuthToken exposing (AuthToken, getTokenString, blankToken)
import Html exposing (Html, div, a, text, label, input, button, h1, form, img, i)
import Html.Attributes exposing (disabled, type_, class, style, value, for, id, href, src)
import Html.Events exposing (onWithOptions, onClick, onInput)
import Http exposing (Error, send, post, stringBody)
import Json.Decode as JD exposing (bool, decodeString, field, int, map4, string)
import Json.Encode as JE exposing (object, string, encode)
import Data.Session exposing (Session)
import Data.User exposing (User, decoder)
import Route exposing (Route)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Client.Http as GraphQLClient
import Task exposing (Task)
import Result exposing (withDefault)


-- type Msg = ReceiveResponse (Result Http.Error User)
-- commented Msg type from Signup.elm


type Msg
    = RequestRecipe
    | SetFilterType ButtonFilter
    | ReceiveQueryResponse RecipeResponse


type alias RecipeResponse =
    Result GraphQLClient.Error RecipeSummary


type ExternalMsg
    = NoOp



-- Types.elm --


type ButtonFilter
    = My
    | Fav
    | All


type alias RecipeSummary =
    { author : String
    , authorId : String
    , description : String
    , id : String
    , imageUrl : String
    , likes : List Int
    , name : String
    , youLike : Bool
    }


type alias Model =
    { currentFilter : ButtonFilter
    , mRecipeSummary : Maybe RecipeResponse
    , token : AuthToken
    }


type alias Flags =
    { token : String }


mapFilterTypeToString : ButtonFilter -> String
mapFilterTypeToString filterType =
    case filterType of
        My ->
            "my"

        Fav ->
            "fav"

        All ->
            "all"


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
        , sendRecipeQuery (getTokenString authToken) All
          -- TODO figure out how to pattern match the auth token
        )



-- getRequestToken : AuthToken -> String
-- getRequestToken token =
--     case token of
--         AuthToken token ->
--             token


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        RequestRecipe ->
            ( ( model, sendRecipeQuery (getTokenString model.token) model.currentFilter ), NoOp )

        SetFilterType msg ->
            ( ( { model | currentFilter = msg }, Cmd.none ), NoOp )

        ReceiveQueryResponse res ->
            ( ( { model | mRecipeSummary = Just res }, Cmd.none ), NoOp )


view : Session -> Model -> Html Msg
view session model =
    div []
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

        recSumFoo =
            GqlB.object RecipeSummary
                |> GqlB.with (GqlB.field "author" [] GqlB.string)
                |> GqlB.with (GqlB.field "authorId" [] GqlB.string)
                |> GqlB.with (GqlB.field "description" [] GqlB.string)
                |> GqlB.with (GqlB.field "id" [] GqlB.string)
                |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
                |> GqlB.with (GqlB.field "likes" [] (GqlB.list GqlB.int))
                |> GqlB.with (GqlB.field "name" [] GqlB.string)
                |> GqlB.with (GqlB.field "youLike" [] GqlB.bool)

        queryRoot =
            GqlB.extract
                (GqlB.field "randomRecipe"
                    [ ( "searchFilter", Arg.variable searchFilterVar ) ]
                    recSumFoo
                )
    in
        GqlB.queryDocument queryRoot


requestOptions token =
    { method = "POST"
    , headers = [ (Http.header "Authorization" ("Bearer " ++ token)) ]
    , url = "http://localhost:4000/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }


recipeQueryRequest : ButtonFilter -> GqlB.Request GqlB.Query RecipeSummary
recipeQueryRequest buttonFilter =
    recipeRequest
        |> GqlB.request { searchFilter = (mapFilterTypeToString buttonFilter) }


sendQueryRequest : String -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request


sendRecipeQuery : String -> ButtonFilter -> Cmd Msg
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


filterButton : ButtonFilter -> ButtonFilter -> Html Msg
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
