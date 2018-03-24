module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Navigation exposing (Location)
import Data.Recipe as Recipe
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Home
    | Root
    | Login
    | Logout
    | Signup
    | Randomizer
    | Recipes
    | RecipeDetail Recipe.Slug


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Login (s "login")
        , Url.map Logout (s "logout")
        , Url.map Signup (s "signup")
        , Url.map Randomizer (s "random")
        , Url.map Recipes (s "recipes")
        , Url.map RecipeDetail (s "recipes" </> Recipe.slugParser)
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

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

                RecipeDetail slug ->
                    [ "recipes", Recipe.slugToString slug ]
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
