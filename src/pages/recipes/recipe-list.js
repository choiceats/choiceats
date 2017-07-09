// @flow
import React, { Component } from 'react'
import { gql, graphql } from 'react-apollo'
import { connect } from 'react-redux'
import styled, { keyframes } from 'styled-components'

import Recipe from './recipe'

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
    const {
      data,
      isLoggedIn,
      userId
    } = this.props
    if (!data) return <Loading>loading</Loading>

    const { recipes, loading } = data
    if (loading) {
      return <Loading>LOADING..</Loading>
    }

    if (recipes) {
      return (
        <ListContainer>
          { recipes.map(recipe => (
            <Recipe key={recipe.id}
              recipe={recipe}
              allowEdits
              likes={3}
              youLike={false}
              userId={userId}
              isLoggedIn={isLoggedIn} />
            )) }
        </ListContainer>
      )
    }
  }
}

const slideIn = keyframes`
from {
  margin-left: 100%;
}

to {
  margin-left: 0%;
}
`

export const Loading = styled.div`
`

const ListContainer = styled.div`
  animation: ${slideIn} .5s linear;
  padding-top: 30px;
  width: 500px;
  margin: auto;
`

const recipeQuery = gql`
  query RecipeQuery {
    recipes {
      id
      author
      authorId
      description
      imageUrl
      name
      likes
    }
  }
`

export default connect(mapStateToProps)(graphql(recipeQuery)(RecipeList))
