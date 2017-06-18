// @flow
import React, { Component } from 'react'
import { gql, graphql } from 'react-apollo'
import { connect } from 'react-redux'
import styled from 'styled-components'

import Recipe from './recipe'

import RecipeEditor from './recipe-editor'

import type { Recipe as TRecipe } from 'types'

type RecipeListProps = {
  data?: {
    loading: string;
    error: string;
    recipes: TRecipe[];
  },
  userId: string;
  isLoggedIn: boolean;
}

const mapStateToProps = (state) => {
  return {
    isLoggedIn: state.user.token,
    userId: state.user.userId
  }
}

export class RecipeList extends Component {
  props: RecipeListProps;

  render () {
    const { data, isLoggedIn } = this.props
    if (!data) return <Loading>loading</Loading>

    const { recipes, loading } = data
    if (loading) {
      return <Loading>loading..</Loading>
    }

    if (recipes) {
      return (
        <ListContainer>
          <RecipeEditor recipe={null} />
          <List>
            { recipes.map(recipe => (
              <Recipe key={recipe.id}
                recipe={recipe}
                allowEdits
                isLoggedIn={isLoggedIn} />
            )) }
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

const ListContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
`

const recipeQuery = gql`
  query RecipeQuery {
    recipes {
      id
      author
      authorId
      ingredients {
        name
        unit {
          name
          abbr
        }
        quantity
      }
      instructions
      name
    }
  }
`

export default connect(mapStateToProps)(graphql(recipeQuery)(RecipeList))
