// @flow
import React from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import FlatButton from 'material-ui/FlatButton'

import { logout } from '../../state/action-creators'

import type { WithRouter, Connected } from '../../types'

type LogoutButtonProps = WithRouter | Connected;

export const LogoutButton = ({history, dispatch}: LogoutButtonProps) => {
  const onClick = () => {
    dispatch(logout())
    history.push('/login')
  }

  return (
    <FlatButton
      onClick={onClick}
      label='Logout' />
  )
}

export default withRouter(connect()(LogoutButton))
