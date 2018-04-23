module Page.NotFound exposing (view)

-- ELM-LANG MODULES --

import Html exposing (Html, main_, img)
import Html.Attributes exposing (src, class)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --

import Data.Session exposing (Session)


-- VIEW --


view : Session -> Html msg
view session =
    main_
        [ class "ui container" ]
        [ img
            [ src "http://hrwiki.org/w/images/0/03/404.PNG"
            , class "ui fluid centered image"
            ]
            []
        ]
