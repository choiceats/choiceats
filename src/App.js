// @flow
import React, { Component } from 'react'
import { ApolloProvider } from 'react-apollo'
import { 
  BrowserRouter as Router,
  Route,
  Link
 } from 'react-router-dom'


import { Account } from './account'
import { client } from './services/apollo-client'
import { ConnectedRecipes } from './recipe/List'

class App extends Component {
  render () {
    return (
      <ApolloProvider client={client}>
        <Router>
          <div>
            <ul>
              <li><Link to='/'>Recipes</Link></li>
              <li><Link to='/login'>Login</Link></li>
            </ul>
          
            <hr />

            <Route exact path='/' component={ConnectedRecipes} />
            <Route path='/login' component={Account} />
          </div>
        </Router>
      </ApolloProvider>
    )
  }
}

export default App
