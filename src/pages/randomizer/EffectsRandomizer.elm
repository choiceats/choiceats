module EffectsRandomizer exposing (..)

-- ELM-LANG MODULES
import Http

-- THIRD PARTY MODULES
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Client.Http as GraphQLClient
import Task exposing (Task)

-- APPLICATION MODULES
import TypesRandomizer as TR exposing (..)

recipeRequest : GqlB.Document GqlB.Query TR.RecipeSummary { vars | searchFilter: String }
recipeRequest =
  let
    searchFilterVar =
      Var.required "searchFilter" .searchFilter Var.string

    recSumFoo =
      GqlB.object TR.RecipeSummary
        |> GqlB.with (GqlB.field "author"      [] GqlB.string)
        |> GqlB.with (GqlB.field "authorId"    [] GqlB.string)
        |> GqlB.with (GqlB.field "description" [] GqlB.string)
        |> GqlB.with (GqlB.field "id"          [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl"    [] GqlB.string)
        |> GqlB.with (GqlB.field "likes"       [] GqlB.int)
        |> GqlB.with (GqlB.field "name"        [] GqlB.string)
        |> GqlB.with (GqlB.field "youLike"     [] GqlB.bool)

    queryRoot =
      GqlB.extract
        (GqlB.field "randomRecipe"
          [ ("searchFilter", Arg.variable searchFilterVar ) ]
          recSumFoo
        )
  in
      GqlB.queryDocument queryRoot

requestOptions token =
  { method          = "POST"
  , headers         = [(Http.header "Authorization" ("Bearer " ++ token))]
  , url             = "http://localhost:4000/graphql/"
  , timeout         = Nothing
  , withCredentials = False -- value of True makes CORS active, breaking the request
  }

recipeQueryRequest : TR.ButtonFilter -> GqlB.Request GqlB.Query TR.RecipeSummary
recipeQueryRequest buttonFilter =
  recipeRequest
    |> GqlB.request { searchFilter = (TR.mapFilterTypeToString buttonFilter)}

type alias AuthToken = String

sendQueryRequest : AuthToken -> GqlB.Request GqlB.Query a -> Task GraphQLClient.Error a
sendQueryRequest authToken request =
    GraphQLClient.customSendQuery (requestOptions authToken) request

sendRecipeQuery : AuthToken -> TR.ButtonFilter -> Cmd Msg
sendRecipeQuery authToken buttonFilter =
    sendQueryRequest authToken (recipeQueryRequest buttonFilter )
        |> Task.attempt TR.ReceiveQueryResponse
