import React from 'react'
import { connect } from 'react-redux'
import AppBar from 'material-ui/AppBar'

import { Logout } from './account/logout-button'
import { Login } from './account/login-button'


export const ApplicationBar = ({userToken}) => {
  console.log('USER TOKEN')
  const isLoggedIn = userToken !== null
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

const mapStateToProps = (state) => {
  return {
    userToken: state.user.token
  }
}

export default connect(mapStateToProps)(ApplicationBar)
