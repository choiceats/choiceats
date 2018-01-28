import React, { Component } from 'react'
import { BrowserRouter as Router } from 'react-router-dom'

import RecipeApp from './recipe-app'

class App extends Component<*> {
  render() {
    return (
      <Router>
        <RecipeApp />
      </Router>
    )
  }
}

export default App
