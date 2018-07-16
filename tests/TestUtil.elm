module TestUtil exposing (..)

-- THIRD PARTY --

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Util exposing (getImageUrl)


suite : Test
suite =
    describe "Utils"
        [ describe "getImageUrl"
            [ test "defaults to / for missing images" <|
                \_ -> getImageUrl "" |> Expect.equal "/"
            , test "returns string otherwise" <|
                \_ -> getImageUrl "goats" |> Expect.equal "goats!"
            ]
        ]
