module Page.Recipes exposing (ExternalMsg(..), Model, Msg, init, update, view)

-- ELM-LANG MODULES --
-- THIRD PARTY MODULES
-- APPLICATION MODULES

import Data.AuthToken as AuthToken exposing (AuthToken, blankToken, getTokenString)
import Data.Recipe
    exposing
        ( RecipeSummary
        , RecipeTag
        , RecipesResponse
        , SearchFilter(..)
        , Slug(..)
        , TagsResponse
        , gqlRecipeSummary
        , mapFilterTypeToString
        , requestOptions
        )
import Data.Session exposing (Session)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (Html, a, div, i, img, input, option, select, span, text)
import Html.Attributes exposing (class, href, placeholder, src, style, value)
import Html.Events exposing (onInput)
import Http
import List exposing (map)
import Route as Route exposing (Route(..), href)
import Task exposing (Task)
import Util
    exposing
        ( getImageUrl
        , getSummaryLikesText
        , graphQlErrorToString
        )


type ExternalMsg
    = NoOp


type Msg
    = GetRecipes
    | GetRecipesResponse RecipesResponse
    | GetTagsResponse TagsResponse
    | SearchTextChange String
    | SearchFilterChange SearchFilter


recipeCard : RecipeSummary -> Html Msg
recipeCard recipe =
    a [ class "recipe-card", Route.href (RecipeDetail (Slug recipe.id)) ]
        [ div [ class "ui fluid card", style "margin-bottom" "15px" ]
            [ recipeImage recipe.imageUrl
            , div [ class "content" ]
                [ div [ class "header" ] [ text recipe.name ]
                , div [ class "meta" ] [ text recipe.author ]
                , div
                    [ class "meta recipe-summary__likes" ]
                    [ i
                        [ class <|
                            "favorite large icon "
                                ++ (if recipe.youLike then
                                        "teal"

                                    else
                                        "grey"
                                   )
                        ]
                        []
                    , span [ class "recipe-summary__likes-count" ] [ text (getSummaryLikesText (List.length recipe.likes) recipe.youLike) ]
                    ]
                , div [ class "description" ] [ text recipe.description ]
                ]
            ]
        ]


recipeImage : String -> Html Msg
recipeImage url =
    let
        noImage =
            String.isEmpty url
    in
    if noImage then
        text ""

    else
        img [ class "ui image", src (getImageUrl url) ] []


type alias SearchParams =
    { text : String
    , tags : List String
    , filter : SearchFilter
    }


type alias Model =
    { recipes : Maybe RecipesResponse
    , userId : String
    , token : AuthToken
    , apiUrl : String
    , search : SearchParams
    }


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        GetRecipesResponse recipesRes ->
            ( ( { model | recipes = Just recipesRes }, Cmd.none ), NoOp )

        GetRecipes ->
            ( ( model, Cmd.none ), NoOp )

        GetTagsResponse tagRes ->
            ( ( model, Cmd.none ), NoOp )

        _ ->
            ( updateSearch msg model, NoOp )


updateSearch msg model =
    let
        oldSearch =
            model.search

        ( newParams, command ) =
            case msg of
                SearchTextChange text ->
                    ( { oldSearch | text = text }
                    , sendRecipesQuery model.token oldSearch.filter oldSearch.tags text model.apiUrl
                    )

                SearchFilterChange filter ->
                    ( { oldSearch | filter = filter }
                    , sendRecipesQuery model.token filter oldSearch.tags oldSearch.text model.apiUrl
                    )

                _ ->
                    ( model.search, Cmd.none )
    in
    ( { model | search = newParams }, command )


init : Session -> String -> ( Model, Cmd Msg )
init session apiUrl =
    let
        authToken =
            case session.user of
                Nothing ->
                    blankToken

                Just user ->
                    user.token

        defaultSearchParams =
            { text = ""
            , tags = []
            , filter = All
            }
    in
    ( { recipes = Nothing
      , userId = ""
      , token = authToken
      , apiUrl = apiUrl
      , search = defaultSearchParams
      }
    , sendRecipesQuery authToken All [] "he" apiUrl
    )


filterOption filter =
    option [ value (mapFilterTypeToString filter) ] [ text (mapFilterTypeToString filter) ]


filterOptions =
    List.map
        filterOption
        [ All, Fav, My ]


view : Session -> Model -> Html Msg
view session model =
    div [ class "ui container search" ]
        [ searchBar model.search
        , recipeListView model.recipes
        ]


searchBar : SearchParams -> Html Msg
searchBar searchParams =
    div [ class "searchBar" ]
        [ div [ class "ui input" ]
            [ input [ placeholder "Search Title or Ingredents", onInput SearchTextChange ]
                []
            ]
        , select
            [ onInput onFilterChange, class "ui dropdown searchBar__filter" ]
            filterOptions
        , a
            [ Route.href NewRecipe, class "ui primary basic button" ]
            [ text "New Recipe" ]
        ]


onFilterChange filter =
    case filter of
        "My" ->
            SearchFilterChange My

        "All" ->
            SearchFilterChange All

        "Fav" ->
            SearchFilterChange Fav

        _ ->
            SearchFilterChange All


recipeListView : Maybe RecipesResponse -> Html Msg
recipeListView recipes =
    let
        recipeCards =
            case recipes of
                Just res ->
                    case res of
                        Ok r ->
                            map recipeCard r

                        Err err ->
                            [ text (graphQlErrorToString err) ]

                Nothing ->
                    [ text "no recipes" ]
    in
    div [ class "list" ]
        recipeCards



-- Recipe Graphql Requests


recipesRequest : GqlB.Document GqlB.Query (List RecipeSummary) { vars | searchFilter : String, tags : List String, searchText : String }
recipesRequest =
    let
        searchFilterVar =
            Var.required "searchFilter" .searchFilter Var.string

        searchTags =
            Var.required "searchTags" .tags (Var.list Var.string)

        searchText =
            Var.required "searchText" .searchText Var.string

        queryRoot =
            GqlB.extract
                (GqlB.field "recipes"
                    [ ( "searchFilter", Arg.variable searchFilterVar )
                    , ( "searchTags", Arg.variable searchTags )
                    , ( "searchText", Arg.variable searchText )
                    ]
                    (GqlB.list gqlRecipeSummary)
                )
    in
    GqlB.queryDocument queryRoot


recipesQueryRequest : SearchFilter -> List String -> String -> GqlB.Request GqlB.Query (List RecipeSummary)
recipesQueryRequest searchFilter tags searchText =
    recipesRequest
        |> GqlB.request
            { searchFilter = mapFilterTypeToString searchFilter
            , tags = tags
            , searchText = searchText
            }


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> String -> Task GraphQLClient.Error a
sendQueryRequest authToken request apiUrl =
    GraphQLClient.customSendQuery (requestOptions authToken apiUrl) request


sendRecipesQuery : AuthToken -> SearchFilter -> List String -> String -> String -> Cmd Msg
sendRecipesQuery authToken searchFilter tags searchText apiUrl =
    sendQueryRequest authToken (recipesQueryRequest searchFilter tags searchText) apiUrl
        |> Task.attempt GetRecipesResponse


tagsRequest : GqlB.Document GqlB.Query (List RecipeTag) {}
tagsRequest =
    let
        tagDescriptor =
            GqlB.list
                (GqlB.object RecipeTag
                    |> GqlB.with (GqlB.field "id" [] GqlB.string)
                    |> GqlB.with (GqlB.field "name" [] GqlB.string)
                )

        queryRoot =
            GqlB.extract
                (GqlB.field "tags" [] tagDescriptor)
    in
    GqlB.queryDocument queryRoot


tagsQueryRequest : SearchFilter -> List String -> String -> GqlB.Request GqlB.Query (List RecipeTag)
tagsQueryRequest searchFilter tags searchText =
    tagsRequest
        |> GqlB.request {}


sendTagsQuery : AuthToken -> SearchFilter -> List String -> String -> String -> Cmd Msg
sendTagsQuery authToken searchFilter tags searchText apiUrl =
    sendQueryRequest authToken (tagsQueryRequest searchFilter tags searchText) apiUrl
        |> Task.attempt GetTagsResponse
