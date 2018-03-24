module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Data.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)
import Http
import Page.Errored exposing (PageLoadError(..), pageLoadError)
import Task exposing (Task)
import Util exposing (onClickStopPropagation)
import Views.Page as Page


type alias Model =
    { garbage : String
    }


garbageModel =
    { garbage = "in -> out"
    }



--init : Session -> Task PageLoadError Model
-- init :
--     Session
--     -> PageLoadError -- Model
-- init session =
--     let
--         handleLoadError _ =
--             pageLoadError Page.Home "Homepage is currently unavailable."
--     in
--         -- Task.map Model
--         --|> Task.mapError handleLoadError
--         -- Task.mapError handleLoadError
--         handleLoadError Model
-- TODO: Make it how it should be
-- Just Route.Home ->
--     transition HomeLoaded (Home.init model.session)
-- init : Session -> Task PageLoadError Model
-- init session =
--     let
--         feedSources =
--             if session.user == Nothing then
--                 SelectList.singleton globalFeed
--             else
--                 SelectList.fromLists [] yourFeed [ globalFeed ]
--
--         loadTags =
--             Request.Article.tags
--                 |> Http.toTask
--
--         loadSources =
--             Feed.init session feedSources
--
--         handleLoadError _ =
--             pageLoadError Page.Home "Homepage is currently unavailable."
--     in
--     Task.map2 Model loadTags loadSources
--         |> Task.mapError handleLoadError
-- init : Session -> Msg
-- init session =
--     Blah


init : Session -> Model
init session =
    garbageModel



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] [ text "viewFeed model.feed" ]
                , div [ class "sidebar" ]
                    [ p [] [ text "Popular Tags" ]
                    , text "viewTags model.tags"
                    ]
                ]
            ]
        ]


viewBanner : Html msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text " ChoiceEats" ]
            , p [] [ text "A place to share your recipes." ]
            ]
        ]


type Msg
    = Blah


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        Blah ->
            ( garbageModel, Cmd.none )
