module Util
    exposing
        ( appendErrors
        , onClickStopPropagation
        , viewIf
        , getImageUrl
        , getDetailsLikesText
        , getSummaryLikesText
        )

-- ELM-LANG MODULES --

import Html exposing (Attribute, Html)
import Html.Events exposing (defaultOptions, onWithOptions)
import Json.Decode as Decode


-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


viewIf : Bool -> Html msg -> Html msg
viewIf condition content =
    if condition then
        content
    else
        Html.text ""


onClickStopPropagation : msg -> Attribute msg
onClickStopPropagation msg =
    onWithOptions "click"
        { defaultOptions | stopPropagation = True }
        (Decode.succeed msg)


appendErrors : { model | errors : List error } -> List error -> { model | errors : List error }
appendErrors model errors =
    { model | errors = model.errors ++ errors }


getImageUrl str =
    let
        empty =
            String.isEmpty str
    in
        if empty then
            "/"
        else
            str


getLikesText : String -> Int -> Bool -> String
getLikesText noLikesText likes youLike =
    case ( likes, youLike ) of
        ( 0, _ ) ->
            noLikesText

        ( 1, True ) ->
            "You like this."

        ( 1, False ) ->
            "1 person likes this."

        ( _, True ) ->
            let
                otherLikes =
                    likes - 1
            in
                "You and "
                    ++ (toString otherLikes)
                    ++ " other"
                    ++ (if (otherLikes > 0) then
                            "s"
                        else
                            ""
                       )
                    ++ " like this."

        ( _, False ) ->
            (toString (likes - 1)) ++ " others like this."


getDetailsLikesText : Int -> Bool -> String
getDetailsLikesText =
    getLikesText "Be the first to like this."


getSummaryLikesText : Int -> Bool -> String
getSummaryLikesText =
    getLikesText "0 likes"
