// @flow
import {
  SELECT_RECIPE,
  SELECT_RECIPE_TO_DELETE,
  SET_RECIPE_STATUS,
  SET_RECIPE_LIKE_STATUS
} from './action-types'
import type { Action } from 'types'

export const selectRecipe: (
  recipeId: number
) => Action & { payload: number } = recipeId => ({
  type: SELECT_RECIPE,
  payload: recipeId
})

export const selectRecipeToDelete: (
  recipeId: null | string | number
) => Action & { payload: null | string | number } = recipeId => ({
  type: SELECT_RECIPE_TO_DELETE,
  payload: recipeId
})

export const setRecipeStatus: (
  payload: Object
) => Action & { payload: Object } = payload => ({
  type: SET_RECIPE_STATUS,
  payload
})

export const setRecipeLikeStatus: (
  payload: Object
) => Action & { payload: Object } = payload => ({
  type: SET_RECIPE_LIKE_STATUS,
  payload
})
