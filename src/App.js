// @flow
import React, { Component } from 'react'
import { ApolloProvider } from 'react-apollo'
import {
  BrowserRouter as Router,
  Route,
  Link
 } from 'react-router-dom'

import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'
import AppBar from 'material-ui/AppBar'
import FlatButton from 'material-ui/FlatButton'

import { Account } from './account'
import { client } from './services/apollo-client'
import { ConnectedRecipes } from './recipe/List'


class Login extends Component {
  static muiName = 'FlatButton';
  render () {
    return (
      <Link to='/login'>
        <FlatButton label='Login' />
      </Link>
    )
  }
}

class App extends Component {
  state = { logged: false }
  render () {
    return (
      <ApolloProvider client={client}>
        <MuiThemeProvider>
          <Router>
            <div>
              <AppBar
                title='ChoicEats'
                iconElementRight={this.state.logged ? <div /> : <Login />}
                />
              <Route exact path='/' component={ConnectedRecipes} />
              <Route path='/login' component={Account} />
            </div>
          </Router>
        </MuiThemeProvider>
      </ApolloProvider>
    )
  }
}

export default App
