// @flow
import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'

import { logout } from '../state/action-creators'

export const Logout = connect()(withRouter(({history, dispatch}) => {
  return (
    <button onClick={() => {
      dispatch(logout())
      history.push('/login')
    }}>Logout</button>
  )
}))
