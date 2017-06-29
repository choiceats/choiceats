// @flow

import type { Recipe } from 'types'

export type RecipeProps = {
  allowEdits: boolean;
  isLoggedIn: boolean;
  likes: number;
  likes?: number;
  mutate: Function;
  recipe: Recipe;
  userId?: number;
  youLike?: boolean;
}
