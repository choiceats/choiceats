module TestDataRecipe exposing (..)

-- THIRD PARTY --

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Data.Recipe
    exposing
        ( SearchFilter(..)
        , Slug(..)
        , mapFilterTypeToString
        , slugToString
        )


suite : Test
suite =
    describe "Data.Recipe"
        [ describe "mapFilterTypeToString"
            [ test "My -> my" <|
                \_ -> mapFilterTypeToString My |> Expect.equal "my"
            , test "Fav -> fav" <|
                \_ -> mapFilterTypeToString Fav |> Expect.equal "fav"
            , test "All -> all" <|
                \_ -> mapFilterTypeToString All |> Expect.equal "all"
            ]
        , describe "slugToString"
            [ test "successfully extracts string from a slug" <|
                \_ -> slugToString (Slug "goats") |> Expect.equal "goats"
            ]
        ]
