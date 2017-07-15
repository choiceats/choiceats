// @flow
import React from 'react'
import styled from 'styled-components'
import { connect } from 'react-redux'
import { gql, graphql } from 'react-apollo'

import { selectRecipe } from '../../state/action-creators'
import { Card, Icon } from 'semantic-ui-react'

import type { ConnectedProps } from 'types'
import type { RecipeProps } from './prop-types.flow'

type OtherProps = {
  mutate: Function,
  likes: number,
  userId: number | string,
  youLike?: boolean
}

export const RecipeSimple
  : (RecipeProps & OtherProps & ConnectedProps) => React.Element<*> =
  ({
    allowEdits,
    dispatch,
    isLoggedIn,
    likes = 0,
    mutate,
    recipe,
    userId,
    youLike
  }) => (
    <Card centered >
      <Card.Content onClick={() => {
        dispatch(selectRecipe(recipe.id))
      }}>
        <Card.Header>{recipe.name}</Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Description>{ recipe.description }</Description>
        </Card.Description>
        <Card.Description>
          <Icon name='smile'
            size='big'
            color={youLike ? 'green' : 'black'}
            onClick={() => {
              mutate({
                variables: {
                  recipeId: recipe.id,
                  userId
                }
              })
                .then(({ data }) => {
                  console.log('got data', data)
                }).catch((error) => {
                  console.log('there was an error sending the query', error)
                })
            }} />
          {(recipe.likes) && <span>Likes: {recipe.likes} {recipe.youLike && '(including you)'}</span>}
          {!recipe.likes && <span>Be the first to like this</span>}
        </Card.Description>
      </Card.Content>
    </Card>
  )

const likeRecipe = gql`
  mutation likeRecipe($userId: ID!, $recipeId: ID!) {
    likeRecipe(userId: $userId, recipeId: $recipeId) {
      id
      likes
      youLike
    }
  }
`

export default graphql(likeRecipe)(connect()(RecipeSimple))

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
