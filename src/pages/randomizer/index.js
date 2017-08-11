// @flow
import React, { Component } from 'react'
import { compose, gql, graphql } from 'react-apollo'
import { Button } from 'semantic-ui-react'
import styled from 'styled-components'

import RecipeComponent from '../recipes/recipe'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import NotFound from '../shared-components/not-found'
import Loading from '../shared-components/loading'

import type { Recipe } from 'types'

type ApolloRecipeProps = {
  data: {
    loading: boolean,
    randomRecipe: Recipe,
    refetch: void => void
  }
}

export class RecipeDetailApollo extends Component {
  props: ApolloRecipeProps

  getAnotherRecipe() {
    const { data } = this.props
    data.refetch()
  }

  render() {
    const { data } = this.props
    const recipe = data.randomRecipe || {}

    if (data.loading) {
      return <Loading />
    } else if (!data.loading && !recipe.id) {
      return <NotFound />
    } else {
      return (
        <RandomizerBody>
          <RecipeComponent recipe={recipe} />
          <RandomButton>
            <Button primary onClick={e => this.getAnotherRecipe()}>
              NEW RECIPE!
            </Button>
          </RandomButton>
        </RandomizerBody>
      )
    }
  }
}

const RandomizerBody = styled.div`align: center;`

const RandomButton = styled.div`
  width: 100%;
  text-align: center;
  margin-top: 15px;
`

const recipeQuery = gql`
  query RandomRecipe {
    randomRecipe {
      id
      author
      authorId
      description
      imageUrl
      name
      likes
      youLike
    }
  }
`

export default withRouter(compose(graphql(recipeQuery))(RecipeDetailApollo))
