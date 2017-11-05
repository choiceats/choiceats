port module Randomizer exposing (..)

-- ELM-LANG MODULES
import Html exposing (Html, div, text)
import Html.Events exposing (onClick)
import Json.Decode exposing (decodeString, int, string, field, bool)
import Json.Encode exposing (encode, object)
import Result exposing (withDefault)
import String exposing (toInt)
import Time exposing (Time, hour)

-- APPLICATION MODULES
import ViewFilterButtons exposing (viewFilterButtons)
import ViewGetNewRecipe exposing (viewGetNewRecipe)
import ViewNotFound exposing (viewNotFound)
import ViewRecipeSummary exposing (viewRecipeSummary)

import TypesRandomizer as TR exposing (..)

import EffectsRandomizer as Effects exposing (sendRecipeQuery)


main =
  Html.programWithFlags
  { update = update
  , view = viewAll
  , init = init
  , subscriptions = subscriptions
  }

initialFilterType : TR.ButtonFilter
initialFilterType = TR.All

init : TR.Flags -> (Model, Cmd TR.Msg)
init initFlags = 
  ({ currentFilter = initialFilterType
  , mRecipeSummary = Nothing
  , flags = initFlags
  }, sendRecipeQuery initFlags.token initialFilterType)


update : TR.Msg -> TR.Model -> (TR.Model, Cmd TR.Msg)
update msg model = 
  case msg of

    TR.NoOp ->
      (model, Cmd.none)

    TR.Tick newTime ->
      (model, Cmd.none)

    TR.RequestRecipe ->
      (model, sendRecipeQuery model.flags.token model.currentFilter)

    TR.SetFilterType msg ->
      ({ model | currentFilter = msg }, Cmd.none)

    (TR.ReceiveQueryResponse res) ->
      ({ model | mRecipeSummary = Just res }, Cmd.none)

subscriptions : TR.Model -> Sub TR.Msg
subscriptions model =
  Sub.none

viewAll : TR.Model -> Html TR.Msg
viewAll model = div []
  [ viewFilterButtons model
  , viewRecipeSummary model.mRecipeSummary
  , viewGetNewRecipe model
  , div [] [ text model.flags.token ]
  ]

-- GOOD
-- Apollo GraphQL looks like this

-- "query RandomRecipe($searchFilter: String) {
--   randomRecipe(searchFilter: $searchFilter) {
--     id
--     author
--     authorId
--     description
--     imageUrl
--     name
--     likes
--     youLike
--     __typename
--   }
-- }
-- "

-- BAD
-- My elm-graphql usage so far looks like this, but it gets the data back :)

-- "query ($searchFilter: String!) {
--   author(searchFilter: $searchFilter) {
--     author
--     authorId
--     description
--     id
--     imageUrl
--     likes
--     name
--     youLike
--   }
-- }"

-- This is what we used to generate the query.
-- query NAME does not seem super specific to apollo

-- const recipeQuery = gql`
--   query RandomRecipe($searchFilter: String) {
--     randomRecipe(searchFilter: $searchFilter) {
--       id
--       author
--       authorId
--       description
--       imageUrl
--       name
--       likes
--       youLike
--     }
--   }
-- `
