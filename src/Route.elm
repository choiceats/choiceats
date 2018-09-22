module Route exposing (Route(..), fromUrl, href, replaceUrl, routeToTitle)

-- used to expose fromLocation, modifyUrl
-- ELM-LANG MODULES --
-- THIRD PARTY MODULES --
-- APPLICATION MODULES --
-- import Browser exposing (Location)

import Browser.Navigation as Nav
import Data.Recipe as Recipe
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)


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



-- this was "route" in the elm 18 elm-spa-example
-- this is "parser" in the elm 19 rework of elm-spa-example


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Login (s "login")
        , Parser.map Logout (s "logout")
        , Parser.map Signup (s "signup")
        , Parser.map Randomizer (s "random")
        , Parser.map Recipes (s "recipes")
        , Parser.map NewRecipe (s "recipe" </> s "new")
        , Parser.map RecipeDetail (s "recipe" </> Recipe.slugParser)
        , Parser.map EditRecipe (s "recipe" </> Recipe.slugParser </> s "edit")
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



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)



-- modifyUrl goes away?
-- modifyUrl : Route -> Cmd msg
-- modifyUrl =
--     routeToString >> replaceUrl


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser



-- fromLocation : Location -> Maybe Route
-- fromLocation location =
--     if String.isEmpty location.hash then
--         Just Root
--
--     else
--         parseHash route location


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



-- fromUrl is the new fromLocation???
