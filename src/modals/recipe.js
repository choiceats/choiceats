
export const typeDefs = `
  type Unit {
    name: String
    abbr: String
  }

  type Ingredient {
    name: String!
    unit: Unit
    quantity: Int!
  }

  type Recipe {
    id: ID
    author: String
    authorId: String
    ingredients: [Ingredient]
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
}

type Mutation {
  likeRecipe
}
`
