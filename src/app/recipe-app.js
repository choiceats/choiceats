import React, { Component } from 'react'
import { Route, Redirect, Switch, withRouter } from 'react-router-dom'
import styled from 'styled-components'

import { setUser, getUser, clearUser } from '../services/users'

import { Login } from '../pages/Login/Login.elm'
import { Navbar } from './components/Navbar.elm'
import { Randomizer } from '../pages/Randomizer/Randomizer.elm'
import { Signup } from '../pages/Signup/Signup.elm'
import Elm from '../pages/shared-components/react-elm/elm'
import RecipeEditorNew from '../pages/Recipes/recipe-editor-new.apollo'
import RecipeEditor from '../pages/Recipes/recipe-editor.apollo'
import * as R from '../pages/Recipes/RecipeDetail.elm'
import { Recipes } from '../pages/Recipes/RecipeSearch.elm'

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
        const { location, match } = this.props
        const { user = {} } = this.state
        let { token = '', userId = '' } = user

        if (token === null) {
            token = ''
        }

        const isRestrictedPath =
            NON_RESTRICTED_PATHS.indexOf(location.pathname) === -1

        const DecoratedRecipeEditor = props => {
            return <RecipeEditor userId={userId} {...props} />
            /*Maybe missing tags information, or an id maybe is an string that should be an int, or vice versa? Certain updates fail graphql schema validation on the backend*/
        }

        const getRecipeIdFromMatch = match =>
            (match &&
                match.params &&
                match.params.recipeId &&
                parseInt(match.params.recipeId, 10)) ||
            0

        if (token === '' && isRestrictedPath) {
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
                                token.length > 0 ? (
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
                            component={RecipeEditorNew}
                        />
                        <Route
                            path={`${match.url}recipe/:recipeId/edit`}
                            render={DecoratedRecipeEditor}
                        />
                        <Route
                            path={`${match.url}recipe/:recipeId`}
                            component={props => (
                                <Elm
                                    src={R.Recipes.RecipeDetail}
                                    flags={{
                                        token,
                                        userId: parseInt(userId, 10) || 0,
                                        recipeId: getRecipeIdFromMatch(
                                            props.match
                                        )
                                    }}
                                />
                            )}
                        />

                        <Route
                            path="/"
                            component={() => (
                                <Elm
                                    src={Recipes.RecipeSearch}
                                    flags={{
                                        token: token,
                                        userId: userId,
                                        isLoggedIn: !!token
                                    }}
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
    height: calc(100vh - ${HEADER_HEIGHT}px);
    overflow: auto;
    padding: 20px;
`
