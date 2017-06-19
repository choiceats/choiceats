// @flow
import React from 'react'
import styled from 'styled-components'

import Logout from './logout-button'
import Login from './login-button'

type NavbarProps = {
  isLoggedIn: boolean
}

const Navbar = ({isLoggedIn}: NavbarProps) => {
  return (
    <AppBar>
      <AppBarLeftMenu />
      <AppBarTitleArea>
        <Title>ChoicEats</Title>
      </AppBarTitleArea>
      <AppMenu>
        <Menu>
          { isLoggedIn
            ? <Logout />
            : <Login />
          }
        </Menu>
      </AppMenu>
    </AppBar>
  )
}

const AppBar = styled.div`
  display: grid;
  background-color: #b3e6ff;
  grid-template-columns: 40px auto 150px;
  grid-template-rows: 50px;
`

const AppBarTitleArea = styled.div`
  grid-column: 2 / 3;
  grid-row: 1 / 2;
`

const AppBarLeftMenu = styled.div`

`

const Title = styled.h1`
  height: 100%;
  padding: 7px;
`
const Menu = styled.div`
  padding: 7px;
`

const AppMenu = styled.div`
  grid-column: 3;
  justify-self: right;
`

export default Navbar
