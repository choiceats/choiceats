// @flow
import React from 'react'
import styled from 'styled-components'
import { compose, gql, graphql } from 'react-apollo'
import { Link } from 'react-router-dom'
import RecipeEditorComponent from './components/recipe-editor/recipe-editor'

import type { Recipe } from 'types'
import type { RecipeProps } from './prop-types.flow'

export const RecipeEditor
:(RecipeProps & { data: {recipe: Recipe } }) => React.Element<*> =
({
  data,
  isLoggedIn,
  allowEdits,
  likes = 0,
  userId,
  mutate,
  youLike
}) => {
  if (data.loading) {
    return <div> LOADING...</div>
  }

  const recipe = data.recipe || {}
  return (
    <RecipeEditorComponent
      units={data.units}
      ingredients={data.ingredients}
      recipe={recipe} />
  )
}

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

const Directions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

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
        id
        name
        unit {
          id
          name
          abbr
        }
        quantity
      }
      likes
    }

    units {
      id
      name
      abbr
    }

    ingredients {
      id
      name
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
)(RecipeEditor)
