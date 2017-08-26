// @flow
import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { compose, gql, graphql } from 'react-apollo'
import RecipeEditor from './components/recipe-editor/recipe-editor'
import Loading from '../shared-components/loading'
import { connect } from 'react-redux'
import { UPDATE, SUCCESS, PENDING, FAIL } from '../../state/action-types'
import { setRecipeStatus } from '../../state/action-creators'

import type { Recipe, Ingredient, Unit } from 'types'

type RecipeEditorApolloProps = {
  data: {
    recipe: Recipe,
    ingredients: Ingredient[],
    units: Unit[]
  },
  history: any,
  recipeStatus: Object,
  userId: null | string,
  mutate: any => window.Promise,
  dispatch: any => Object
}

export class RecipeEditorApollo extends Component<RecipeEditorApolloProps> {
  onSave(recipe: Recipe) {
    const { mutate, history, dispatch } = this.props
    const cleanRecipe = stripOutTypenames(recipe)
    dispatch(
      setRecipeStatus({
        id: recipe.id,
        operation: UPDATE,
        status: PENDING
      })
    )
    mutate({
      variables: { recipe: cleanRecipe }
    })
      .then(({ data }) => {
        dispatch(
          setRecipeStatus({
            id: recipe.id,
            operation: UPDATE,
            status: SUCCESS
          })
        )

        history.push('/') // TODO: push to id
      })
      .catch(error => {
        dispatch(
          setRecipeStatus({
            id: recipe.id,
            operation: UPDATE,
            status: FAIL
          })
        )
        console.error('Got back error', error)
      })
  }

  render() {
    const { data, userId, recipeStatus } = this.props
    console.log(recipeStatus)
    if (data.loading) {
      return <Loading />
    }

    const recipe = data.recipe || {}

    if (recipe.authorId !== userId) {
      return (
        <div>
          You need to be logged in as the user owning this recipe to edit it.
        </div>
      )
    }

    const isSavingRecipe =
      !!recipe &&
      !!recipeStatus &&
      recipe.id === recipeStatus.id &&
      recipeStatus.operation === UPDATE &&
      recipeStatus.status === PENDING

    const recipeSaveError =
      !!recipe &&
      !!recipeStatus &&
      recipe.id === recipeStatus.id &&
      recipeStatus.operation === UPDATE &&
      recipeStatus.status === FAIL

    return (
      <RecipeEditor
        onSave={this.onSave.bind(this)}
        units={data.units}
        ingredients={data.ingredients}
        recipe={recipe}
        isSavingRecipe={isSavingRecipe}
        recipeSaveError={recipeSaveError}
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

const recipeQuery = gql`
  query RecipeById($recipeId: Int!) {
    recipe(recipeId: $recipeId) {
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
  match: { params: { recipeId: string } }
}
type RecipeQueryOptions = RouteMatch => any
const options: RecipeQueryOptions = ({ match }) => ({
  variables: {
    recipeId: match.params.recipeId
  }
})

const mapStateToProps = state => ({
  recipeStatus: state.ui.recipeStatus,
  userId: state.user.userId || null
})

export default connect(mapStateToProps)(
  withRouter(
    compose(graphql(gqlStuff), graphql(recipeQuery, { options }))(
      RecipeEditorApollo
    )
  )
)
