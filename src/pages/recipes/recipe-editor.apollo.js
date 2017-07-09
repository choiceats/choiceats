// @flow
import React from 'react'
import { compose, gql, graphql } from 'react-apollo'
import RecipeEditorComponent from './components/recipe-editor/recipe-editor'

import type { Recipe, Ingredient, Unit } from 'types'

type RecipeApolloData = {
  data: {
    recipe: Recipe;
    ingredients: Ingredient[];
    units: Unit[];
  }
}

export const RecipeEditor: (RecipeApolloData) => React.Element<any> =
({ data }) => {
  if (data.loading) {
    return <div>LOADING...</div>
  }

  const recipe = data.recipe || {}
  return (
    <RecipeEditorComponent
      units={data.units}
      ingredients={data.ingredients}
      recipe={recipe} />
  )
}

const recipeQuery = gql`
  query RecipeById($recipeId: Int!) {
    recipe (recipeId: $recipeId) {
      id
      author
      authorId
      description
      imageUrl
      name
      instructions
      ingredients {
        id
        name
        unit {
          id
          name
          abbr
        }
        quantity
      }
      likes
    }

    units {
      id
      name
      abbr
    }

    ingredients {
      id
      name
    }
  }
`

type RouteMatch = {
  match: { params: { recipeId: string } };
}
type RecipeQueryOptions = (RouteMatch) => any;
const options: RecipeQueryOptions = ({match}) => ({
  variables: {
    recipeId: match.params.recipeId
  }
})

export default compose(
  graphql(recipeQuery, { options })
)(RecipeEditor)
