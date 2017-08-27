// @flow
import React, { Component } from 'react'
import { compose, gql, graphql } from 'react-apollo'
import styled from 'styled-components'

import RecipeComponent from '../recipes/recipe'
import { withRouter } from 'react-router-dom'
import NotFound from '../shared-components/not-found'
import Loading from '../shared-components/loading'
import RandomButton from './components/random-button-filter'
import FilterSelector from './components/filter'

import { DEFAULT_FILTER } from './consts'

import type { Recipe } from 'types'

type PROPS = {
  data: {
    loading: boolean,
    randomRecipe: Recipe,
    refetch: (filter: { searchFilter: string }) => void
  }
}

type STATE = {
  searchFilter: string
}

export class RecipeDetailApollo extends Component<PROPS, STATE> {
  state = { searchFilter: DEFAULT_FILTER }

  getAnotherRecipe() {
    const { data } = this.props
    const { searchFilter } = this.state
    data.refetch({ searchFilter })
  }

  updateFilter(value: string) {
    this.setState(() => ({ searchFilter: value }))
  }

  render() {
    const { data } = this.props
    const recipe = data.randomRecipe || {}
    const { searchFilter } = this.state
    if (data.loading) {
      return <Loading />
    } else if (!data.loading && !recipe.id) {
      return <NotFound />
    } else {
      return (
        <RandomizerBody>
          <FilterSelector
            updateFilter={this.updateFilter.bind(this)}
            selectedFilter={searchFilter}
          />
          <RecipeComponent recipe={recipe} />
          <RandomButton getAnotherRecipe={this.getAnotherRecipe.bind(this)} />
        </RandomizerBody>
      )
    }
  }
}

const RandomizerBody = styled.div`align: center;`

const recipeQuery = gql`
  query RandomRecipe($searchFilter: String) {
    randomRecipe(searchFilter: $searchFilter) {
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
