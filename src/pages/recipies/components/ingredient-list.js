import React from 'react'
import Ingredient from './ingredient'

export default ({ingredients}) =>
  <ul>
    { ingredients.map((ingredient, index) => <Ingredient key={index} ingredient={ingredient} />)}
  </ul>
