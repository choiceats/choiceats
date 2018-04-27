module Route exposing (Route(..), fromLocation, href, modifyUrl, routeToTitle)

-- ELM-LANG MODULES --

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)


-- THIRD PARTY MODULES --

import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- APPLICATION MODULES --

import Data.Recipe as Recipe


type Route
    = Root
    | Login
    | Logout
    | Signup
    | Randomizer
    | Recipes
    | NewRecipe
    | RecipeDetail Recipe.Slug
    | EditRecipe Recipe.Slug


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Login (s "login")
        , Url.map Logout (s "logout")
        , Url.map Signup (s "signup")
        , Url.map Randomizer (s "random")
        , Url.map Recipes (s "recipes")
        , Url.map NewRecipe (s "recipe" </> s "new")
        , Url.map RecipeDetail (s "recipe" </> Recipe.slugParser)
        , Url.map EditRecipe (s "recipe" </> Recipe.slugParser </> s "edit")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Root ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Signup ->
                    [ "signup" ]

                Randomizer ->
                    [ "random" ]

                Recipes ->
                    [ "recipes" ]

                NewRecipe ->
                    [ "recipe", "new" ]

                RecipeDetail slug ->
                    [ "recipe", Recipe.slugToString slug ]

                EditRecipe slug ->
                    [ "recipe", Recipe.slugToString slug, "edit" ]
    in
        "#/" ++ String.join "/" pieces



-- PUBLIC HEADERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Root
    else
        parseHash route location


routeToTitle : Route -> String
routeToTitle route =
    case route of
        Root ->
            ""

        Login ->
            "Login"

        Logout ->
            ""

        Signup ->
            "Sign up"

        Randomizer ->
            "New Idea"

        Recipes ->
            "Recipes"

        NewRecipe ->
            "New Recipe"

        RecipeDetail slug ->
            "Recipe Details"

        EditRecipe slug ->
            "Edit Recipe"
