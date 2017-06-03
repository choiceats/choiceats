// @flow
import React from 'react'
import styled from 'styled-components'
import {
  Card,
  CardActions,
  CardTitle,
  CardText,
} from 'material-ui/Card'
import FlatButton from 'material-ui/FlatButton'
import * as colors from '../styles/colors';

import type { Recipe as TRecipe } from './types'

type RecipeProps = {
  recipe: TRecipe
};

export const Recipe = ({
  recipe,
  isLoggedIn,
  allowEdits
}) => {
  return (
    <Card style={{marginBottom: 25, maxWidth: 550}}>
      <CardTitle title={recipe.name} subtitle={recipe.author} />
      <CardText>
        <Ingredients>{ recipe.ingredients }</Ingredients>
        <Instructions>{ recipe.instructions }</Instructions>
      </CardText>
      {allowEdits && isLoggedIn && <CardActions>
        <FlatButton label='Edit'
          backgroundColor={colors.colorWarningHighlight}
          hoverColor={colors.colorWarning}
          onClick={()=>console.log('not yet connected to editRecipe mutation')}/>
        <FlatButton label='Delete'
          backgroundColor={colors.colorDanger}
          hoverColor={colors.colorDangerHighlight}
          onClick={()=>console.log('not yet connected to deleteRecipe mutation')}/>
      </CardActions>}
        
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
