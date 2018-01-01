module Recipes.Recipe exposing (recipeCard)

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)
import Recipes.Types exposing (..)


recipeCard : Recipes.Types.RecipeSummary -> Html RecipeMsg
recipeCard recipe =
    a [ href ("/recipe/" ++ recipe.id) ]
        [ div [ class "ui fluid card", style [ ( "margin-bottom", "15px" ) ] ]
            [ img [ class "ui image", src "/" ] []
            , div [ class "content" ]
                [ div [ class "header" ] [ text recipe.name ]
                , div [ class "meta" ] [ text recipe.author ]
                , div [ class "meta" ]
                    [ i [ class "grey favorite large icon" ] []
                    , text (toString recipe.likes)
                    ]
                ]
            , div [ class "description" ] [ text recipe.description ]
            ]
        ]
