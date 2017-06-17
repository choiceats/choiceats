import React from 'react'
import Ingredient from './ingredient'

export default ({ingredients}) =>
  <ul>
    { ingredients.map(ingredient => <Ingredient ingredient={ingredient} />)}
  </ul>
