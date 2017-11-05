port module ElmButton exposing (main)

import Html exposing (Html, a, button, text)
import Html.Attributes exposing (type_, class)
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
  button [type_ "submit", class "ui primary button" ] [text "Login"]

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every hour Tick
