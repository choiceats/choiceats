// @flow

import type { Recipe } from 'types'

export type RecipeProps = {
  recipe: Recipe;
  isLoggedIn: boolean;
  allowEdits: boolean;
  youLike: boolean;
  likes: number;
}
