// @flow
import type { Recipe, Ingredient } from 'types'

export const DEFAULT_RECIPE: Recipe = {
  id: null,
  name: '',
  author: '',
  instructions: '',
  ingredients: []
}

export const DEFAULT_INGREDIENT: Ingredient = {
  id: null,
  quantity: 1,
  unit: null,
  name: 'Can of Soup'
}
