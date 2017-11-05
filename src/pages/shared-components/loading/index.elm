port module LoadingElm exposing (main)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Time exposing (Time, hour)


main =
  Html.program
  { update = update
  , view = view
  , init = init
  , subscriptions = subscriptions
  }


type alias Model = Int

init : (Model, Cmd Msg)
init = 
  (0, Cmd.none)

type Msg = NoOp | Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    NoOp ->
      (model, Cmd.none)

    Tick newTime ->
      (model, Cmd.none)

view : Model -> Html Msg
view model =
  div
  [class "ui massive active text centered inline loader"]
  [text "Loading"]

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every hour Tick
