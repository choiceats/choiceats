
export const typeDefs = `
type Recipe {
  author: String
  ingredients: String
  instructions: String
  name: String
}

# This type specifies the entry points into our API. In this case
# there is only one - "channels" - which returns a list of channels.
type Query {
  recipes: [Recipe]    # "[]" means this is a list of channels
}
`;
