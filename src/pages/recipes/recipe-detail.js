// @flow
import React from 'react'
import styled from 'styled-components'
import { gql, graphql } from 'react-apollo'
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
  youLike
}) => {
  if (data.loading) {
    return <div> LOADING...</div>
  }

  const recipe = data.recipe
  return (
    <Card>
      <Card.Content>
        <Card.Header>{recipe.name}</Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Description>{ recipe.description }</Description>
          <IngredientList ingredients={recipe.ingredients} />
          <Directions>{ recipe.instructions }</Directions>
        </Card.Description>
        <Card.Description>
          <Icon name='smile' size='big' color={youLike ? 'green' : 'black'} onClick={() => console.log('onclick function not implemented yet')} />
          {(likes || youLike) && <span>by you and {likes} {likes > 1 ? 'others' : 'other'}</span>}
          {!likes && <span>Be the first to like this</span>}
        </Card.Description>
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
      ingredients {
        name
        unit {
          name
          abbr
        }
        quantity
      }
    }
  }
`

const options
: (RecipeProps) => any =
  ({recipe}) => {
    console.log('OROPS', recipe)
    return {
      variables: {
        recipeId: recipe.id
      }
    }
  }

export default graphql(recipeQuery, { options })(RecipeDetail)
