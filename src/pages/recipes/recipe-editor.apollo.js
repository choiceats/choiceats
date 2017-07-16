// @flow
import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { compose, gql, graphql } from 'react-apollo'
import RecipeEditor from './components/recipe-editor/recipe-editor'

import type { Recipe, Ingredient, Unit } from 'types'

type RecipeApolloData = {
  data: {
    recipe: Recipe;
    ingredients: Ingredient[];
    units: Unit[];
  },
  history: any;
  mutate: (any)=> window.Promise
}

export class RecipeEditorApollo extends Component {
  props: RecipeApolloData

  onSave (recipe: Recipe) {
    const { mutate, history } = this.props
    const cleanRecipe = stripOutTypenames(recipe)
    mutate({
      variables: { recipe: cleanRecipe }
    })
    .then(({data}) => {
      history.push('/') // TODO: push to id
      console.log('Got back data', data)
    })
    .catch((error) => console.error('Got back error', error))
  }

  render () {
    const { data } = this.props
    if (data.loading) {
      return <div>LOADING...</div>
    }

    const recipe = data.recipe || {}
    return (
      <RecipeEditor
        onSave={this.onSave.bind(this)}
        units={data.units}
        ingredients={data.ingredients}
        recipe={recipe} />
    )
  }
}

// TODO: not sure why we are getting a __typename
function stripOutTypenames (obj: any) {
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

type RouteMatch = {
  match: { params: { recipeId: string } };
}
type RecipeQueryOptions = (RouteMatch) => any;
const options: RecipeQueryOptions = ({match}) => ({
  variables: {
    recipeId: match.params.recipeId
  }
})

export default withRouter(compose(
  graphql(gqlStuff),
  graphql(recipeQuery, { options })
)(RecipeEditorApollo))
