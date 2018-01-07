import React, { Component } from 'react'
import { Route, Redirect, Switch, withRouter } from 'react-router-dom'
import styled from 'styled-components'

import { Login } from '../pages/Login/Login.elm'
import RecipeList from '../pages/Recipes'
import { Navbar } from './components/Navbar.elm'
import { Randomizer } from '../pages/randomizer/Randomizer.elm'
import { Signup } from '../pages/Signup/Signup.elm'
import Elm from '../pages/shared-components/react-elm/elm'
import { setUser, getUser, clearUser } from '../services/users'

const NON_RESTRICTED_PATHS = ['/login', '/login/sign-up']
const HEADER_HEIGHT = 50

export class RecipeApp extends Component {
  constructor() {
    super()

    const userState = getUser()

    this.state = {
      user: userState,
      ports: null
    }
  }

  render() {
    const { location } = this.props
    const { user = {} } = this.state

    const isRestrictedPath =
      NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1

    const DecoratedRecipeList = props => {
      return (
        <RecipeList userId={user.userId} token={user.token || ''} {...props} />
      )
    }

    if (user.token === null && isRestrictedPath) {
      return <Redirect to="/login" />
    }

    return (
      <AppContainer>
        <Elm
          src={Navbar}
          flags={{ headerHeight: HEADER_HEIGHT.toString() }}
          ports={this.setupNavbarPorts.bind(this)}
        />
        <TopRouteContainer>
          <Switch>
            <Route
              exact
              path="/login/sign-up"
              component={() =>
                user.token && user.token.length > 0 ? (
                  <Redirect to="/" />
                ) : (
                  <Elm
                    src={Signup}
                    flags={{ token: user.token || '' }}
                    ports={this.setupSignupPorts.bind(this)}
                  />
                )
              }
            />
            <Route
              exact
              path="/login"
              component={() => (
                <Elm
                  src={Login}
                  flags={{ user: user.token || '' }}
                  ports={this.setupLoginPorts.bind(this)}
                />
              )}
            />
            <Route
              exact
              path="/random"
              component={() => (
                <Elm src={Randomizer} flags={{ user: user.token || '' }} />
              )}
            />
            <Route path="/" render={DecoratedRecipeList} />
          </Switch>
        </TopRouteContainer>
      </AppContainer>
    )
  }

  onClickLogoutHandler() {
    const { history } = this.props

    clearUser()

    this.setState(() => ({ user: null }))
    this.updateElmHeader.call(this, 'false')

    history.push('/login')
  }

  setupSignupPorts(ports) {
    ports.recordSignup.subscribe(sessionString => {
      const user = JSON.parse(sessionString)

      setUser(user)

      this.setState(() => ({ user }))
      this.updateElmHeader.call(this, 'true')

      window.location.href = '/'
    })
  }

  setupLoginPorts(ports) {
    ports.recordLogin.subscribe(sessionString => {
      const user = JSON.parse(sessionString)

      setUser(user)

      this.setState(() => ({ userToken: user.token }))
      this.updateElmHeader.call(this, 'true')

      window.location.href = '/'
    })
  }

  setupNavbarPorts(ports) {
    var self = this
    this.setState.call(this, () => ({ ports }))

    ports.requestLogout.subscribe(() => self.onClickLogoutHandler.call(self))

    ports.readReactState.send(
      this.state.user && this.state.user.token ? 'true' : 'false'
    )
  }

  updateElmHeader(userTokenBoolString) {
    if (this.state && this.state.ports) {
      this.state.ports.readReactState.send.call(this, userTokenBoolString)
    }
  }
}

export default withRouter(RecipeApp)

const AppContainer = styled.div`
  display: flex;
  height: 100vh;
  width: 100vw;
  flex-direction: column;
`

const TopRouteContainer = styled.div`
  height: calc(100vh - ${HEADER_HEIGHT}px);
  overflow: auto;
  padding: 20px;
`
