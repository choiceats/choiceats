import React, { Component } from 'react'
import { clearToken } from '../services/users'

export class Logout extends Component {
  handleClick () {
    clearToken()
    window.location.reload()
  }

  render () {
    return <button onClick={() => this.handleClick()}>Logout</button>
  }
}
