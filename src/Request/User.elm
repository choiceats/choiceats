module Request.User exposing (login, storeSession)

-- ELM-LANG MODULES --

import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- THIRD PARTY MODULES --

import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Encode.Extra as EncodeExtra


-- APPLICATION MODULES --

import Data.AuthToken exposing (AuthToken, withAuthorization)
import Data.User as User exposing (User)
import Ports


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | apiUrl : String, email : String, password : String } -> Http.Request User
login { apiUrl, email, password } =
    let
        user =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
        Decode.field "user" User.decoder
            |> Http.post apiUrl body
