// @flow
import React from 'react'
import styled from 'styled-components'
import {Card, CardTitle, CardText} from 'material-ui/Card'

import type { Recipe as TRecipe } from './types'

type RecipeProps = {
  recipe: TRecipe
};

export const Recipe = ({recipe}: RecipeProps) => {
  return (
    <Card style={{marginBottom: 25, maxWidth: 550}}>
      <CardTitle
        title={recipe.name}
        subtitle='pasta' />
      <CardText>
        <Ingredients>{ recipe.ingredients }</Ingredients>
        <Instructions>{ recipe.instructions }</Instructions>
      </CardText>
    </Card>
  )
}

const Ingredients = styled.div`
  margin-top: 15px;
  font-family: monospace;
  white-space: pre-wrap;
`

const Instructions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`
