module ViewGetNewRecipe exposing (viewGetNewRecipe)

-- BUILTIN CODE
import Html exposing (Html, div, a, button, text)
import Html.Attributes exposing (type_, style, class)
import Html.Events exposing (onClick)

-- APPLICATION CODE
import TypesRandomizer as TR exposing (..)
--import Randomizer exposing (sendRecipeQuery)

viewGetNewRecipe : TR.Model -> Html TR.Msg
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
    , onClick TR.RequestRecipe
    ]
    [text "NEW IDEA!"]
  ]
