port module Recipes.RecipeSearch exposing (main)

import Html exposing (Html, div, input, text, a, img, i, option, select)
import Html.Attributes exposing (class, style, href, src, placeholder, value)
import Html.Events exposing (onInput)
import List exposing (map)
import Recipes.Types exposing (..)
import Recipes.Recipe exposing (recipeCard)
import Recipes.Types exposing (..)
import Recipes.Recipe_Effects as Effects exposing (sendRecipesQuery)


type alias SearchParams =
    { text : String
    , tags : List String
    , filter : SearchFilter
    }


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
    , search : SearchParams
    }


initialFilterType : SearchFilter
initialFilterType =
    All


defaultSearchParams : SearchParams
defaultSearchParams =
    { text = ""
    , tags = []
    , filter = All
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

        SearchTextChange text ->
            let
                searchParams =
                    model.search

                updatedSearchParms =
                    { searchParams | text = text }

                command =
                    sendRecipesQuery model.token updatedSearchParms.filter updatedSearchParms.tags updatedSearchParms.text
            in
                ( { model | search = updatedSearchParms }, command )

        SearchFilterChange filter ->
            -- TODO: This is very simular to the SearchTextChange,
            -- I wonder how we can best refactor this?
            let
                searchParams =
                    model.search

                updatedSearchParms =
                    { searchParams | filter = filter }

                command =
                    sendRecipesQuery model.token updatedSearchParms.filter updatedSearchParms.tags updatedSearchParms.text
            in
                ( { model | search = updatedSearchParms }, command )


init : Flags -> ( Model, Cmd RecipeMsg )
init flags =
    ( { recipes = Nothing
      , isLoggedIn = flags.isLoggedIn
      , userId = toString flags.userId
      , token = flags.token
      , search = defaultSearchParams
      }
    , sendRecipesQuery flags.token initialFilterType [] "he"
    )


filterOption filter =
    option [ value (toString filter) ] [ text (toString filter) ]


filterOptions =
    List.map
        filterOption
        [ All, Fav, My ]


view : Model -> Html RecipeMsg
view model =
    div [ class "search" ]
        [ searchBar model.search
        , recipeListView model.recipes
        ]


searchBar : SearchParams -> Html RecipeMsg
searchBar searchParams =
    div [ class "searchBar" ]
        [ input
            [ placeholder "Search Title or Ingredents", onInput SearchTextChange ]
            []
        , select
            [ onInput onFilterChange ]
            filterOptions
        ]


onFilterChange filter =
    case filter of
        "My" ->
            SearchFilterChange My

        "All" ->
            SearchFilterChange All

        "Fav" ->
            SearchFilterChange Fav

        _ ->
            SearchFilterChange All


recipeListView : Maybe Recipes.Types.RecipesResponse -> Html RecipeMsg
recipeListView recipes =
    let
        recipeCards =
            case recipes of
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
