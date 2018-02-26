module Request.User exposing (login, storeSession)

import Data.AuthToken exposing (AuthToken, withAuthorization)
import Data.User as User exposing (User)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra
import Ports
import Request.Helpers exposing (apiUrl)
import Util exposing ((=>))


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | email : String, password : String } -> Http.Request User
login { email, password } =
    let
        user =
            Encode.object
                [ "email" => Encode.string email
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
        Decode.field "user" User.decoder
            |> Http.post ("http://localhost:4000/auth") body



-- TODO: Convert http request in Page/Signup
-- signup : { r | username : String, email : String, password : String } -> Http.Request User
-- signup { username, email, password } =
--     let
--         user =
--             Encode.object
--                 [ "username" => Encode.string username
--                 , "email" => Encode.string email
--                 , "password" => Encode.string password
--                 ]
--
--         body =
--             Encode.object [ "user" => user ]
--                 |> Http.jsonBody
--     in
--         Decode.field "user" User.decoder
--             |> Http.post (apiUrl "/users") body
