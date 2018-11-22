module Data.User
    exposing
        ( User
        , Name(..)
        , UserId(..)
        , blankUserId
        , decoder
        , encode
        , nameDecoder
        , nameParser
        , nameToHtml
        , nameToString
        , userIdDecoder
        , userIdParser
        , userIdToHtml
        , userIdToString
        )

-- ELM-LANG MODULES --

import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


-- THIRD PARTY MODULES --

import Json.Encode.Extra as EncodeExtra
import Url.Parser


-- APPLICATION MODULES --

import Data.AuthToken as AuthToken exposing (AuthToken)


type alias User =
    { email : String
    , token : AuthToken
    , name : Name
    , userId : UserId
    }



-- SERIALIZATION --


decoder : Decoder User
decoder =
    Decode.succeed User
        |> required "email" Decode.string
        |> required "token" AuthToken.decoder
        |> required "name" nameDecoder
        |> required "userId" userIdDecoder


encode : User -> Value
encode user =
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "token", AuthToken.encode user.token )
        , ( "name", encodeName user.name )
        , ( "userId", encodeUserId user.userId )
        ]



-- IDENTIFIERS --


type Name
    = Name String


type UserId
    = UserId String


blankUserId =
    UserId ""


nameToString : Name -> String
nameToString (Name name) =
    name


userIdToString : Name -> String
userIdToString (Name userId) =
    userId


nameParser : Url.Parser.Parser (Name -> a) a
nameParser =
    Url.Parser.custom "NAME" (Just << Name)


userIdParser : Url.Parser.Parser (UserId -> a) a
userIdParser =
    Url.Parser.custom "USERID" (Just << UserId)


nameDecoder : Decoder Name
nameDecoder =
    Decode.map Name Decode.string


userIdDecoder : Decoder UserId
userIdDecoder =
    Decode.map UserId Decode.string


encodeName : Name -> Value
encodeName (Name name) =
    Encode.string name


encodeUserId : UserId -> Value
encodeUserId (UserId userId) =
    Encode.string userId


nameToHtml : Name -> Html msg
nameToHtml (Name name) =
    Html.text name


userIdToHtml : UserId -> Html msg
userIdToHtml (UserId userId) =
    Html.text userId
