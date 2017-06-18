// @flow
import { LOGOUT, LOGIN } from './action-types'
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

export const login = (userInfo: User) => {
  return {
    type: LOGIN,
    payload: userInfo
  }
}
