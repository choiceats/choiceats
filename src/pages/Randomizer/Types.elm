module Randomizer.Types exposing (..)

import Time exposing (Time)
import GraphQL.Client.Http as GraphQLClient
import Http


type ButtonFilter
    = My
    | Fav
    | All


type alias RecipeSummary =
    { author : String
    , authorId : String
    , description : String
    , id : String
    , imageUrl : String
    , likes : List Int
    , name : String
    , youLike : Bool
    }


type alias Model =
    { currentFilter : ButtonFilter
    , mRecipeSummary : Maybe RecipeResponse
    , flags : Flags
    }


type alias Flags =
    { token : String }


type alias RecipeResponse =
    Result GraphQLClient.Error RecipeSummary


type Msg
    = NoOp
    | Tick Time
    | RequestRecipe
    | SetFilterType ButtonFilter
    | ReceiveQueryResponse RecipeResponse


mapFilterTypeToString : ButtonFilter -> String
mapFilterTypeToString filterType =
    case filterType of
        My ->
            "my"

        Fav ->
            "fav"

        All ->
            "all"
