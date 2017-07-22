// @flow
import {
  EDIT_RECIPE,
  SELECT_RECIPE,
  SELECT_RECIPE_TO_DELETE,
  SET_RECIPE_STATUS,
  SET_RECIPE_LIKE_STATUS,
  SUCCESS,
  PENDING
} from './action-types'
import { DEFAULT_UI_STATE } from '../defaults'
import type { Action } from 'types'

type UiState = {
  selectedRecipeId: ?number,
  editingRecipeId: ?number
}

export const ui: (UiState, Action & { payload: any }) => UiState = (
  state = DEFAULT_UI_STATE,
  action
) => {
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

    case SET_RECIPE_STATUS:
      return {
        ...state,
        recipeStatus:
          action.payload.status === SUCCESS
            ? {}
            : {
                id: action.payload.id,
                operation: action.payload.operation,
                status: action.payload.status || PENDING
              }
      }

    case SET_RECIPE_LIKE_STATUS:
      return {
        ...state,
        recipeLikeStatus:
          action.payload.status === SUCCESS
            ? {}
            : {
                id: action.payload.id,
                operation: action.payload.operation,
                status: action.payload.status || PENDING
              }
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
