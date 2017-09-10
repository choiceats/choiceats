// @flow

import type { Dispatch } from 'redux'

export type ConnectedProps = {
  dispatch: Dispatch<*>
}

export type User = {
  id: number,
  token: string
}

export type Unit = {
  id: number,
  name: string,
  abbr: string
}

export type Ingredient = {
  id: number,
  name: string
}

export type RecipeIngredient = {
  id: ?number, // Null id means unsaved
  name: string,
  unit: ?Unit,
  quantity: number
}

export type RecipeTag = {
  id: number,
  name: string
}

export type Recipe = {
  id: ?number | ?string, // Null id means unsaved
  author: string,
  ingredients: RecipeIngredient[],
  instructions: string,
  name: string,
  description: string,
  likes?: number,
  imageUrl: string,
  tags: RecipeTag[]
}

export type Action = {
  type: ?string
}

export type AppState = {
  ui: {
    selectedRecipeId: number
  }
}
