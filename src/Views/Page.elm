module Views.Page exposing (ActivePage(..), frame)

{-| Add header to page
-}

-- ELM-LANG MODULES --

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (lazy2)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --

import Data.User as User exposing (User)
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
            navbarLink page False

        sessionLinkTo =
            navbarLink page True

        sessionLinkRoute =
            case user of
                Just user ->
                    Route.Logout

                Nothing ->
                    (case page of
                        Login ->
                            Route.Signup

                        _ ->
                            Route.Login
                    )

        sessionLinkText =
            case user of
                Just user ->
                    "Logout"

                Nothing ->
                    (case page of
                        Login ->
                            "Sign up"

                        _ ->
                            "Login"
                    )
    in
        div [ class "ui secondary menu" ]
            [ div [ class "header item" ] [ text "ChoicEats" ]
            , linkTo Route.Recipes [ text "Recipes" ]
            , linkTo Route.Randomizer [ text "Ideas" ]
            , sessionLinkTo sessionLinkRoute [ text sessionLinkText ]
            ]


navbarLink : ActivePage -> Bool -> Route -> List (Html msg) -> Html msg
navbarLink page isSessionLink route linkContent =
    a
        [ Route.href route
        , classList
            [ ( "item link", True )
            , ( "active", isActive page route )
            , ( "right aligned", isSessionLink )
            ]
        ]
        linkContent


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
