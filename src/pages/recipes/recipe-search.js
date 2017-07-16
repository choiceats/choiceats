/* global KeyboardEvent, HTMLInputElement */
// @flow
import React, { Component } from 'react'
import { Input, Button } from 'semantic-ui-react'
import { Link } from 'react-router-dom'
import styled from 'styled-components'

import RecipeListApollo from './recipe-list.apollo'

export default class RecipeSearch extends Component {
  state = {
    searchText: ''
  }

  updateSearch (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      const value = e.target.value
      this.setState(() => ({ searchText: value }))
    }
  }

  render () {
    const { searchText } = this.state
    return (
      <SearchContainer>
        <SearchInput>
          <NewLink>
            <Link to='/recipe/new'>
              <Button primary>New</Button>
            </Link>
          </NewLink>
          <SearchHeader>Search</SearchHeader>
          <SearchHelpText>Searches by recipe name and ingredient list</SearchHelpText>
          <Input fluid onChange={e => this.updateSearch(e)} />

        </SearchInput>
        <RecipeListApollo searchText={searchText} />
      </SearchContainer>
    )
  }
}

const SearchContainer = styled.div`
  max-width: 500px;
  margin: auto;
`

const NewLink = styled.div`
  float: right;
`

const SearchInput = styled.div`

`

const SearchHeader = styled.h2`
  margin-bottom: 2px
`

const SearchHelpText = styled.p`
  margin: 0;
  font-size: smaller;
  color: #888;
`
