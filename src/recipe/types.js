// @flow
export type Recipe = {
  id: string;
  author: string;
  ingredients: string;
  instructions: string;
  name: string;
}

export type RecipeListProps = {
  data?: {
    loading: string;
    error: string;
    recipes: Recipe[];
    isLoggedIn: any;
  }
}
