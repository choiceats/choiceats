// @flow
import React from 'react'
import { Link } from 'react-router-dom'

import { Button } from 'semantic-ui-react'

const LoginButton = () => (
  <Link to='/login'>
    <Button>Login</Button>
  </Link>
)

export default LoginButton
