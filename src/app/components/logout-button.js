// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import FlatButton from 'material-ui/FlatButton'

import { logout } from '../../state/action-creators'

import type { ContextRouter } from 'react-router-dom'
import type { ConnectedProps } from 'types'

type LogoutButtonProps = ContextRouter & ConnectedProps

class LogoutButton extends Component {
  props: LogoutButtonProps

  render () {
    const { history, dispatch } = this.props
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
}

export default withRouter(connect()(LogoutButton))
