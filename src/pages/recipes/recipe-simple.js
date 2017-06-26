// @flow
import React from 'react'
import styled from 'styled-components'
import { connect } from 'react-redux'

import { selectRecipe } from '../../state/action-creators'
import { Card, Icon } from 'semantic-ui-react'

import type { RecipeProps } from './prop-types.flow'

export const RecipeSimple = ({
  recipe,
  isLoggedIn,
  allowEdits,
  likes = 0,
  youLike,
  dispatch
}: RecipeProps) => {
  return (
    <Card>
      <Card.Content onClick={() => dispatch(selectRecipe(recipe.id))}>
        <Card.Header>{recipe.name}</Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Description>{ recipe.description }</Description>
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

export default connect()(RecipeSimple)

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
