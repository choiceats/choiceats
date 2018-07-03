module TestPageLogin exposing (..)

-- THIRD PARTY --

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Page.Login
    exposing
        ( init
        , update
        , view
        )


goats =
    "goats"


initExpected =
    { errors = []
    , email = ""
    , password = ""
    , apiUrl = goats
    }


suite : Test
suite =
    describe "Page.Login"
        [ describe "init"
            [ test "creates initial model record with blanks and an apiUrl" <|
                \_ -> init goats |> Expect.equal initExpected
            ]

        -- TODO: Add test
        --        , describe "view"
        --            [ test "alsdkjf" <|
        --                \_ -> () |> Expect.equal False
        --            ]
        ]
