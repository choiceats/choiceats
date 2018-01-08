module ViewRecipeSummary exposing (viewRecipeSummary)

-- ELM-LANG MODULES

import Html exposing (Html, div, text, a, img, i)
import Html.Attributes exposing (class, style, href, src)


-- APPLICATION MODULES

import Randomizer.Types as T exposing (..)
import ViewLoading exposing (viewLoading)


viewRecipeSummary : Maybe RecipeResponse -> Html T.Msg
viewRecipeSummary mRecipeSummary =
    case mRecipeSummary of
        Just res ->
            case res of
                Ok r ->
                    a [ href <| "/recipe/" ++ r.id ]
                        [ div [ class "ui fluid card", style [ ( "margin-bottom", "15px" ) ] ]
                            [ img [ class "ui image", src r.imageUrl ] []
                            , div [ class "content" ]
                                [ div [ class "header" ] [ text r.name ]
                                , div [ class "meta" ] [ text r.author ]
                                , div [ class "meta" ]
                                    [ i
                                        [ class <|
                                            if r.youLike then
                                                "green"
                                            else
                                                "grey" ++ " favorite large icon"
                                        ]
                                        []
                                    , text <| toString r.likes
                                    ]
                                ]
                            , div [ class "description" ] [ text r.description ]
                            ]
                        ]

                Err r ->
                    div [] [ text ("ruh rohr, you has err: " ++ (toString r)) ]

        Nothing ->
            viewLoading
