// @flow

export type Recipe = {
  author: String;
  ingredients: String;
  instructions: String;
  name: String;
}

export type RecipeListProps = {
  data?: {
    loading: string;
    error: string;
    recipes: Recipe[];
  }
}
