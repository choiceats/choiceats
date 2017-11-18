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
  searchText: string,
  searchTags: any
}

export class RecipeListApollo extends Component<RecipeListProps> {
  render() {
    const { data, isLoggedIn, userId } = this.props
    if (!data) return <Loading />

    const { recipes, loading } = data
    if (loading) {
      return <Loading />
    }

    if (recipes) {
      return (
        <RecipeList
          recipes={recipes.slice().sort(sortRecipes)}
          userId={userId}
          isLoggedIn={isLoggedIn}
        />
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
    tags {
      id
      name
    }
  }
`

//const recipesQuery = gql`
//  query RecipeQuery(
//    $searchText: String
//    $searchFilter: String
//    $searchTags: [Int]
//  ) {
//    recipes(
//      searchText: $searchText
//      searchFilter: $searchFilter
//      searchTags: $searchTags
//    ) {
//      id
//      author
//      authorId
//      description
//      imageUrl
//      name
//      likes
//      youLike
//    }
//    tags {
//      id
//      name
//    }
//  }
//`

const options = ({ searchText, searchFilter, searchTags }) => ({
  variables: {
    searchText,
    searchFilter,
    searchTags
  }
})

const sortRecipes = (a, b) => {
  const aLikes = (a && a.likes && a.likes.length) || 0
  const bLikes = (b && b.likes && b.likes.length) || 0

  const aLowerName = a.name && a.name.toLowerCase()
  const bLowerName = b.name && b.name.toLowerCase()

  const nameALTB = aLowerName < bLowerName
  const nameAGTB = aLowerName > bLowerName

  const youLikeAGTB = !!(a.youLike || false) && !(b.youLike || false)
  const youLikeALTB = !(a.youLike || false) && !!(b.youLike || false)

  const allLikeAGTB = aLikes > bLikes
  const allLikeALTB = aLikes < bLikes

  switch (true) {
    case youLikeAGTB:
      return -1
    case youLikeALTB:
      return 1
    case allLikeAGTB:
      return -1
    case allLikeALTB:
      return 1
    case nameALTB:
      return -1
    case nameAGTB:
      return 1
    default:
      return 0
  }
}

const mapStateToProps = state => {
  return {
    isLoggedIn: state.user.token,
    userId: state.user.userId
  }
}

export default connect(mapStateToProps)(
  compose(graphql(recipesQuery, { options }))(RecipeListApollo)
)
