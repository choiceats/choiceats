// @flow
import React from 'react'
import AppBar from 'material-ui/AppBar'

import Logout from '../account/logout-button'
import Login from '../account/login-button'

import type { Connected } from '../types'

type NavbarProps = Connected & {
  isLoggedIn: boolean
}

const Navbar = ({isLoggedIn}: NavbarProps) => {
  return (
    <AppBar
      title='ChoicEats'
      iconElementRight={
        isLoggedIn
          ? <Logout />
          : <Login />
      } />
  )
}

export default Navbar
