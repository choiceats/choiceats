// @flow
import React from 'react'
import { compose, gql, graphql } from 'react-apollo'
import RecipeDetail from './recipe-detail'

import type { Recipe } from 'types'

type ApolloRecipeProps = {
  data: {
    loading: boolean;
    recipe: Recipe
  }
}

export const RecipeDetailApollo:(ApolloRecipeProps) => React.Element<any> =
({ data }) => {
  if (data.loading) {
    return <div> LOADING...</div>
  }

  const recipe = data.recipe || {}
  return <RecipeDetail recipe={recipe} />
}

const recipeQuery = gql`
  query RecipeById($recipeId: Int!) {
    recipe (recipeId: $recipeId) {
      id
      author
      authorId
      description
      imageUrl
      name
      instructions
      ingredients {
        name
        unit {
          name
          abbr
        }
        quantity
      }
      likes
    }
  }
`

type RouteMatch = {
  match: { params: { recipeId: string } };
}
type RecipeQueryOptions = (RouteMatch) => any;
const options: RecipeQueryOptions = ({match}) => ({
  variables: {
    recipeId: match.params.recipeId
  }
})

export default compose(
  graphql(recipeQuery, { options })
)(RecipeDetailApollo)
