// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Route, Redirect, withRouter } from 'react-router-dom'

import Login from '../pages/login'
import Signup from '../pages/signup'
import RecipeList from '../pages/recipes'
import Navbar from './components/navbar'

import type { ContextRouter } from 'react-router-dom'
import type { ConnectedProps } from 'types'

const NON_RESTRICTED_PATHS = [
  '/login',
  '/login/sign-up'
]

type RecipeAppProps = ConnectedProps & ContextRouter & {
  userToken: string
}

export class RecipeApp extends Component {
  props: RecipeAppProps

  render () {
    const { userToken, location } = this.props
    const isRestrictedPath = NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1
    if (userToken === null && isRestrictedPath) {
      return <Redirect to='/login' />
    }

    return (
      <div>
        <Navbar isLoggedIn={userToken !== null} />
        <Route exact path='/' component={RecipeList} />

        <Route path='/login/sign-up' component={Signup} />
        <Route exact path='/login' component={Login} />
      </div>
    )
  }
}

export default withRouter(connect((state) => ({
  userToken: state.user.token
}))(RecipeApp))
