module ViewFilterButtons exposing (viewFilterButtons)

-- BUILTIN CODE

import Html exposing (Html, div, button, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- APPLICATION CODE

import Randomizer.Types as T exposing (..)


viewFilterButtons : T.Model -> Html T.Msg
viewFilterButtons model =
    div
        [ class "ui fluid buttons"
        ]
        [ filterButton "All" All model.currentFilter
        , filterButton "Favs" Fav model.currentFilter
        , filterButton "My" My model.currentFilter
        ]


filterButton innerText buttonFilter currentFilter =
    button
        [ class
            (if (buttonFilter == currentFilter) then
                "ui active button"
             else
                "ui button"
            )
        , onClick (SetFilterType buttonFilter)

        --  , role "button"
        ]
        [ text innerText ]
