module Recipes.RecipeList_Effects exposing (..)

-- ELM-LANG MODULES

import Http


-- THIRD PARTY MODULES

import GraphQL.Request.Builder as GqlB
import GraphQL.Client.Http as GraphQLClient
import Task exposing (Task)


-- APPLICATION MODULES

import Recipes.Types exposing (..)


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


requestOptions token =
    { method = "POST"
    , headers = [ (Http.header "Authorization" ("Bearer " ++ token)) ]
    , url = "http://localhost:4000/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }


tagsQueryRequest : ButtonFilter -> List String -> String -> GqlB.Request GqlB.Query (List RecipeTag)
tagsQueryRequest buttonFilter tags searchText =
    tagsRequest
        |> GqlB.request {}


type alias AuthToken =
    String


sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request


sendRecipesQuery : AuthToken -> ButtonFilter -> List String -> String -> Cmd RecipeMsg
sendRecipesQuery authToken buttonFilter tags searchText =
    sendQueryRequest authToken (tagsQueryRequest buttonFilter tags searchText)
        |> Task.attempt GetTagsResponse
