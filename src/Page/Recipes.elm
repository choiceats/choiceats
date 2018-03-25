module Page.Recipes exposing (ExternalMsg(..), Model, Msg, update, view, init)

import Array exposing (Array)
import Html exposing (Html, a, div, i, img, text, input, option, select)
import Html.Attributes exposing (class, style, href, src, placeholder, value)
import Html.Events exposing (onInput)
import Http
import List exposing (map)
import Util exposing (getImageUrl)
import Task exposing (Task)


-- THIRD PARTY MODULES

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Route as Route exposing (Route(..), href)
import Data.Recipe
    exposing
        ( SearchFilter(..)
        , mapFilterTypeToString
        , RecipeSummary
        , RecipesResponse
        , TagsResponse
        , RecipeTag
        , Slug(..)
        )


-- APPLICATION MODULES

import Data.AuthToken as AuthToken exposing (AuthToken, getTokenString, blankToken)
import Data.Session exposing (Session)
import Data.User exposing (User, UserId, decoder)


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
    let
        noImage =
            String.isEmpty recipe.imageUrl

        mImg =
            if noImage then
                (text "")
            else
                img [ class "ui image", src (getImageUrl recipe.imageUrl) ] []
    in
        a [ class "recipe-card", Route.href (RecipeDetail (Slug recipe.id)) ]
            [ div [ class "ui fluid card", style [ ( "margin-bottom", "15px" ) ] ]
                [ mImg
                , div [ class "content" ]
                    [ div [ class "header" ] [ text recipe.name ]
                    , div [ class "meta" ] [ text recipe.author ]
                    , div [ class "meta" ]
                        [ i [ class "grey favorite large icon" ] []
                        , text (getLikesText recipe.likes)
                        ]
                    ]
                , div [ class "description" ] [ text recipe.description ]
                ]
            ]


getLikesText likes =
    let
        numberLikes =
            List.length likes

        pluralize =
            if numberLikes == 1 then
                ""
            else
                "s"

        text =
            if numberLikes == 0 then
                "Be the first to like this"
            else
                ((toString numberLikes) ++ " like" ++ pluralize)
    in
        text


type alias SearchParams =
    { text : String
    , tags : List String
    , filter : SearchFilter
    }


type alias Model =
    { recipes : Maybe RecipesResponse
    , userId : String
    , token : AuthToken
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
            ( (updateSearch msg model), NoOp )


updateSearch msg model =
    case msg of
        SearchTextChange text ->
            let
                searchParams =
                    model.search

                updatedSearchParms =
                    { searchParams | text = text }

                command =
                    sendRecipesQuery model.token updatedSearchParms.filter updatedSearchParms.tags updatedSearchParms.text
            in
                ( { model | search = updatedSearchParms }, command )

        SearchFilterChange filter ->
            -- TODO: This is very simular to the SearchTextChange,
            -- I wonder how we can best refactor this?
            let
                searchParams =
                    model.search

                updatedSearchParms =
                    { searchParams | filter = filter }

                command =
                    sendRecipesQuery model.token updatedSearchParms.filter updatedSearchParms.tags updatedSearchParms.text
            in
                ( { model | search = updatedSearchParms }, command )

        _ ->
            ( model, Cmd.none )


init : Session -> ( Model, Cmd Msg )
init session =
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

          {- toString userId -}
          , token = authToken
          , search = defaultSearchParams
          }
        , sendRecipesQuery authToken All [] "he"
        )


filterOption filter =
    option [ value (toString filter) ] [ text (toString filter) ]


filterOptions =
    List.map
        filterOption
        [ All, Fav, My ]


view : Session -> Model -> Html Msg
view session model =
    div [ class "search" ]
        [ searchBar model.search
        , recipeListView model.recipes
        ]


searchBar : SearchParams -> Html Msg
searchBar searchParams =
    div [ class "searchBar" ]
        [ input
            [ placeholder "Search Title or Ingredents", onInput SearchTextChange ]
            []
        , select
            [ onInput onFilterChange ]
            filterOptions
        , a
            [ Route.href NewRecipe ]
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
                            (map recipeCard r)

                        Err r ->
                            [ text ("ERROR: " ++ (toString r)) ]

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

        recSumFoo =
            GqlB.list
                (GqlB.object RecipeSummary
                    |> GqlB.with (GqlB.field "author" [] GqlB.string)
                    |> GqlB.with (GqlB.field "authorId" [] GqlB.string)
                    |> GqlB.with (GqlB.field "description" [] GqlB.string)
                    |> GqlB.with (GqlB.field "id" [] GqlB.string)
                    |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
                    |> GqlB.with (GqlB.field "likes" [] (GqlB.list GqlB.int))
                    |> GqlB.with (GqlB.field "name" [] GqlB.string)
                    |> GqlB.with (GqlB.field "youLike" [] GqlB.bool)
                )

        queryRoot =
            GqlB.extract
                (GqlB.field "recipes"
                    [ ( "searchFilter", Arg.variable searchFilterVar )
                    , ( "searchTags", Arg.variable searchTags )
                    , ( "searchText", Arg.variable searchText )
                    ]
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


recipesQueryRequest : SearchFilter -> List String -> String -> GqlB.Request GqlB.Query (List RecipeSummary)
recipesQueryRequest searchFilter tags searchText =
    recipesRequest
        |> GqlB.request
            { searchFilter = (mapFilterTypeToString searchFilter)
            , tags = tags
            , searchText = searchText
            }


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions (getTokenString authToken)) request


sendRecipesQuery : AuthToken -> SearchFilter -> List String -> String -> Cmd Msg
sendRecipesQuery authToken searchFilter tags searchText =
    sendQueryRequest authToken (recipesQueryRequest searchFilter tags searchText)
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


sendTagsQuery : AuthToken -> SearchFilter -> List String -> String -> Cmd Msg
sendTagsQuery authToken searchFilter tags searchText =
    sendQueryRequest authToken (tagsQueryRequest searchFilter tags searchText)
        |> Task.attempt GetTagsResponse
