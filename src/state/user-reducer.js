// @flow
import { LOGIN } from './action-types'

type UserState = {
  token: ?string
}

type UserAction = {
  type: string;
  payload: mixed;
}

export const userReducer = (state: UserState = { token: null }, action: UserAction) => {
  switch (action.type) {
    case LOGIN:
      return { token: action.payload }

    default:
      return state
  }
}
