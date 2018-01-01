// @flow
import * as React from 'react'
import { compose, gql, graphql } from 'react-apollo'
import { RecipeDetail } from './RecipeDetail.elm'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import NotFound from '../shared-components/not-found'
import Loading from '../shared-components/loading'
import { UPDATE, DELETE, PENDING, FAIL } from '../../state/action-types'
import Elm from '../shared-components/react-elm/elm'

import type { Recipe } from 'types'

type ApolloRecipeProps = {
  data: {
    loading: boolean,
    recipe: Recipe
  },
  deleteRecipe?: (arg: {
    variables: { recipeId: null | string | number }
  }) => any,
  dispatch?: (action: { type: string }) => any,
  history: { push: (string | Object) => void },
  likeRecipe?: (arg: {}) => any,
  recipeIdToDelete: string,
  recipeLikeStatus?: Object,
  recipeStatus?: Object,
  selectedRecipeId: string,
  userId?: string,
  token?: string,
  match?: Object
}

export const RecipeDetailApollo: ApolloRecipeProps => React.Element<any> = ({
  data,
  deleteRecipe = () => {},
  dispatch = () => {},
  history = {},
  likeRecipe = () => {},
  recipeIdToDelete,
  recipeLikeStatus = {},
  recipeStatus = {},
  selectedRecipeId,
  userId,
  token,
  match
}) => {
  const recipe = data.recipe || {}

  if (data.loading) {
    return <Loading />
  } else if (!data.loading && !recipe.id) {
    return <NotFound />
  } else {
    const isDeletingRecipe =
      recipe.id === recipeStatus.id &&
      recipeStatus.operation === DELETE &&
      recipeStatus.status === PENDING

    const isChangingLike =
      recipe.id === recipeLikeStatus.id &&
      recipeLikeStatus.operation === UPDATE &&
      recipeLikeStatus.status === PENDING

    const deleteRecipeError =
      recipe.id === recipeStatus.id &&
      recipeStatus.operation === DELETE &&
      recipeStatus.status === FAIL

    const recipeId =
      (match &&
        match.params &&
        match.params.recipeId &&
        parseInt(match.params.recipeId, 10)) ||
      0

    return (
      <Elm
        src={RecipeDetail}
        flags={{
          token,
          userId: parseInt(userId, 10) || 0,
          recipeId
        }}
      />
    )
  }
}

const recipeQuery = gql`
  query RecipeById($recipeId: Int!) {
    recipe(recipeId: $recipeId) {
      id
      author
      authorId
      description
      imageUrl
      name
      instructions
      tags {
        id
        name
      }
      ingredients {
        name
        unit {
          name
          abbr
        }
        quantity
        displayQuantity
      }
      likes
      youLike
    }
  }
`

const deleteRecipe = gql`
  mutation deleteRecipe($recipeId: ID!) {
    deleteRecipe(recipeId: $recipeId) {
      recipeId
      deleted
    }
  }
`

const likeRecipe = gql`
  mutation likeRecipe($userId: ID!, $recipeId: ID!) {
    likeRecipe(userId: $userId, recipeId: $recipeId) {
      id
      likes
      youLike
    }
  }
`

type RouteMatch = {
  match: { params: { recipeId: string } }
}
type RecipeQueryOptions = RouteMatch => any
const options: RecipeQueryOptions = ({ match }) => ({
  variables: {
    recipeId: match.params.recipeId
  }
})

const mapStateToProps = state => ({
  selectedRecipeId: state.ui.selectedRecipeId,
  recipeIdToDelete: state.ui.recipeIdToDelete,
  recipeStatus: state.ui.recipeStatus,
  recipeLikeStatus: state.ui.recipeLikeStatus,
  userId: state.user.userId || null,
  token: state.user.token || null
})

export default connect(mapStateToProps)(
  withRouter(
    compose(
      graphql(likeRecipe, { name: 'likeRecipe' }),
      graphql(deleteRecipe, { name: 'deleteRecipe' }),
      graphql(recipeQuery, { options })
    )(RecipeDetailApollo)
  )
)
