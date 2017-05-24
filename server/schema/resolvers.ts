import * as seedRecipes from '../seed-recipes';

export const resolvers = {
  Query: {
    recipes: () => {
      return seedRecipes;
    },
  },
};