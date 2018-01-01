module Recipes.Types exposing (..)

import GraphQL.Client.Http as GraphQLClient


type alias RecipeFullResponse =
    Result GraphQLClient.Error RecipeFull


type alias RecipesResponse =
    Result GraphQLClient.Error (List RecipeSummary)


type alias Flags =
    { token : String
    , recipeId : Int
    , userId : Int
    }


type alias RecipeTag =
    { id : String
    , name : String
    }


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


type alias RecipeFull =
    { author : String
    , authorId : String
    , description : String
    , id : String
    , imageUrl : String
    , ingredients : List Ingredient
    , instructions : String
    , likes : Int
    , name : String
    , tags : List RecipeTag
    , youLike : Bool
    }


type alias Ingredient =
    { quantity : Float
    , displayQuantity : String
    , name : String
    , unit : IngredientUnit
    }


type alias IngredientUnit =
    { name : String
    , abbr : String
    }


type ButtonFilter
    = My
    | Fav
    | All


type RecipeMsg
    = GetRecipes
    | GetRecipesResponse RecipesResponse


mapFilterTypeToString : ButtonFilter -> String
mapFilterTypeToString filterType =
    case filterType of
        My ->
            "my"

        Fav ->
            "fav"

        All ->
            "all"
