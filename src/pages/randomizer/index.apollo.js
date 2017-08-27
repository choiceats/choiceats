// @flow
import React, { Component } from 'react'
import { compose, gql, graphql } from 'react-apollo'
import { Button, Dropdown } from 'semantic-ui-react'
import styled from 'styled-components'

import RecipeComponent from '../recipes/recipe'
import { withRouter } from 'react-router-dom'
import NotFound from '../shared-components/not-found'
import Loading from '../shared-components/loading'
import Randomfilter from './components/random-button-filter'

import { DEFAULT_FILTER, FILTER_OPTIONS } from './consts'

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

  updateFilter(e: MouseEvent, data: { value: string }) {
    this.setState(() => ({ searchFilter: data.value }))
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
          <RecipeComponent recipe={recipe} />
          <Randomfilter
            updateFilter={this.updateFilter.bind(this)}
            getAnotherRecipe={this.getAnotherRecipe.bind(this)}
            selectedFilter={searchFilter}
          />
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
