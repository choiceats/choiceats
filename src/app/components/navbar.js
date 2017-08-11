// @flow
import React from 'react'
import { Menu } from 'semantic-ui-react'
import { Link } from 'react-router-dom'

import Logout from './logout-button'
import Login from './login-button'

type NavbarProps = {
  isLoggedIn: boolean
}

const Navbar = ({ isLoggedIn }: NavbarProps) => {
  return (
    <Menu secondary>
      <Menu.Item header>ChoicEats</Menu.Item>
      <Menu.Item>
        <Link to="/">Recipes</Link>
      </Menu.Item>
      <Menu.Item>
        <Link to="/random">Ideas</Link>
      </Menu.Item>
      <Menu.Menu position="right">
        <Menu.Item>
          {isLoggedIn ? <Logout /> : <Login />}
        </Menu.Item>
      </Menu.Menu>
    </Menu>
  )
  // return (
  //   <AppBar>
  //     <AppBarLeftMenu />
  //     <AppBarTitleArea>
  //       <Title>ChoicEats</Title>
  //     </AppBarTitleArea>
  //     <AppMenu>
  //       <Menu>
  //         { isLoggedIn
  //           ? <Logout />
  //           : <Login />
  //         }
  //       </Menu>
  //     </AppMenu>
  //   </AppBar>
  // )
}

export default Navbar
