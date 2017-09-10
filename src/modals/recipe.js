export const typeDefs = `
  type Unit {
    name: String
    abbr: String
  }

  type Ingredient {
    id: ID
    name: String!
  }

  type RecipeIngredient {
    id: ID
    name: String!
    unit: Unit
    quantity: Float!
  }

  type Tag {
    id: ID
    name: String!
  }

  type Recipe {
    id: ID
    author: String
    authorId: String
    ingredients: [RecipeIngredient]
    tags: [Tag]
    instructions: String
    name: String
  }
 
  input LikeRecipePayload {
    recipeId: ID!
    userId: ID!
  }

  type LikeRecipeResult {
    recipeId: ID!
    userId: ID!
    likeStatus: Boolean!
  }


# This type specifies the entry points into our API.
type Query {
  recipes: [Recipe]
  recipe: Recipe
  units: [Unit]
  ingredients: [Ingredient]
  tags: [Tag]
}

type Mutation {
  likeRecipe
}
`
