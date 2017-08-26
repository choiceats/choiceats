// @flow
import React, { Component } from 'react'
import { ApolloProvider } from 'react-apollo'
import { BrowserRouter as Router } from 'react-router-dom'
import { createStore, combineReducers, applyMiddleware, compose } from 'redux'

import { client } from '../services/apollo-client'
import { user, ui } from '../state/reducers'

import RecipeApp from './recipe-app'

const store = createStore(
  combineReducers({
    user,
    ui,
    apollo: client.reducer()
  }),
  {},
  compose(
    applyMiddleware(client.middleware()),
    typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined'
      ? window.__REDUX_DEVTOOLS_EXTENSION__()
      : f => f
  )
)

class App extends Component<*> {
  render() {
    return (
      <ApolloProvider store={store} client={client}>
        <Router>
          <RecipeApp />
        </Router>
      </ApolloProvider>
    )
  }
}

export default App
