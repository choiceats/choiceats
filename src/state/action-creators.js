// @flow
import { LOGOUT } from './action-types'

export const logout = () => {
  return {
    type: LOGOUT,
    payload: null
  }
}
