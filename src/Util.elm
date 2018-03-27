module Util exposing (appendErrors, onClickStopPropagation, viewIf, getImageUrl)

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
