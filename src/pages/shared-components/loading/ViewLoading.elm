module ViewLoading exposing (viewLoading)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Randomizer.Types as T exposing (..)

viewLoading : Html T.Msg
viewLoading =
  div
  [class "ui massive active text centered inline loader"]
  [text "Loading"]
