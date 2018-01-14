module Recipes.Types exposing (..)

import GraphQL.Client.Http as GraphQLClient


type alias RecipeFullResponse =
    Result GraphQLClient.Error RecipeFull


type alias RecipesResponse =
    Result GraphQLClient.Error (List RecipeSummary)


type alias TagsResponse =
    Result GraphQLClient.Error (List RecipeTag)


type alias Flags =
    { token : String
    , recipeId : Int
    , userId : String
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
    , likes : List Int
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


type SearchFilter
    = My
    | Fav
    | All


type RecipeMsg
    = GetRecipes
    | GetRecipesResponse RecipesResponse
    | GetTagsResponse TagsResponse
    | SearchTextChange String
    | SearchFilterChange SearchFilter


mapFilterTypeToString : SearchFilter -> String
mapFilterTypeToString filterType =
    case filterType of
        My ->
            "my"

        Fav ->
            "fav"

        All ->
            "all"
