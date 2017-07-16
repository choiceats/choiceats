// @flow
import React, { Component } from 'react'
import { gql, graphql, compose } from 'react-apollo'
import { connect } from 'react-redux'
import styled from 'styled-components'

import RecipeList from './recipe-list'

import type { Recipe as TRecipe } from 'types'

type RecipeListProps = {
  data?: {
    loading: string;
    error: string;
    recipes: TRecipe[];
  },
  userId: number;
  isLoggedIn: boolean;
  searchText: string;
}

export class RecipeListApollo extends Component {
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
        <RecipeList
          recipes={recipes}
          userId={userId}
          isLoggedIn={isLoggedIn} />
      )
    }
  }
}

const Loading = styled.div`
`
const recipesQuery = gql`
  query RecipeQuery($searchText: String) {
    recipes (searchText: $searchText) {
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

const options = ({searchText}) => ({
  variables: {
    searchText
  }
})

const mapStateToProps = (state) => {
  return {
    isLoggedIn: state.user.token,
    userId: state.user.userId
  }
}

export default connect(mapStateToProps)(compose(
  graphql(recipesQuery, { options })
)(RecipeListApollo))
