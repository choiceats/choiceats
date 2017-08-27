// @flow
import React, { Component } from 'react'
import { Button, Dropdown } from 'semantic-ui-react'
import styled from 'styled-components'

import { FILTER_OPTIONS } from '../consts'

type PROPS = {
  selectedFilter: string,
  updateFilter: (MouseEvent, any) => void,
  getAnotherRecipe: () => void
}

class RandomFilter extends Component<PROPS> {
  render() {
    const { getAnotherRecipe, updateFilter, selectedFilter } = this.props
    return (
      <RandomButton>
        <Button primary onClick={e => getAnotherRecipe()}>
          NEW IDEA!
        </Button>
        <Dropdown
          selection
          options={FILTER_OPTIONS}
          defaultValue={selectedFilter}
          onChange={(e, d) => updateFilter(e, d)}
        />
      </RandomButton>
    )
  }
}

const RandomButton = styled.div`
  width: 100%;
  text-align: center;
  margin-top: 15px;
`

export default RandomFilter
