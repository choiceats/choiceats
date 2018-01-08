port module Randomizer exposing (..)

-- ELM-LANG MODULES

import Html exposing (Html, div, text)
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
import Randomizer.Types as T exposing (..)
import Randomizer.Effects as Effects exposing (sendRecipeQuery)


main =
    Html.programWithFlags
        { update = update
        , view = viewAll
        , init = init
        , subscriptions = subscriptions
        }


initialFilterType : T.ButtonFilter
initialFilterType =
    T.All


init : T.Flags -> ( T.Model, Cmd T.Msg )
init initFlags =
    ( { currentFilter = initialFilterType
      , mRecipeSummary = Nothing
      , flags = initFlags
      }
    , sendRecipeQuery initFlags.token initialFilterType
    )


update : T.Msg -> T.Model -> ( T.Model, Cmd T.Msg )
update msg model =
    case msg of
        T.NoOp ->
            ( model, Cmd.none )

        T.Tick newTime ->
            ( model, Cmd.none )

        T.RequestRecipe ->
            ( model, sendRecipeQuery model.flags.token model.currentFilter )

        T.SetFilterType msg ->
            ( { model | currentFilter = msg }, Cmd.none )

        T.ReceiveQueryResponse res ->
            ( { model | mRecipeSummary = Just res }, Cmd.none )


subscriptions : T.Model -> Sub T.Msg
subscriptions model =
    Sub.none


viewAll : T.Model -> Html T.Msg
viewAll model =
    div []
        [ viewFilterButtons model
        , viewRecipeSummary model.mRecipeSummary
        , viewGetNewRecipe model
        ]
