// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Route, Redirect, Switch, withRouter } from 'react-router-dom'
import styled from 'styled-components'

import Login from '../pages/login'
import Signup from '../pages/signup'
import RecipeList from '../pages/recipes'
import Randomizer from '../pages/randomizer'
import Navbar from './components/navbar'

import type { ContextRouter } from 'react-router-dom'
import type { ConnectedProps } from 'types'

const NON_RESTRICTED_PATHS = ['/login', '/login/sign-up']

type RecipeAppProps = ConnectedProps &
  ContextRouter & {
    userToken: string
  }

export class RecipeApp extends Component {
  props: RecipeAppProps

  render() {
    const { userToken, location } = this.props
    const isRestrictedPath =
      NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1
    if (userToken === null && isRestrictedPath) {
      return <Redirect to="/login" />
    }

    return (
      <AppContainer>
        <NavContainer>
          <Navbar isLoggedIn={userToken !== null} />
        </NavContainer>
        <TopRouteContainer>
          <Switch>
            <Route exact path="/login/sign-up" component={Signup} />
            <Route exact path="/login" component={Login} />
            <Route exact path="/random" component={Randomizer} />
            <Route path="/" component={RecipeList} />
          </Switch>
        </TopRouteContainer>
      </AppContainer>
    )
  }
}

export default withRouter(
  connect(state => ({
    userToken: state.user.token
  }))(RecipeApp)
)

const HEADER_HEIGHT = 50
const AppContainer = styled.div`
  display: flex;
  height: 100vh;
  width: 100vw;
  flex-direction: column;
`

const TopRouteContainer = styled.div`
  max-height: calc(100vh - ${HEADER_HEIGHT}px);
  overflow: auto;
  padding: 20px;
`
const NavContainer = styled.div`height: ${HEADER_HEIGHT}px;`
