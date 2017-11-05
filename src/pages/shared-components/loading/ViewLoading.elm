module ViewLoading exposing (viewLoading)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import TypesRandomizer as TR exposing (..)

viewLoading : Html TR.Msg
viewLoading =
  div
  [class "ui massive active text centered inline loader"]
  [text "Loading"]
