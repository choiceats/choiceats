// @flow
import { LOGOUT, LOGIN } from './action-types'
import type { User } from 'types'

export const logout = () => {
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
