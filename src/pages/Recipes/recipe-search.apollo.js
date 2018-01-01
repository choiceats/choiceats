// @flow
import React, { Component } from 'react'
import { gql, graphql, compose } from 'react-apollo'
import { connect } from 'react-redux'

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
    const { data } = this.props
    if (!data) {
      return <Loading />
    }

    const { tags, loading } = data
    if (loading) {
      return <Loading />
    }

    return <RecipeSearch tags={tags} />
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

const mapStateToProps = state => {
  return {
    isLoggedIn: state.user.token,
    userId: state.user.userId
  }
}

export default connect(mapStateToProps)(
  compose(graphql(tagsQuery))(RecipeListApollo)
)
