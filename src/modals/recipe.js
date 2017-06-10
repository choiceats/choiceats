
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
 

# This type specifies the entry points into our API. In this case
# there is only one - "channels" - which returns a list of channels.
type Query {
  recipes: [Recipe]    # "[]" means this is a list of channels
}
`
