// @flow
import type { Recipe, RecipeIngredient } from 'types'

export const DEFAULT_RECIPE: Recipe = {
  id: null,
  name: '',
  author: '',
  instructions: '',
  ingredients: [],
  description: ''
}

export const DEFAULT_RECIPE_INGREDIENT: RecipeIngredient = {
  id: null,
  quantity: 1,
  unit: null,
  name: 'Can of Soup'
}

export const DEFAULT_UI_STATE = {
  selectedRecipeId: null,
  editingRecipeId: null
}
