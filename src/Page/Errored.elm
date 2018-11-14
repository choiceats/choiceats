module Page.Errored exposing (PageLoadError(..), pageLoadError, view)

{-| The page that renders when there was an error trying to load another page, for example a
Page Not Found error.
-}

import Data.Session exposing (Session)
import Html exposing (Html, br, div, h1, img, main_, p, text)
import Html.Attributes exposing (alt, class, id, src, style, tabindex)
import Views.Page exposing (ActivePage)



-- MODEL --


type PageLoadError
    = PageLoadError Model


type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }


pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }



-- VIEW --


words =
    { title = "Angry hedgie says"
    }


view : Session -> PageLoadError -> Html msg
view session (PageLoadError model) =
    main_ [ id "content", class "container", tabindex -1 ]
        [ h1 [ class "ui header" ] [ text words.title ]
        , div [ class "row" ]
            [ p [] [ text model.errorMessage ]
            , br [] []
            , img [ style "max-width" "320px", class "ui image", src "/error-hedgehog.jpg" ] []
            ]
        ]
