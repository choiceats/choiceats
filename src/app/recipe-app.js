import React, { Component } from 'react'
import { Route, Redirect, Switch, withRouter } from 'react-router-dom'
import styled from 'styled-components'

import { setUser, getUser, clearUser } from '../services/users'

import { Login } from '../pages/Login/Login.elm'
import { Navbar } from './components/Navbar.elm'
import { Randomizer } from '../pages/Randomizer/Randomizer.elm'
import { Signup } from '../pages/Signup/Signup.elm'
import Elm from '../pages/shared-components/react-elm/elm'
import RecipeEditor from '../pages/RecipeEditor/RecipeEditor.elm'
import * as R from '../pages/Recipes/RecipeDetail.elm'
import { Recipes } from '../pages/Recipes/RecipeSearch.elm'

const NON_RESTRICTED_PATHS = ['/login', '/login/sign-up']
const headerHeight = '50'

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
    const { location, match } = this.props

    let { user = {} } = this.state
    if (user === null) {
      user = {};
    }

    let { token = '', userId = '' } = user

    if (token === null) {
      token = ''
    }

    const taco = { token, userId } // see https://github.com/ohanhi/elm-taco for naming :)

    const isRestrictedPath =
      NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1

    const getRecipeId = match =>
      (match &&
        match.params &&
        match.params.recipeId &&
        parseInt(match.params.recipeId, 10)) ||
      undefined

    const makeRecipeTaco = match => ({
      ...taco,
      recipeId: getRecipeId(match) || -1
    })

    if (token === '' && isRestrictedPath) {
      return <Redirect to="/login" />
    }

    return (
      <AppContainer>
        <Elm
          src={Navbar}
          flags={{ headerHeight }}
          ports={this.setupNavbarPorts.bind(this)}
        />
        <TopRouteContainer>
          <Switch>
            <Route
              exact
              path="/login/sign-up"
              component={() =>
                token.length ? (
                  <Redirect to="/" />
                ) : (
                    <Elm
                      src={Signup}
                      flags={{ token }}
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
                  flags={{ token }}
                  ports={this.setupLoginPorts.bind(this)}
                />
              )}
            />
            <Route
              exact
              path="/random"
              component={() => (
                <Elm src={Randomizer} flags={{ token }} />
              )}
            />
            <Route
              path={`${match.url}recipe/new`}
              component={props => (
                <Elm
                  src={RecipeEditor.RecipeEditor}
                  flags={{ ...makeRecipeTaco(props.match) }}
                />
              )}
            />
            <Route
              path={`${match.url}recipe/:recipeId/edit`}
              component={props => (
                <Elm
                  src={RecipeEditor.RecipeEditor}
                  flags={{ ...makeRecipeTaco(props.match) }}
                />
              )}
            />
            <Route
              path={`${match.url}recipe/:recipeId`}
              component={props => (
                <Elm
                  src={R.Recipes.RecipeDetail}
                  flags={{ ...makeRecipeTaco(props.match) }}
                />
              )}
            />

            <Route
              path="/"
              component={() => (
                <Elm
                  src={Recipes.RecipeSearch}
                  flags={{ ...taco }}
                />
              )}
            />
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

      let { token = '' } = user

      if (token === null) {
        token = ''
      }

      setUser(user)

      this.setState(() => ({ userToken: user.token }))
      this.updateElmHeader.call(this, 'true')

      window.location.href = '/'
    })
  }

  setupNavbarPorts(ports) {
    var self = this
    this.setState.call(this, () => ({ ports }))

    ports.requestLogout.subscribe(() =>
      self.onClickLogoutHandler.call(self)
    )

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
    height: calc(100vh - ${headerHeight}px);
    overflow: auto;
    padding: 20px;
`
