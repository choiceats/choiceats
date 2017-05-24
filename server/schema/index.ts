import { makeExecutableSchema } from 'graphql-tools';
import { resolvers } from './resolvers';

const typeDefs = `
  type Recipe {
    author: String
    ingredients: String
    instructions: String
    name: String
  }

  type Query {
    recipes: [Recipe]
  }
`;

const schema = makeExecutableSchema({ typeDefs, resolvers });
export { schema };