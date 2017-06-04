// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Route, Redirect, withRouter } from 'react-router-dom'

import { Account } from '../account'
import { ConnectedRecipes } from '../recipe/list'
import Navbar from './navbar'

import type { Connected, WithRouter } from '../types'

const NON_RESTRICTED_PATHS = [
  '/login',
  '/login/sign-up'
]

type RecipeAppProps = Connected & WithRouter & {
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
        <Route exact path='/' component={ConnectedRecipes} />
        <Route path='/login' component={Account} />
      </div>
    )
  }
}

export default withRouter(connect((state) => ({
  userToken: state.user.token
}))(RecipeApp))
