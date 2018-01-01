// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Route, Redirect, Switch, withRouter } from 'react-router-dom'
import styled from 'styled-components'

import Login from '../pages/login'
import RecipeList from '../pages/Recipes'
import { Navbar } from './components/Navbar.elm'
import { Randomizer } from '../pages/randomizer/Randomizer.elm'
import { Signup } from '../pages/Signup/Signup.elm'
import Elm from '../pages/shared-components/react-elm/elm'
import { logout } from '../state/action-creators'
import { setUser } from '../services/users'

const NON_RESTRICTED_PATHS = ['/login', '/login/sign-up']
const HEADER_HEIGHT = 50

type PROPS = any

type PORTS = {
  requestLogout: {
    subscribe: any,
    unsubscribe: any
  },

  readReactState: {
    send: (msg: string) => any
  },

  recordSignup: {
    subscribe: any
  }
}

type STATE = {
  ports: ?PORTS
}

export class RecipeApp extends Component<PROPS, STATE> {
  componentWillReceiveProps(newProps: PROPS) {
    if (newProps.userToken !== this.props.userToken) {
      this.updateElmHeader.call(this, this.props.userToken ? 'true' : 'false')
    }
  }

  render() {
    const { userToken, location } = this.props
    const isRestrictedPath =
      NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1
    if (userToken === null && isRestrictedPath) {
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
                userToken && userToken.length > 0 ? (
                  <Redirect to="/" />
                ) : (
                  <Elm
                    src={Signup}
                    flags={{ token: userToken || '' }}
                    ports={this.setupSignupPorts.bind(this)}
                  />
                )
              }
            />
            <Route exact path="/login" component={Login} />
            <Route
              exact
              path="/random"
              component={() => (
                <Elm src={Randomizer} flags={{ token: userToken || '' }} />
              )}
            />
            <Route path="/" component={RecipeList} />
          </Switch>
        </TopRouteContainer>
      </AppContainer>
    )
  }

  onClickLogoutHandler() {
    const { history, dispatch } = this.props
    dispatch(logout())
    history.push('/login')
  }

  setupSignupPorts(ports: PORTS) {
    ports.recordSignup.subscribe(a => {
      setUser(JSON.parse(a))
      window.location.href = '/'
    })
  }

  setupNavbarPorts(ports: PORTS) {
    var self = this
    this.setState.call(this, () => ({ ports }: { ports: PORTS }))

    ports.requestLogout.subscribe(() => self.onClickLogoutHandler.call(self))

    ports.readReactState.send(this.props.userToken ? 'true' : 'false')
  }

  updateElmHeader(userTokenBoolString: 'true' | 'false') {
    if (this.state && this.state.ports) {
      this.state.ports.readReactState.send.call(this, userTokenBoolString)
    }
  }
}

export default withRouter(
  connect(state => ({
    userToken: state.user.token
  }))(RecipeApp)
)

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
