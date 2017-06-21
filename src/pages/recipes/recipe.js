// @flow
import React from 'react'
import styled from 'styled-components'
import { Card, Icon } from 'semantic-ui-react'

import Ingredients from './components/ingredient-list'

import type { Recipe } from '../../types'

type RecipeProps = {
  recipe: Recipe;
  isLoggedIn: boolean;
  allowEdits: boolean;
}

export default ({
  recipe,
  isLoggedIn,
  allowEdits,
  likes=0,
  youLike,
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
          <Icon name="smile" size="big" color={youLike ? "green" : "black"} onClick={()=>console.log('onclick function not implemented yet')} />
          {(likes || youLike) && <span>by you and {likes} {likes > 1 ? 'others' : 'other'}</span>}
          {!likes && <span>Be the first to like this</span>}
        </Card.Description>
      </Card.Content>
    </Card>
  )
}

const Instructions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
