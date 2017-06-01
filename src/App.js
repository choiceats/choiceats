// @flow
import React, { Component } from 'react'
import { ApolloProvider } from 'react-apollo'
import {
  BrowserRouter as Router,
  Route
 } from 'react-router-dom'
import { createStore, combineReducers, applyMiddleware, compose } from 'redux'

import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider'

import { Account } from './account'
import { client } from './services/apollo-client'
import { ConnectedRecipes } from './recipe/List'
import { userReducer } from './state/reducers'

import ApplicationBar from './application-bar'


const store = createStore(
  combineReducers({
    user: userReducer,
    apollo: client.reducer()
  }),
  {},
  compose(
      applyMiddleware(client.middleware()),
      (typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined') ? window.__REDUX_DEVTOOLS_EXTENSION__() : f => f
  )
)


class App extends Component {
  render () {
    return (
      <ApolloProvider store={store} client={client}>
        <MuiThemeProvider>
          <Router>
            <div>
              <ApplicationBar />
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
