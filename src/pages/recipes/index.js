// @flow
import React, { Component } from 'react'
import { gql, graphql } from 'react-apollo'
import { connect } from 'react-redux'
import styled from 'styled-components'

import Recipe from './recipe'

// import RecipeEditor from './components/recipe-editor'

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
          {/* <RecipeEditor recipe={null} /> */}
          <ListColumn>
            { recipes.filter((r, i) => i % 3 === 0).map(recipe => (
              <Recipe key={recipe.id}
                recipe={recipe}
                allowEdits
                isLoggedIn={isLoggedIn} />
            )) }
          </ListColumn>
          <ListColumn>
            { recipes.filter((r, i) => i % 3 === 1).map(recipe => (
              <Recipe key={recipe.id}
                recipe={recipe}
                allowEdits
                isLoggedIn={isLoggedIn} />
            )) }
          </ListColumn>
          <ListColumn>
            { recipes.filter((r, i) => i % 3 === 2).map(recipe => (
              <Recipe key={recipe.id}
                recipe={recipe}
                allowEdits
                isLoggedIn={isLoggedIn} />
            )) }
          </ListColumn>
        </ListContainer>
      )
    }
  }
}

const ListColumn = styled.div`
  display: flex;
  flex-direction: column;
  width: 32%;
`

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
  padding-top: 30px;
  display: flex;
  justify-content: space-around;
`

const recipeQuery = gql`
  query RecipeQuery {
    recipes {
      id
      author
      authorId
      description
      imageUrl
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
