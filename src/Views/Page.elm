module Views.Page exposing (ActivePage(..), frame)

{-| Add header to page
-}

import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)
import Route exposing (Route)
import Views.Spinner exposing (spinner)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't have links for every page. Anything that's not part of the navbar falls under Other.

-}
type ActivePage
    = Other
    | Home
    | Login
    | Signup
    | Randomizer
    | Recipes
    | NewRecipe


{-| Take a page's Html and add a header

The caller provides the current user, letting us show login or logout buttons and user's name.

isLoading is for determining whether we should show a loading spinner in the header. (This comes up during slow page transitions.)

-}
frame : Bool -> Maybe User -> ActivePage -> Html msg -> Html msg
frame isLoading user page content =
    div [ class "page-frame" ]
        [ viewHeader page user isLoading
        , content
        ]


viewHeader : ActivePage -> Maybe User -> Bool -> Html msg
viewHeader page user isLoading =
    let
        linkTo =
            navbarLink page

        sessionButton =
            case user of
                Just user ->
                    linkTo Route.Logout
                        [ button [ class "ui button", type_ "button" ] [ text "Logout" ] ]

                Nothing ->
                    linkTo Route.Login
                        [ button [ class "ui button", type_ "button" ] [ text "Login" ] ]
    in
        div [ class "ui secondary menu", style [ ( "height", "50px" ) ] ]
            [ div [ class "header item" ] [ text "ChoicEats" ]
            , linkTo Route.Recipes [ text "Recipes" ] -- TODO: Change route to / when this route is created. And make recipes the default route.
            , linkTo Route.Randomizer [ text "Ideas" ]
            , div [ class "right menu" ]
                [ div [ class "item" ]
                    [ sessionButton ]
                ]
            ]


navbarLink : ActivePage -> Route -> List (Html msg) -> Html msg
navbarLink page route linkContent =
    li [ classList [ ( "item", True ), ( "active", isActive page route ) ] ]
        [ a [ Route.href route ] linkContent ]


isActive : ActivePage -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Login, Route.Login ) ->
            True

        ( Signup, Route.Signup ) ->
            True

        ( Randomizer, Route.Randomizer ) ->
            True

        ( Recipes, Route.Recipes ) ->
            True

        _ ->
            False
