// @flow
import { LOGOUT, LOGIN } from './action-types'

export const logout = () => {
  return {
    type: LOGOUT
  }
}

export const login = () => {
  return {
    type: LOGIN
  }
}
