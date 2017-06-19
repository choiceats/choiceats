import React from 'react'
import styled from 'styled-components'

export default ({ ingredient, showQuantity=true }) => {
  const { name, quantity, unit } = ingredient
  return (
    <IngredientContainer>
      { showQuantity && `${quantity} ` }
      { unit && unit.abbr ? `${unit.abbr} ` : '' }
      { name }
    </IngredientContainer>
  )
}

const IngredientContainer = styled.div`
  margin-top: 5px;
  white-space: pre-wrap;
`

