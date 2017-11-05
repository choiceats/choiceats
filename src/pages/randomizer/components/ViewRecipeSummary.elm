module ViewRecipeSummary exposing (viewRecipeSummary)

-- ELM-LANG MODULES
import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)

-- APPLICATION MODULES
import TypesRandomizer as TR exposing (..)
import ViewLoading exposing (viewLoading)

recipeDescription = ""

viewRecipeSummary : Maybe RecipeResponse -> Html TR.Msg
viewRecipeSummary mRecipeSummary =
  case mRecipeSummary of
    (Just res) ->
      case res of
        (Ok r) -> 
          a [href <| "/recipe/" ++ r.id]
          [ div [class "ui fluid card", style [("margin-bottom", "15px")]]
            [ img [class "ui image", src r.imageUrl] []
            , div [class "content"]
              [ div [class "header"] [text r.name]
              , div [class "meta"] [text r.author]
              , div [class "meta"]
                [ i [class <| if r.youLike then "green" else "grey" ++ " favorite large icon"] []
                , text <| toString r.likes
                ]
              ]
            , div [class "description"] [ text recipeDescription ]
            ]
          ]
        (Err r) -> div [] [text ("ruh roh, you has err: " ++ (toString r))]

    (Nothing) -> viewLoading
