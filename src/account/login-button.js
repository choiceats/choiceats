import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import FlatButton from 'material-ui/FlatButton'

export class Login extends Component {
  static muiName = 'FlatButton';
  render () {
    return (
      <Link to='/login'>
        <FlatButton label='Login' />
      </Link>
    )
  }
}
