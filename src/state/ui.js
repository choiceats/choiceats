// @flow
import {
  EDIT_RECIPE,
  SELECT_RECIPE,
  SELECT_RECIPE_TO_DELETE
} from './action-types'
import { DEFAULT_UI_STATE } from '../defaults'
import type { Action } from 'types'

type UiState = {
  selectedRecipeId: ?number,
  editingRecipeId: ?number
}

export const ui
  : (UiState, Action & { payload: number }) => UiState =
    (state = DEFAULT_UI_STATE, action) => {
      switch (action.type) {
        case SELECT_RECIPE:
          return {
            ...state,
            selectedRecipeId: action.payload
          }

        case SELECT_RECIPE_TO_DELETE:
          return {
            ...state,
            recipeIdToDelete: action.payload
          }

        case EDIT_RECIPE:
          return {
            ...state,
            editingRecipeId: action.payload
          }
        default:
          return state
      }
    }
