// @flow
import { LOGIN, LOGOUT } from './action-types'
import { getUser, clearUser } from '../services/users'

type UserState = {
  token: ?string,
  name: ?string,
  email: ?string,
  userId: ?number
}

type UserAction = {
  type: string;
  payload: mixed;
}

export const user = (state: UserState = { ...getUser() }, action: UserAction) => {
  switch (action.type) {
    case LOGIN:
      return { ...action.payload }

    case LOGOUT:
      clearUser()
      return {
        token: null,
        name: null,
        email: null,
        userId: null
      }

    default:
      return state
  }
}
