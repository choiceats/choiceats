// @flow
import { SELECT_RECIPE } from './action-types'
import { DEFAULT_UI_STATE } from '../defaults'
import type { Action } from 'types'

type UiState = {
  selectedRecipeId: ?number
}

export const ui
  : (UiState, Action & { payload: number }) => UiState =
    (state = DEFAULT_UI_STATE, action) => {
      switch (action.type) {
        case SELECT_RECIPE:
          return { selectedRecipeId: action.payload }
      }
      return state
    }
