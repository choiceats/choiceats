port module RecipeElm exposing (main)

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)

type Msg = NoOp

recipeImageUrl    = "/"
recipeLink        = "/recipe/2800"
recipeTitle       = "Chocolate Crinkle Cookies"
recipeAuthor      = "samashby"
recipeLikes       = "36 likes"
recipeDescription = ""

main : Html Msg
main =
  a [href recipeLink]
  [ div [class "ui fluid card", style [("margin-bottom", "15px")]]
    [ img [class "ui image", src "/"] []
    , div [class "content"]
      [ div [class "header"] [text recipeTitle]
      , div [class "meta"] [text recipeAuthor]
      , div [class "meta"]
        [ i [class "grey favorite large icon"] []
        , text recipeLikes
        ]
      ]
    , div [class "description"] [ text recipeDescription ]
    ]
  ]
