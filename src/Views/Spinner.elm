module Views.Spinner exposing (spinner)

-- ELM-LANG MODULES --

import Html exposing (Attribute, Html, div, li)
import Html.Attributes exposing (class, style)


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


spinner : Html msg
spinner =
    li [ class "sk-three-bounce", style "float" "left", style "margin" "8px" ]
        [ div [ class "sk-child sk-bounce1" ] []
        , div [ class "sk-child sk-bounce2" ] []
        , div [ class "sk-child sk-bounce3" ] []
        ]
