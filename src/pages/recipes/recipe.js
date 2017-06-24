// @flow
import React from 'react'
import styled from 'styled-components'
import { Card, Icon } from 'semantic-ui-react'

import Ingredients from './components/ingredient-list'

import type { TRecipe } from '../../types'

import { gql, graphql } from 'react-apollo'

type RecipeProps = {
  recipe: TRecipe;
  isLoggedIn: boolean;
  allowEdits: boolean;
  youLike?: boolean;
  likes?: number;
  mutate: Function;
}

const likeRecipe = gql`
  mutation likeRecipe($userId: ID!, $recipeId: ID!) {
    likeRecipe(userId: $userId, recipeId: $recipeId) {
      id
      likes
      youLike
    }
  }
`

export const Recipe = ({
  recipe,
  isLoggedIn,
  allowEdits,
  likes = 0,
  youLike,
  mutate,
  ...other
}: RecipeProps) => {
  return (
    <Card >
      <Card.Content>
        <Card.Header>{recipe.name}</Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Ingredients ingredients={recipe.ingredients} />
          <Instructions>{ recipe.instructions }</Instructions>
        </Card.Description>
        <Card.Description>
          <Icon name='smile'
            size='big'
            color={youLike ? 'green' : 'black'}
            onClick={() => {
              mutate({
                variables: {
                  recipeId: recipe.id,
                  userId: 1
                }
              })
                .then(({ data }) => {
                  console.log('got data', data)
                }).catch((error) => {
                  console.log('there was an error sending the query', error)
                })
            }} />
          {(likes || youLike) && <span>by you and {likes} {likes > 1 ? 'others' : 'other'}</span>}
          {!likes && <span>Be the first to like this</span>}
        </Card.Description>
      </Card.Content>
    </Card>
  )
}

export default graphql(likeRecipe)(Recipe)

const Instructions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
