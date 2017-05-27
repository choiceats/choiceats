export interface Recipe {
  author: String;
  ingredients: String;
  instructions: String;
  name: String;
}

export interface RecipeListProps {
  data?: {
    loading: string;
    error: string;
    recipes: Recipe[];
  }
}