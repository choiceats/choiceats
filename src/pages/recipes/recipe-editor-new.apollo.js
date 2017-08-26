// @flow
import React, { Component } from 'react'
import { compose, gql, graphql } from 'react-apollo'
import RecipeEditor from './components/recipe-editor/recipe-editor'
import { DEFAULT_RECIPE } from '../../defaults'
import Loading from '../shared-components/loading'

import type { Recipe, Ingredient, Unit } from 'types'

type RecipeEditorNewData = {
  data: {
    ingredients: Ingredient[],
    units: Unit[]
  },
  history: any,
  mutate: any => window.Promise
}

export class RecipeEditorNewApollo extends Component<RecipeEditorNewData> {
  onSave(recipe: Recipe) {
    const { mutate, history } = this.props
    const cleanRecipe = stripOutTypenames(recipe)
    mutate({
      variables: { recipe: cleanRecipe }
    })
      .then(({ data }) => {
        history.push('/') // TODO: push to id
      })
      .catch(error => console.error('Got back error', error))
  }

  render() {
    const { data } = this.props
    if (data.loading) {
      return <Loading />
    }

    return (
      <RecipeEditor
        onSave={this.onSave.bind(this)}
        units={data.units}
        ingredients={data.ingredients}
        recipe={DEFAULT_RECIPE}
      />
    )
  }
}

// TODO: not sure why we are getting a __typename
function stripOutTypenames(obj: any) {
  if (obj === null || obj === undefined) {
    return obj
  }

  if (typeof obj !== 'object') {
    return obj
  }

  if (obj instanceof String) {
    return obj
  }

  if (obj instanceof Array) {
    return obj.map(o => stripOutTypenames(o))
  }

  const keys = Object.keys(obj)
  const newObj = {}
  keys.forEach(k => {
    if (typeof obj === 'object' && k !== '__typename') {
      newObj[k] = stripOutTypenames(obj[k])
    }
  })

  return newObj
}

const unitsAndIngredientsQuery = gql`
  query UnitsAndIngredients {
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

const gqlStuff = gql`
  mutation SaveRecipe($recipe: RecipeInput!) {
    saveRecipe(recipe: $recipe) {
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
  }
`

export default compose(graphql(gqlStuff), graphql(unitsAndIngredientsQuery))(
  RecipeEditorNewApollo
)
