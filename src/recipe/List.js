// @flow
import React, { Component } from 'react'
import { gql, graphql } from 'react-apollo'
import styled from 'styled-components'

import type { RecipeListProps } from './types'

import { Recipe } from './Recipe'

export class RecipeList extends Component {
  props: RecipeListProps;

  render () {
    const { data } = this.props
    if (!data) return <Loading>loading</Loading>

    const { recipes, loading } = data
    if (loading) {
      return <Loading>loading..</Loading>
    }

    if (recipes) {
      return (
        <ListContainer>
          <List>
            { recipes.map(recipe => <Recipe key={recipe.id} recipe={recipe} />) }
          </List>
        </ListContainer>
      )
    }
  }
}

const List = styled.div``

export const Loading = styled.div`
  width: 100%;
  font-size: 36px;
  font-family: sans-serif;
  text-align: center;
  padding: 20px 40px;
  border: 1px solid #224466;
  background-color: salmon;
`

const ListContainer = styled.div``

const recipeQuery = gql`
  query RecipeQuery {
    recipes {
      id
      author
      ingredients
      instructions
      name
    }
  }
`

const ConnectedRecipes = graphql(recipeQuery)(RecipeList)
export { ConnectedRecipes }
