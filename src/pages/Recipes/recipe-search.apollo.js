// @flow
import React, { Component } from 'react'
import { gql, graphql, compose } from 'react-apollo'

import RecipeSearch from './recipe-search'
import Loading from '../shared-components/loading'

import type { RecipeTag } from '../types'

type RecipeSearchProps = {
  data?: {
    loading: string,
    error: string,
    tags: RecipeTag[]
  }
}

export class RecipeListApollo extends Component<RecipeSearchProps> {
  render() {
    const { data, token, userId } = this.props

    if (!data) {
      return <Loading />
    }

    const { tags, loading } = data
    if (loading) {
      return <Loading />
    }

    return <RecipeSearch tags={tags} token={token} userId={userId} />
  }
}

const tagsQuery = gql`
  query GetTags {
    tags {
      id
      name
    }
  }
`

export default compose(graphql(tagsQuery))(RecipeListApollo)
