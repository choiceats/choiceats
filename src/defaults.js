// @flow
import type { Recipe, Ingredient } from 'types'

export const DEFAULT_RECIPE: Recipe = {
  id: null,
  name: '',
  author: '',
  instructions: '',
  ingredients: [],
  description: ''
}

export const DEFAULT_INGREDIENT: Ingredient = {
  id: null,
  quantity: 1,
  unit: null,
  name: 'Can of Soup'
}

export const DEFAULT_UI_STATE = {
  selectedRecipeId: null,
  editingRecipeId: null
}
