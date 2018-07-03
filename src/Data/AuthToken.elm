module Data.AuthToken exposing (AuthToken(..), decoder, encode, withAuthorization, blankToken, getTokenString)

-- ELM-LANG MODULES --

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


-- THIRD PARTY MODULES --

import HttpBuilder exposing (RequestBuilder, withHeader)


-- APPLICATION MODULES --


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken


getTokenString : AuthToken -> String
getTokenString (AuthToken str) =
    str


blankToken =
    AuthToken ""


withAuthorization : Maybe AuthToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (AuthToken token) ->
            builder
                |> withHeader "authorization" ("Token " ++ token)

        Nothing ->
            builder
