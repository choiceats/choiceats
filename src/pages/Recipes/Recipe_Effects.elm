module Recipes.Recipe_Effects exposing (..)

-- ELM-LANG MODULES

import Http


-- THIRD PARTY MODULES

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Task exposing (Task)


-- APPLICATION MODULES

import Recipes.Types exposing (..)


type alias AuthToken =
    String



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
    GraphQLClient.customSendQuery (requestOptions authToken) request


sendRecipesQuery : AuthToken -> SearchFilter -> List String -> String -> Cmd RecipeMsg
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


sendTagsQuery : AuthToken -> SearchFilter -> List String -> String -> Cmd RecipeMsg
sendTagsQuery authToken searchFilter tags searchText =
    sendQueryRequest authToken (tagsQueryRequest searchFilter tags searchText)
        |> Task.attempt GetTagsResponse
