import React from 'react'
import styled from 'styled-components'

export default ({ ingredient }) => {
  const { name, quantity, unit } = ingredient
  return (
    <IngredientContainer>
      { quantity }
      { unit && unit.abbr ? unit.abbr : '' }
      { name }
    </IngredientContainer>
  )
}

const IngredientContainer = styled.div`
  margin-top: 15px;
  font-family: monospace;
  white-space: pre-wrap;
`
