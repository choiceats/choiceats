// @flow
import { LOGIN, LOGOUT } from './action-types'
import { getToken, clearToken } from '../services/users'

type UserState = {
  token: ?string
}

type UserAction = {
  type: string;
  payload: mixed;
}

export const user = (state: UserState = { token: getToken() }, action: UserAction) => {
  switch (action.type) {
    case LOGIN:
      return { token: action.payload }

    case LOGOUT:
      clearToken()
      return { token: null }

    default:
      return state
  }
}
