// @flow
import React, { Component } from 'react'
import { Route, Switch } from 'react-router-dom'
import styled from 'styled-components'

import RecipeSearch from './recipe-search'
import RecipeDetail from './recipe-detail.apollo'
import RecipeEditor from './recipe-editor.apollo'
import RecipeEditorNew from './recipe-editor-new.apollo'

export default class RecipeRoute extends Component {
  render() {
    const { match } = this.props
    return (
      <RecipesBody>
        <RecipesContent>
          <Switch>
            <Route
              path={`${match.url}recipe/new`}
              component={RecipeEditorNew}
            />
            <Route
              path={`${match.url}recipe/:recipeId/edit`}
              component={RecipeEditor}
            />
            <Route
              path={`${match.url}recipe/:recipeId`}
              component={RecipeDetail}
            />
            <Route path={match.url} component={RecipeSearch} />
          </Switch>
        </RecipesContent>
      </RecipesBody>
    )
  }
}

const RecipesBody = styled.div`
  padding: 0 25px;
  margin: auto;
  max-width: 1000px;
  margin-top: 10px;
`
const RecipesContent = styled.div`margin-top: 25px;`
