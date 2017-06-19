import React from 'react'
import Ingredient from './ingredient'

export default ({ingredients}) =>
  <ul>
    { ingredients.map((ingredient, i) => {
      const { quantity, unit } = ingredient
      const showQuantity = (unit.name !== 'UNITLESS' || (unit.name === 'UNITLESS' && quantity !== 1))
      return <Ingredient ingredient={ingredient} key={i} showQuantity={showQuantity} />
    })}
  </ul>
