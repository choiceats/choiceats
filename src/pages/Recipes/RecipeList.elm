port module Recipes.RecipeList exposing (recipeListView)

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)
import List exposing (map)
import Recipes.Recipe exposing (recipeCard)
import Recipes.Types exposing (..)
import Recipes.RecipeList_Effects as Effects exposing (sendRecipesQuery)


recipeListView : Model -> Html RecipeMsg
recipeListView model =
    let
        recipeCards =
            case model.recipes of
                Just res ->
                    case res of
                        Ok r ->
                            (map recipeCard r)

                        Err r ->
                            [ text ("ERROR: " ++ (toString r)) ]

                Nothing ->
                    [ text "no recipes" ]
    in
        div [ class "list" ]
            recipeCards
