// @flow
import React, { Component } from 'react'
import { Route, NavLink } from 'react-router-dom'
import { Breadcrumb } from 'semantic-ui-react'
import styled from 'styled-components'

import RecipeList from './recipe-list'
import RecipeDetail from './recipe-detail'
import RecipeEditor from './recipe-editor'

export default class RecipeRoute extends Component {
  render () {
    const { match } = this.props
    return (
      <RecipesBody>
        <Breadcrumb>
          { this.buildBreadcrumbSecions() }
        </Breadcrumb>
        <RecipesContent>
          <Route path={`${match.url}recipe/:recipeId/edit`} exact component={RecipeEditor} />
          <Route path={`${match.url}recipe/:recipeId`} exact component={RecipeDetail} />
          <Route path={match.url} exact component={RecipeList} />
        </RecipesContent>
      </RecipesBody>
    )
  }

  buildBreadcrumbSecions () {
    const { pathname } = this.props.location
    const breadcrumbs = []
    breadcrumbs.push(
      <Breadcrumb.Section>
        <NavLink to='/'>Recipe List</NavLink>
      </Breadcrumb.Section>
    )

    const parts = pathname.split('/').splice(1)
    if (pathname.indexOf('recipe') > -1) {
      const navTo = `/recipe/${parts[1]}`
      breadcrumbs.push(<Breadcrumb.Divider icon='right angle' />)
      breadcrumbs.push(
        <Breadcrumb.Section>
          <NavLink to={navTo}>Recipe</NavLink>
        </Breadcrumb.Section>
      )
    }

    if (pathname.indexOf('edit') > -1) {
      const navTo = `/recipe/${parts[1]}/edit`
      breadcrumbs.push(<Breadcrumb.Divider icon='right angle' />)
      breadcrumbs.push(
        <Breadcrumb.Section>
          <NavLink to={navTo}>Edit</NavLink>
        </Breadcrumb.Section>
      )
    }

    return breadcrumbs
  }
}

const RecipesBody = styled.div`
  padding: 0 25px;
  margin: auto;
  max-width: 1000px;
  margin-top: 10px;
`
const RecipesContent = styled.div`
  margin-top: 25px;
`
