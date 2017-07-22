// @flow
import React, { Component } from 'react'
import { gql, graphql, compose } from 'react-apollo'
import { connect } from 'react-redux'

import RecipeList from './recipe-list'
import Loading from '../shared-components/loading'

import type { Recipe as TRecipe } from 'types'

type RecipeListProps = {
  data?: {
    loading: string,
    error: string,
    recipes: TRecipe[]
  },
  userId: number,
  isLoggedIn: boolean,
  searchText: string
}

export class RecipeListApollo extends Component {
  props: RecipeListProps

  render() {
    const { data, isLoggedIn, userId } = this.props
    if (!data) return <Loading />

    const { recipes, loading } = data
    if (loading) {
      return <Loading />
    }

    if (recipes) {
      return (
        <RecipeList recipes={recipes} userId={userId} isLoggedIn={isLoggedIn} />
      )
    }
  }
}

const recipesQuery = gql`
  query RecipeQuery($searchText: String, $searchFilter: String) {
    recipes(searchText: $searchText, searchFilter: $searchFilter) {
      id
      author
      authorId
      description
      imageUrl
      name
      likes
      youLike
    }
  }
`

const options = ({ searchText, searchFilter }) => ({
  variables: {
    searchText,
    searchFilter
  }
})

const mapStateToProps = state => {
  return {
    isLoggedIn: state.user.token,
    userId: state.user.userId
  }
}

export default connect(mapStateToProps)(
  compose(graphql(recipesQuery, { options }))(RecipeListApollo)
)
