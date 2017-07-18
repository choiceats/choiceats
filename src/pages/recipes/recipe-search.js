/* global KeyboardEvent, HTMLInputElement, MouseEvent */
// @flow
import React, { Component } from 'react'
import { Input, Button, Dropdown } from 'semantic-ui-react'
import { Link } from 'react-router-dom'
import styled from 'styled-components'

import RecipeListApollo from './recipe-list.apollo'

const FILTER_OPTIONS = [
  { key: 'my', text: 'My Recipes', value: 'my' },
  { key: 'fav', text: 'Favorite', value: 'fav' },
  { key: 'all', text: 'All', value: 'all' }
]

const DEFAULT_FILTER = 'all'

export default class RecipeSearch extends Component {
  state = {
    searchText: '',
    searchFilter: DEFAULT_FILTER
  }

  updateSearch(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      const value = e.target.value
      this.setState(() => ({ searchText: value }))
    }
  }

  updateFilter(e: MouseEvent, data: { value: string }) {
    this.setState(() => ({ searchFilter: data.value }))
  }

  render() {
    const { searchText, searchFilter } = this.state
    return (
      <SearchContainer>
        <SearchInput>
          <NewLink>
            <Link to="/recipe/new">
              <Button size="mini" primary>
                New
              </Button>
            </Link>
          </NewLink>
          <SearchHeader>Search</SearchHeader>
          <Input
            action={
              <Dropdown
                button
                basic
                options={FILTER_OPTIONS}
                onChange={(e, d) => this.updateFilter(e, d)}
                defaultValue={DEFAULT_FILTER}
              />
            }
            iconPosition="left"
            icon="search"
            placeholder="Search by name or ingredient"
            fluid
            onChange={e => this.updateSearch(e)}
          />
        </SearchInput>
        <RecipeListApollo searchText={searchText} searchFilter={searchFilter} />
      </SearchContainer>
    )
  }
}

const SearchContainer = styled.div`
  max-width: 500px;
  margin: auto;
`

const NewLink = styled.div`
  position: absolute;
  top: 0px;
  right: 0px;
`

const SearchInput = styled.div`position: relative;`

const SearchHeader = styled.h2`margin-bottom: 8px;`

const SearchHelpText = styled.p`
  margin: 0;
  font-size: smaller;
  color: #888;
`
