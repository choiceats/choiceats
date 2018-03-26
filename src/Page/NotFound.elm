module Page.NotFound exposing (view)

-- ELM-LANG MODULES --

import Html exposing (Html, main_, img)
import Html.Attributes exposing (src, tabindex, style)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --

import Data.Session exposing (Session)


-- VIEW --


view : Session -> Html msg
view session =
    main_
        [ style
            [ ( "max-width", "100%" )
            , ( "margin", "0 auto" )
            , ( "text-align", "center" )
            ]
        ]
        [ img
            [ src "http://hrwiki.org/w/images/0/03/404.PNG"
            , style [ ( "max-width", "100%" ) ]
            ]
            []
        ]
