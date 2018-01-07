import React, { Component } from 'react'
import { Route, Switch } from 'react-router-dom'
import styled from 'styled-components'

import Elm from '../shared-components/react-elm/elm'
import { Recipes } from './RecipeSearch.elm'
import RecipeDetail from './recipe-detail.apollo'
import RecipeEditor from './recipe-editor.apollo'
import RecipeEditorNew from './recipe-editor-new.apollo'

export default class RecipeRoute extends Component<PROPS, void> {
  render() {
    const { match, userId = null, token = '' } = this.props

    const DecoratedRecipeEditor = props => {
      return <RecipeEditor userId={userId} {...props} />
    }

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
              render={DecoratedRecipeEditor}
            />
            <Route
              path={`${match.url}recipe/:recipeId`}
              component={RecipeDetail}
            />
            <Route
              path={match.url}
              component={() => (
                <Elm
                  src={Recipes.RecipeSearch}
                  flags={{ token: token, userId: userId, isLoggedIn: !!token }}
                />
              )}
            />
          </Switch>
        </RecipesContent>
      </RecipesBody>
    )
  }
}

const RecipesBody = styled.div`
  margin: auto;
  max-width: 1000px;
  margin-top: 10px;
`
const RecipesContent = styled.div`
  margin-top: 25px;
`
