module Util exposing
    ( appendErrors
    , getDetailsLikesText
    , getImageUrl
    , getSummaryLikesText
    , graphQlErrorToString
    , httpErrorToString
    , onClickStopPropagation
    , viewIf
    )

-- ELM-LANG MODULES --

import GraphQL.Client.Http as GraphQLClient
import Html exposing (Attribute, Html)
import Html.Events exposing (custom, stopPropagationOn)
import Http
import Json.Decode as Decode
import String exposing (fromInt)


defaultOptions =
    { stopPropagation = False
    , preventDefault = False
    }



-- THIRD PARTY MODULES --
-- APPLICATION MODULES --


viewIf : Bool -> Html msg -> Html msg
viewIf condition content =
    if condition then
        content

    else
        Html.text ""


onClickStopPropagation msg =
    stopPropagationOn "click" (Decode.map alwaysStopPropagation (Decode.succeed msg))


alwaysStopPropagation : msg -> ( msg, Bool )
alwaysStopPropagation msg =
    ( msg, True )


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
                ++ fromInt otherLikes
                ++ " other"
                ++ (if otherLikes > 0 then
                        "s"

                    else
                        ""
                   )
                ++ " like this."

        ( _, False ) ->
            fromInt (likes - 1) ++ " others like this."


getDetailsLikesText : Int -> Bool -> String
getDetailsLikesText =
    getLikesText "Be the first to like this."


getSummaryLikesText : Int -> Bool -> String
getSummaryLikesText =
    getLikesText "0 likes"


graphQlErrorToString : GraphQLClient.Error -> String
graphQlErrorToString gqlError =
    case gqlError of
        GraphQLClient.GraphQLError errors ->
            "ERROR: " ++ String.join " " (List.map (\requestError -> requestError.message) errors)

        GraphQLClient.HttpError _ ->
            "ERROR: " ++ "vauge http error"


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl a ->
            "Bad url " ++ a

        Http.Timeout ->
            "asdf"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "Bad status: some_status_here"

        Http.BadPayload a b ->
            "Bad payload " ++ a ++ "b"
