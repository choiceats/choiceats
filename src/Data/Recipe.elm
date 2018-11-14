module Data.Recipe exposing
    ( DeleteRecipeResponse
    , DeleteResponseBody
    , EditingIngredient
    , EditingRecipeFull
    , Flags
    , Ingredient
    , IngredientRaw
    , IngredientUnit
    , RecipeFull
    , RecipeFullResponse
    , RecipeId
    , RecipeMsg
    , RecipeQueryMsg(..)
    , RecipeSummary
    , RecipeTag
    , RecipesResponse
    , SearchFilter(..)
    , Slug(..)
    , TagsResponse
    ,  Unit
       -- HELPER FUNCTIONS

    ,  -- QUERIES --
       createIngredientsQueryTask

    , createRecipeQueryTask
    , createUnitsQueryTask
    , gqlRecipeSummary
    , mapFilterTypeToString
    , requestOptions
    , sendIngredientsQuery
    , sendRecipeQuery
    , sendUnitsQuery
    ,  slugParser
       -- OTHER

    , slugToString
    ,  submitDeleteMutation
       -- TYPES --

    , submitLikeMutation
    , submitRecipeMutation
    )

import Array exposing (Array)
import Data.AuthToken as AuthToken exposing (AuthToken, blankToken, getTokenString)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Http
import Task exposing (Task)
import Url.Parser exposing (Parser, custom)


type alias RecipeId =
    String


type alias RequestOptions a =
    { headers : List Http.Header
    , method : String
    , timeout : Maybe a
    , url : String
    , withCredentials : Bool
    }



-- Helper function that sets headers and url for a graphql
-- request


requestOptions : AuthToken -> String -> RequestOptions a
requestOptions token apiUrl =
    { method = "POST"
    , headers = [ Http.header "Authorization" ("Bearer " ++ getTokenString token) ]
    , url = apiUrl ++ "/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }



--
-- Queries Messages
--


type RecipeQueryMsg
    = RequestRecipe
    | ReceiveUnits UnitsResponse
    | ReceiveRecipeFull RecipeFullResponse
    | ReceiveIngredients IngredientsResponse



--
-- RESPONSE TYPES
--


type alias RecipeFullResponse =
    Result GraphQLClient.Error RecipeFull


type alias RecipesResponse =
    Result GraphQLClient.Error (List RecipeSummary)


type alias TagsResponse =
    Result GraphQLClient.Error (List RecipeTag)


type alias UnitsResponse =
    Result GraphQLClient.Error (List Unit)


type alias IngredientsResponse =
    Result GraphQLClient.Error (List IngredientRaw)


type alias DeleteRecipeResponse =
    Result GraphQLClient.Error DeleteResponseBody



--
-- GRAPHQL Queries
--


type alias ApiUrl =
    String


createUnitsQueryTask : AuthToken -> ApiUrl -> Task GraphQLClient.Error (List Unit)
createUnitsQueryTask authToken apiUrl =
    GraphQLClient.customSendQuery
        (requestOptions authToken apiUrl)
        (GqlB.request {} unitsRequest)


sendUnitsQuery : AuthToken -> (UnitsResponse -> a) -> ApiUrl -> Cmd a
sendUnitsQuery authToken msg apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken apiUrl)
            (GqlB.request {} unitsRequest)
        )


sendIngredientsQuery : AuthToken -> (IngredientsResponse -> a) -> ApiUrl -> Cmd a
sendIngredientsQuery authToken msg apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken apiUrl)
            (GqlB.request {} ingredientsRequest)
        )


createIngredientsQueryTask : AuthToken -> ApiUrl -> Task GraphQLClient.Error (List IngredientRaw)
createIngredientsQueryTask authToken apiUrl =
    GraphQLClient.customSendQuery
        (requestOptions authToken apiUrl)
        (GqlB.request {} ingredientsRequest)


sendRecipeQuery : AuthToken -> RecipeId -> (RecipeFullResponse -> a) -> ApiUrl -> Cmd a
sendRecipeQuery authToken recipeId msg apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken apiUrl)
            (GqlB.request { recipeId = recipeId } recipeRequest)
        )


createRecipeQueryTask : AuthToken -> RecipeId -> ApiUrl -> Task GraphQLClient.Error RecipeFull
createRecipeQueryTask authToken recipeId apiUrl =
    GraphQLClient.customSendQuery
        (requestOptions authToken apiUrl)
        (GqlB.request { recipeId = recipeId } recipeRequest)


type alias RecipeMutationInput =
    { description : String
    , id : Maybe String
    , imageUrl : String
    , ingredients : List RecipeMutationIngredientInput
    , instructions : String
    , name : String
    , tags : List RecipeTag
    }


type alias RecipeMutationIngredientInput =
    { quantity : String
    , ingredientId : String
    , unitId : String
    }


convertRecipeArraysToList : EditingRecipeFull -> RecipeMutationInput
convertRecipeArraysToList recipe =
    let
        recipeId =
            if recipe.id == "" then
                Nothing

            else
                Just recipe.id
    in
    { description = recipe.description
    , id = recipeId
    , imageUrl = recipe.imageUrl
    , ingredients = Array.toList recipe.ingredients
    , instructions = recipe.instructions
    , name = recipe.name
    , tags = recipe.tags
    }


submitRecipeMutation : AuthToken -> EditingRecipeFull -> (RecipeFullResponse -> a) -> ApiUrl -> Cmd a
submitRecipeMutation authToken recipe msg apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendMutation
            (requestOptions authToken apiUrl)
            (GqlB.request { recipe = convertRecipeArraysToList recipe } saveRecipeMutation)
        )



--
-- GraphQL Requests
--


submitLikeMutation : AuthToken -> (RecipeFullResponse -> a) -> String -> String -> ApiUrl -> Cmd a
submitLikeMutation authToken msg userId recipeId apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendMutation
            (requestOptions authToken apiUrl)
            (GqlB.request { userId = userId, recipeId = recipeId } likeRecipeMutation)
        )


submitDeleteMutation : AuthToken -> (DeleteRecipeResponse -> a) -> String -> ApiUrl -> Cmd a
submitDeleteMutation authToken msg recipeId apiUrl =
    Task.attempt
        msg
        (GraphQLClient.customSendMutation
            (requestOptions authToken apiUrl)
            (GqlB.request { recipeId = recipeId } deleteRecipeMutation)
        )


deleteRecipeMutation =
    GqlB.mutationDocument
        (GqlB.extract
            (GqlB.field
                "deleteRecipe"
                [ ( "recipeId", Arg.variable (Var.required "recipeId" .recipeId Var.string) )
                ]
                gqlDeleteRecipeResult
            )
        )


likeRecipeMutation =
    GqlB.mutationDocument
        (GqlB.extract
            (GqlB.field
                "likeRecipe"
                [ ( "userId", Arg.variable (Var.required "userId" .userId Var.string) )
                , ( "recipeId", Arg.variable (Var.required "recipeId" .recipeId Var.string) )
                ]
                gqlRecipeFull
            )
        )


unitsRequest : GqlB.Document GqlB.Query (List Unit) {}
unitsRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "units"
                []
                gqlUnitList
            )
        )


recipeRequest : GqlB.Document GqlB.Query RecipeFull { vars | recipeId : String }
recipeRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "recipe"
                [ ( "recipeId"
                  , Arg.variable (Var.required "recipeId" .recipeId Var.string)
                  )
                ]
                gqlRecipeFull
            )
        )


ingredientsRequest : GqlB.Document GqlB.Query (List IngredientRaw) {}
ingredientsRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "ingredients"
                []
                gqlIngredientList
            )
        )


saveRecipeMutation =
    GqlB.mutationDocument
        (GqlB.extract
            (GqlB.field
                "saveRecipe"
                [ ( "recipe"
                  , Arg.variable
                        (Var.required
                            "recipe"
                            .recipe
                            (Var.object
                                "RecipeInput"
                                [ Var.field "id" .id (Var.nullable Var.string)
                                , Var.field "description" .description Var.string
                                , Var.field "imageUrl" .imageUrl Var.string
                                , Var.field "instructions" .instructions Var.string
                                , Var.field "ingredients"
                                    .ingredients
                                    (Var.list
                                        (Var.object
                                            "ingredient"
                                            [ Var.field "quantity" .quantity Var.string
                                            , Var.field "ingredientId" .ingredientId Var.string
                                            , Var.field "unitId" .unitId Var.string
                                            ]
                                        )
                                    )
                                , Var.field "name" .name Var.string
                                ]
                            )
                        )
                  )
                ]
                gqlRecipeFull
            )
        )


ingredientsArrayFromRecipeInput input =
    Array.toList input.ingredients



--
-- GraphQL Object definitions
--


gqlUnit : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType IngredientUnit vars
gqlUnit =
    GqlB.object IngredientUnit
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "abbr" [] GqlB.string)


gqlTag : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeTag vars
gqlTag =
    GqlB.object RecipeTag
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)


gqlIngredient : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType Ingredient vars
gqlIngredient =
    GqlB.object Ingredient
        |> GqlB.with (GqlB.field "quantity" [] GqlB.float)
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "displayQuantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "unit" [] gqlUnit)


gqlRecipeSummary : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeSummary vars
gqlRecipeSummary =
    GqlB.object RecipeSummary
        |> GqlB.with (GqlB.field "author" [] GqlB.string)
        |> GqlB.with (GqlB.field "authorId" [] GqlB.string)
        |> GqlB.with (GqlB.field "description" [] GqlB.string)
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
        |> GqlB.with (GqlB.field "likes" [] (GqlB.list GqlB.int))
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "youLike" [] GqlB.bool)


gqlRecipeFull : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeFull vars
gqlRecipeFull =
    GqlB.object RecipeFull
        |> GqlB.with (GqlB.field "author" [] GqlB.string)
        |> GqlB.with (GqlB.field "authorId" [] GqlB.string)
        |> GqlB.with (GqlB.field "description" [] GqlB.string)
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredients" [] (GqlB.list gqlIngredient))
        |> GqlB.with (GqlB.field "instructions" [] GqlB.string)
        |> GqlB.with (GqlB.field "likes" [] (GqlB.list GqlB.int))
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "tags" [] (GqlB.list gqlTag))
        |> GqlB.with (GqlB.field "youLike" [] GqlB.bool)


gqlEditingRecipeFull : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeMutationInput vars
gqlEditingRecipeFull =
    GqlB.object RecipeMutationInput
        |> GqlB.with (GqlB.field "description" [] GqlB.string)
        |> GqlB.with (GqlB.field "id" [] (GqlB.nullable GqlB.string))
        |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredients" [] (GqlB.list gqlEditingIngredient))
        |> GqlB.with (GqlB.field "instructions" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "tags" [] (GqlB.list gqlTag))


gqlEditingIngredient : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeMutationIngredientInput vars
gqlEditingIngredient =
    GqlB.object EditingIngredient
        |> GqlB.with (GqlB.field "quantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredientId" [] GqlB.string)
        |> GqlB.with (GqlB.field "unitId" [] GqlB.string)


gqlUnitList : GqlB.ValueSpec GqlB.NonNull (GqlB.ListType GqlB.NonNull GqlB.ObjectType) (List Unit) vars
gqlUnitList =
    GqlB.list
        (GqlB.object Unit
            |> GqlB.with (GqlB.field "id" [] GqlB.string)
            |> GqlB.with (GqlB.field "name" [] GqlB.string)
            |> GqlB.with (GqlB.field "abbr" [] GqlB.string)
        )


gqlIngredientList : GqlB.ValueSpec GqlB.NonNull (GqlB.ListType GqlB.NonNull GqlB.ObjectType) (List IngredientRaw) vars
gqlIngredientList =
    GqlB.list
        (GqlB.object IngredientRaw
            |> GqlB.with (GqlB.field "id" [] GqlB.string)
            |> GqlB.with (GqlB.field "name" [] GqlB.string)
        )


gqlDeleteRecipeResult : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType DeleteResponseBody vars
gqlDeleteRecipeResult =
    GqlB.object DeleteResponseBody
        |> GqlB.with (GqlB.field "recipeId" [] GqlB.string)
        |> GqlB.with (GqlB.field "deleted" [] GqlB.bool)



-- WAS Recipes/Types


type alias Flags =
    { token : String
    , recipeId : String
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
    , id : String
    , displayQuantity : String
    , name : String
    , unit : IngredientUnit
    }


type alias IngredientRaw =
    { id : String
    , name : String
    }


type alias IngredientUnit =
    { id : String
    , name : String
    , abbr : String
    }


type alias Unit =
    { id : String
    , name : String
    , abbr : String
    }


type alias DeleteResponseBody =
    { recipeId : String
    , deleted : Bool
    }


type alias LikeResponseBody =
    { recipeId : String
    , userId : String
    , youLike : Bool
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


type alias EditingRecipeFull =
    { description : String
    , id : String
    , authorId : String
    , imageUrl : String
    , ingredients : Array EditingIngredient
    , instructions : String
    , name : String
    , tags : List RecipeTag
    }


type alias EditingIngredient =
    { quantity : String
    , ingredientId : String
    , unitId : String
    }


mapFilterTypeToString : SearchFilter -> String
mapFilterTypeToString filterType =
    case filterType of
        My ->
            "my"

        Fav ->
            "fav"

        All ->
            "all"



-- Routing types


slugParser : Parser (Slug -> a) a
slugParser =
    custom "SLUG" (Just << Slug)


type Slug
    = Slug String


slugToString : Slug -> String
slugToString (Slug slug) =
    slug
