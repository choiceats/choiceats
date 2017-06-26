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
  payload: UserState;
}

export const user
  : (UserState, UserAction) => UserState =
    (state = { ...getUser() }, action) => {
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
