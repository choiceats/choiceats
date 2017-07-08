// @flow
import React, { Component } from 'react'
import { Route } from 'react-router-dom'

import RecipeList from './recipe-list'
import RecipeDetail from './recipe-detail'
import RecipeEditor from './recipe-editor'

export default class RecipeRoute extends Component {
  render () {
    const { match } = this.props
    return (
      <div>
        <Route path={`${match.url}recipe/:recipeId/edit`} exact component={RecipeEditor} />
        <Route path={`${match.url}recipe/:recipeId`} exact component={RecipeDetail} />
        <Route path={match.url} exact component={RecipeList} />
      </div>
    )
  }
}
