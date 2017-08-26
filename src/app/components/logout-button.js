// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { Button } from 'semantic-ui-react'

import { logout } from '../../state/action-creators'

import type { ContextRouter } from 'react-router-dom'
import type { ConnectedProps } from 'types'

type PROPS = ConnectedProps & ContextRouter

export class LogoutButton extends Component<PROPS> {
  onClick: () => void

  constructor(props: ConnectedProps & ContextRouter) {
    super(props)
    this.onClick = this._onClick.bind(this)
  }

  render() {
    return <Button onClick={this.onClick}>Logout</Button>
  }

  _onClick() {
    const { history, dispatch } = this.props
    dispatch(logout())
    history.push('/login')
  }
}

export default withRouter(connect()(LogoutButton))
