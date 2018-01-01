port module Recipes.RecipeList exposing (main)

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)
import List exposing (map)
import Recipes.Recipe exposing (recipeCard)
import Recipes.Types exposing (..)
import Recipes.RecipeList_Effects as Effects exposing (sendRecipesQuery)


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


main : Program Flags Model RecipeMsg
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


init : Flags -> ( Model, Cmd RecipeMsg )
init flags =
    ( { recipes = Nothing
      , isLoggedIn = flags.isLoggedIn
      , userId = flags.userId
      , token = flags.token
      }
    , sendRecipesQuery flags.token initialFilterType [] "he"
    )


view : Model -> Html RecipeMsg
view model =
    -- TODO: We ended here, using the Maybe type
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
