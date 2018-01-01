// @flow
import * as React from 'react'
import styled, { keyframes } from 'styled-components'

import Recipe from './recipe'

import type { Recipe as TRecipe } from 'types'

type RecipeListProps = {
  recipes: TRecipe[],
  userId: number,
  isLoggedIn: boolean
}

export default class RecipeList extends React.Component<RecipeListProps, void> {
  render() {
    const { recipes, userId, isLoggedIn } = this.props
    return (
      <ListContainer>
        {recipes.map(recipe => (
          <Recipe
            key={recipe.id}
            recipe={recipe}
            allowEdits
            likes={3}
            youLike={false}
            userId={userId}
            isLoggedIn={isLoggedIn}
          />
        ))}
      </ListContainer>
    )
  }
}

const slideIn = keyframes`
from {
  margin-left: 100%;
}

to {
  margin-left: 0%;
}
`

const PAGE_PADDING = 50
const ListContainer = styled.div`
  animation: ${slideIn} 0.125s linear;
  padding-top: 30px;
  min-width: ${320 - PAGE_PADDING}px;
  max-width: 500px;
  margin: auto;
`
