// @flow
import React from 'react'
import styled from 'styled-components'
import { compose, gql, graphql } from 'react-apollo'
import { Link } from 'react-router-dom'
import { Card, Icon } from 'semantic-ui-react'

import IngredientList from './components/ingredient-list'

import type { Recipe } from 'types'
import type { RecipeProps } from './prop-types.flow'

export const RecipeDetail
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
    <Card>
      <Card.Content>
        <Card.Header>
          <Link to='/'>Back</Link>
          {recipe.name}
        </Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Description>{ recipe.description }</Description>
          <IngredientList ingredients={recipe.ingredients} />
          <Directions>{ recipe.instructions }</Directions>
        </Card.Description>
        <Link to={`/recipe/${recipe.id}/edit`}>Edit</Link>
      </Card.Content>
    </Card>
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
)(RecipeDetail)
