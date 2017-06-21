// @flow
import React from 'react'
import styled from 'styled-components'
import { Card } from 'semantic-ui-react'

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
  allowEdits
}: RecipeProps) => {
  return (
    <Card className={{width: '100%'}}>
      <Card.Content>
        <Card.Header>{recipe.name}</Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          <Ingredients ingredients={recipe.ingredients} />
          <Instructions>{ recipe.instructions }</Instructions>
        </Card.Description>
      </Card.Content>
    </Card>
  )
}

const Instructions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
