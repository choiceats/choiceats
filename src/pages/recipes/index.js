// @flow
import React, { Component } from 'react'
import { Route, NavLink, Switch } from 'react-router-dom'
import { Breadcrumb } from 'semantic-ui-react'
import styled from 'styled-components'

import RecipeSearch from './recipe-search'
import RecipeDetail from './recipe-detail.apollo'
import RecipeEditor from './recipe-editor.apollo'
import RecipeEditorNew from './recipe-editor-new.apollo'

export default class RecipeRoute extends Component {
  render () {
    const { match } = this.props
    return (
      <RecipesBody>
        <Breadcrumb>
          { this.buildBreadcrumbSections() }
        </Breadcrumb>
        <RecipesContent>
          <Switch>
            <Route path={`${match.url}recipe/new`} component={RecipeEditorNew} />
            <Route path={`${match.url}recipe/:recipeId/edit`} component={RecipeEditor} />
            <Route path={`${match.url}recipe/:recipeId`} component={RecipeDetail} />
            <Route path={match.url} component={RecipeSearch} />
          </Switch>
        </RecipesContent>
      </RecipesBody>
    )
  }

  buildBreadcrumbSections (): Array<React.Element<*>> {
    const { pathname } = this.props.location
    const breadcrumbs = []
    breadcrumbs.push(
      <Breadcrumb.Section key={breadcrumbs.length}>
        <NavLink to='/'>Recipe List</NavLink>
      </Breadcrumb.Section>
    )

    const parts = pathname.split('/').splice(1)
    if (pathname.indexOf('recipe') > -1) {
      const navTo = `/recipe/${parts[1]}`
      breadcrumbs.push(<Breadcrumb.Divider icon='right angle' key={breadcrumbs.length} />)
      breadcrumbs.push(
        <Breadcrumb.Section key={breadcrumbs.length}>
          <NavLink to={navTo}>Recipe</NavLink>
        </Breadcrumb.Section>
      )
    }

    if (pathname.indexOf('new') > -1) {
      const navTo = `/recipe/new`
      breadcrumbs.push(<Breadcrumb.Divider icon='right angle' key={breadcrumbs.length} />)
      breadcrumbs.push(
        <Breadcrumb.Section key={breadcrumbs.length}>
          <NavLink to={navTo}>New</NavLink>
        </Breadcrumb.Section>
      )
    }

    if (pathname.indexOf('edit') > -1) {
      const navTo = `/recipe/${parts[1]}/edit`
      breadcrumbs.push(<Breadcrumb.Divider icon='right angle' key={breadcrumbs.length} />)
      breadcrumbs.push(
        <Breadcrumb.Section key={breadcrumbs.length}>
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
