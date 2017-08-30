import React from 'react'
import styled from 'styled-components'

export default ({ ingredient, showQuantity = true }) => {
  const { name, displayQuantity, unit } = ingredient
  return (
    <IngredientContainer>
      {showQuantity && `${displayQuantity} `}
      {unit && unit.abbr ? `${unit.abbr} ` : ''}
      {name}
    </IngredientContainer>
  )
}

const IngredientContainer = styled.div`
  margin-top: 5px;
  white-space: pre-wrap;
`
