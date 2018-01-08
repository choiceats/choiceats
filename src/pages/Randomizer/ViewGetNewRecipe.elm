module ViewGetNewRecipe exposing (viewGetNewRecipe)

-- BUILTIN CODE
import Html exposing (Html, div, a, button, text)
import Html.Attributes exposing (type_, style, class)
import Html.Events exposing (onClick)

-- APPLICATION CODE
import Randomizer.Types as T exposing (..)

viewGetNewRecipe : T.Model -> Html T.Msg
viewGetNewRecipe model =
  div
  [ style
    [ ("width", "100%")
    , ("text-align", "center")
    , ("margin-top", "15px")
    ]
  ]
  [ button
    [ type_ "submit"
    , class "ui primary button"
    , onClick T.RequestRecipe
    ]
    [text "NEW IDEA!"]
  ]
