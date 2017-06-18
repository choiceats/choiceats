// @flow
import React from 'react'
import AppBar from 'material-ui/AppBar'

import Logout from './logout-button'
import Login from './login-button'

type NavbarProps = {
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
