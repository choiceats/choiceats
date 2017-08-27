// @flow
import React, { Component } from 'react'
import { Button } from 'semantic-ui-react'
import styled from 'styled-components'

type PROPS = {
  getAnotherRecipe: () => void
}

class RandomFilter extends Component<PROPS> {
  render() {
    const { getAnotherRecipe } = this.props
    return (
      <SCRandomButton>
        <Button primary onClick={e => getAnotherRecipe()}>
          NEW IDEA!
        </Button>
      </SCRandomButton>
    )
  }
}

const SCRandomButton = styled.div`
  width: 100%;
  text-align: center;
  margin-top: 15px;
`

export default RandomFilter
