// @flow
import React from 'react'
import { Link } from 'react-router-dom'
import FlatButton from 'material-ui/FlatButton'

const LoginButton = () => (
  <Link to='/login'>
    <FlatButton label='Login' />
  </Link>
)

export default LoginButton
