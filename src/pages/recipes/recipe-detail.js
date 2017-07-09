// @flow
import React from 'react'
import styled, { keyframes } from 'styled-components'
import { Link } from 'react-router-dom'
import { Card } from 'semantic-ui-react'

import IngredientList from './components/ingredient-list'

import type { RecipeProps } from './prop-types.flow'

export const RecipeDetail: (RecipeProps) => React.Element<*> =
({ recipe }) => (
  <RecipeCard>
    <Card fluid>
      <Card.Content>
        <Card.Header>
          {recipe.name}
        </Card.Header>
        <Card.Meta>{recipe.author}</Card.Meta>
        <Card.Description>
          { recipe.id && <Link to={`/recipe/${recipe.id}/edit`}>Edit</Link> }
          <Description>{ recipe.description }</Description>
          <IngredientList ingredients={recipe.ingredients} />
          <Directions>{ recipe.instructions }</Directions>
        </Card.Description>

      </Card.Content>
    </Card>
  </RecipeCard>
)

const slideIn = keyframes`
  from {
    margin-left: 100%;
  }

  to {
    margin-left: 0%;
  }
`

const RecipeCard = styled.div`
  animation: ${slideIn} .25s linear;
`

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

const Directions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
export default RecipeDetail
