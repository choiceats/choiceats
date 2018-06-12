module TestAuthToken exposing (..)

-- THIRD PARTY --

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Data.AuthToken
    exposing
        ( AuthToken(..)
        , getTokenString
        )


suite : Test
suite =
    describe "Data.AuthToken"
        [ describe "getTokenString"
            [ test "extracts string from a token" <|
                \_ -> getTokenString (AuthToken "goats") |> Expect.equal "goats"
            ]
        ]
