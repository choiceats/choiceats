module RecipeQueries
    exposing
        ( RecipeQueryMsg(..)
          -- Queries
        , sendUnitsQuery
        , sendRecipeQuery
        , sendIngredientsQuery
        , submitRecipeMutation
        )

import Http
import Array exposing (Array)
import Task exposing (Task)
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GqlB
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Recipes.Types


type alias AuthToken =
    String


type alias RecipeId =
    Int


type alias RequestOptions a =
    { headers : List Http.Header
    , method : String
    , timeout : Maybe a
    , url : String
    , withCredentials : Bool
    }



-- Helper function that sets headers and url for a graphql
-- request


requestOptions : String -> RequestOptions a
requestOptions token =
    { method = "POST"
    , headers = [ (Http.header "Authorization" ("Bearer " ++ token)) ]
    , url = "http://localhost:4000/graphql/"
    , timeout = Nothing
    , withCredentials = False -- value of True makes CORS active, breaking the request
    }



--
-- Queries Messages
--


type RecipeQueryMsg
    = RequestRecipe
    | ReceiveUnits UnitsResponse
    | ReceiveRecipeFull Recipes.Types.RecipeFullResponse
    | ReceiveIngredients IngredientsResponse



--
-- RESPONSE TYPES
--


type alias RecipeFullResponse =
    Result GraphQLClient.Error Recipes.Types.RecipeFull


type alias RecipesResponse =
    Result GraphQLClient.Error (List Recipes.Types.RecipeSummary)


type alias TagsResponse =
    Result GraphQLClient.Error (List Recipes.Types.RecipeTag)


type alias UnitsResponse =
    Result GraphQLClient.Error (List Recipes.Types.Unit)


type alias IngredientsResponse =
    Result GraphQLClient.Error (List Recipes.Types.IngredientRaw)



--
-- GRAPHQL Queries
--


sendUnitsQuery : AuthToken -> (UnitsResponse -> a) -> Cmd a
sendUnitsQuery authToken msg =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken)
            (GqlB.request {} unitsRequest)
        )


sendIngredientsQuery : AuthToken -> (IngredientsResponse -> a) -> Cmd a
sendIngredientsQuery authToken msg =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken)
            (GqlB.request {} ingredientsRequest)
        )


sendRecipeQuery : AuthToken -> RecipeId -> (RecipeFullResponse -> a) -> Cmd a
sendRecipeQuery authToken recipeId msg =
    Task.attempt
        msg
        (GraphQLClient.customSendQuery
            (requestOptions authToken)
            (GqlB.request { recipeId = recipeId } recipeRequest)
        )


type alias RecipeMutationInput =
    { description : String
    , id : String
    , imageUrl : String
    , ingredients : List RecipeMutationIngredientInput
    , instructions : String
    , name : String
    , tags : List Recipes.Types.RecipeTag
    }


type alias RecipeMutationIngredientInput =
    { quantity : String
    , ingredientId : String
    , unitId : String
    }


convertRecipeArraysToList : Recipes.Types.EditingRecipeFull -> RecipeMutationInput
convertRecipeArraysToList recipe =
    { recipe | ingredients = Array.toList recipe.ingredients }


submitRecipeMutation : AuthToken -> Recipes.Types.EditingRecipeFull -> (RecipeFullResponse -> a) -> Cmd a
submitRecipeMutation authToken recipe msg =
    Task.attempt
        msg
        (GraphQLClient.customSendMutation
            (requestOptions authToken)
            (GqlB.request { recipe = (convertRecipeArraysToList recipe) } saveRecipeMutation)
        )



--
-- GraphQL Requests
--


unitsRequest : GqlB.Document GqlB.Query (List Recipes.Types.Unit) {}
unitsRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "units"
                []
                gqlUnitList
            )
        )


recipeRequest : GqlB.Document GqlB.Query Recipes.Types.RecipeFull { vars | recipeId : Int }
recipeRequest =
    GqlB.queryDocument
        (GqlB.extract
            (GqlB.field
                "recipe"
                [ ( "recipeId"
                  , Arg.variable (Var.required "recipeId" .recipeId Var.int)
                  )
                ]
                gqlRecipeFull
            )
        )


ingredientsRequest : GqlB.Document GqlB.Query (List Recipes.Types.IngredientRaw) {}
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
                                [ Var.field "id" .id Var.string
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



-- const gqlStuff = gql`
--   mutation SaveRecipe($recipe: RecipeInput!) {
--     saveRecipe(recipe: $recipe) {
--       id
--       author
--       authorId
--       description
--       imageUrl
--       name
--       instructions
--       ingredients {
--         id
--         name
--         unit {
--           id
--           name
--           abbr
--         }
--         quantity
--       }
--       tags {
--         id
--       }
--       likes
--     }
--   }
-- `
--
-- GraphQL Object definitions
--


gqlUnit : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType Recipes.Types.IngredientUnit vars
gqlUnit =
    GqlB.object Recipes.Types.IngredientUnit
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "abbr" [] GqlB.string)


gqlTag : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType Recipes.Types.RecipeTag vars
gqlTag =
    GqlB.object Recipes.Types.RecipeTag
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)


gqlIngredient : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType Recipes.Types.Ingredient vars
gqlIngredient =
    GqlB.object Recipes.Types.Ingredient
        |> GqlB.with (GqlB.field "quantity" [] GqlB.float)
        |> GqlB.with (GqlB.field "displayQuantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "unit" [] gqlUnit)


gqlRecipeFull : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType Recipes.Types.RecipeFull vars
gqlRecipeFull =
    GqlB.object Recipes.Types.RecipeFull
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
        |> GqlB.with (GqlB.field "id" [] GqlB.string)
        |> GqlB.with (GqlB.field "imageUrl" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredients" [] (GqlB.list gqlEditingIngredient))
        |> GqlB.with (GqlB.field "instructions" [] GqlB.string)
        |> GqlB.with (GqlB.field "name" [] GqlB.string)
        |> GqlB.with (GqlB.field "tags" [] (GqlB.list gqlTag))


gqlEditingIngredient : GqlB.ValueSpec GqlB.NonNull GqlB.ObjectType RecipeMutationIngredientInput vars
gqlEditingIngredient =
    GqlB.object Recipes.Types.EditingIngredient
        |> GqlB.with (GqlB.field "quantity" [] GqlB.string)
        |> GqlB.with (GqlB.field "ingredientId" [] GqlB.string)
        |> GqlB.with (GqlB.field "unitId" [] GqlB.string)


gqlUnitList : GqlB.ValueSpec GqlB.NonNull (GqlB.ListType GqlB.NonNull GqlB.ObjectType) (List Recipes.Types.Unit) vars
gqlUnitList =
    GqlB.list
        (GqlB.object Recipes.Types.Unit
            |> GqlB.with (GqlB.field "id" [] GqlB.string)
            |> GqlB.with (GqlB.field "name" [] GqlB.string)
            |> GqlB.with (GqlB.field "abbr" [] GqlB.string)
        )


gqlIngredientList : GqlB.ValueSpec GqlB.NonNull (GqlB.ListType GqlB.NonNull GqlB.ObjectType) (List Recipes.Types.IngredientRaw) vars
gqlIngredientList =
    GqlB.list
        (GqlB.object Recipes.Types.IngredientRaw
            |> GqlB.with (GqlB.field "id" [] GqlB.string)
            |> GqlB.with (GqlB.field "name" [] GqlB.string)
        )
