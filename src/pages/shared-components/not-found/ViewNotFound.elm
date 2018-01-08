module ViewNotFound exposing (viewNotFound)

import Html exposing (Html, div, img, text)
import Html.Attributes exposing (style, src)

import Randomizer.Types as T exposing (..)

viewNotFound : Html T.Msg
viewNotFound =
  div
  [ style [ ("max-width", "100%")
          , ("margin", "0 auto")
          , ("text-align", "center")
          ]
  ]
  [
    img
    [ src "http://hrwiki.org/w/images/0/03/404.PNG"
    , style [("max-width", "100%")]
    ] []
  ]
