// @flow
import {
  LOGIN,
  LOGOUT,
  SELECT_RECIPE,
  SELECT_RECIPE_TO_DELETE
} from './action-types'
import type { User, Action } from 'types'

// Testing out this syntax for defining a var, its type then
// implementation
export const logout
  : () => Action =
    () => {
      return {
        type: LOGOUT
      }
    }

export const login
  : (User) => Action =
    (userInfo) => {
      return {
        type: LOGIN,
        payload: userInfo
      }
    }

export const selectRecipe
  : (recipeId: number) => Action & { payload: number } =
    (recipeId) => ({
      type: SELECT_RECIPE,
      payload: recipeId
    })

export const selectRecipeToDelete
  : (recipeId: null | string | number) => Action & { payload: null | string | number } =
    (recipeId) => ({
      type: SELECT_RECIPE_TO_DELETE,
      payload: recipeId
    })
