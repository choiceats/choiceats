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

type PROPS = {
  tags: Array<{ id: number, name: string }>
}

type STATE = {
  searchText: string,
  searchFilter: string,
  searchTags: any[]
}

export default class RecipeSearch extends Component<PROPS, STATE> {
  state = {
    searchText: '',
    searchFilter: DEFAULT_FILTER,
    searchTags: []
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

  handleTagChange({ value }: { value: string[] }) {
    this.setState(() => ({ searchTags: value }))
  }

  render() {
    const { tags } = this.props
    const { searchText, searchFilter, searchTags } = this.state
    const options = tags.map(t => ({ text: t.name, value: t.id }))

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
          <Dropdown
            selection
            multiple
            options={options}
            onChange={(e, d) => this.handleTagChange(d)}
          />
        </SearchInput>
        <RecipeListApollo
          searchText={searchText}
          searchTags={searchTags}
          searchFilter={searchFilter}
        />
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
