port module Recipes.RecipeSearch exposing (main)

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)
import List exposing (map)
import Recipes.Types exposing (..)
import Recipes.Recipe exposing (recipeCard)
import Recipes.Types exposing (..)
import Recipes.Recipe_Effects as Effects exposing (sendRecipesQuery)


initialFilterType : ButtonFilter
initialFilterType =
    All


type alias Flags =
    { userId : String
    , isLoggedIn : Bool
    , token : String
    }


type alias Model =
    { recipes : Maybe Recipes.Types.RecipesResponse
    , userId : String
    , isLoggedIn : Bool
    , token : String
    }


main =
    Html.programWithFlags
        { update = update
        , view = view
        , init = init
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub RecipeMsg
subscriptions model =
    Sub.none


update : RecipeMsg -> Model -> ( Model, Cmd RecipeMsg )
update recipeMsg model =
    case recipeMsg of
        GetRecipesResponse recipesRes ->
            ( { model | recipes = Just recipesRes }, Cmd.none )

        GetRecipes ->
            ( model, Cmd.none )

        GetTagsResponse tagRes ->
            ( model, Cmd.none )


init : Flags -> ( Model, Cmd RecipeMsg )
init flags =
    ( { recipes = Nothing
      , isLoggedIn = flags.isLoggedIn
      , userId = toString flags.userId
      , token = flags.token
      }
    , sendRecipesQuery flags.token initialFilterType [] "he"
    )



-- The below code will work with elm-reactor if you find your access_token in postgres
-- init : ( Model, Cmd RecipeMsg )
-- init =
--     ( { recipes = Nothing
--       , isLoggedIn = True
--       , userId = "1"
--       , token = "nyfehfnz1uemy31zdg7528tazsfle6p"
--       }
--     , sendRecipesQuery "nyfehfnz1uemy31zdg7528tazsfle6p" initialFilterType [] "he"
--     )


view : Model -> Html RecipeMsg
view model =
    div [ class "search" ]
        [ recipeListView model ]


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
