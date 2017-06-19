import React, { Component } from 'react'
import TextField from 'material-ui/TextField'

import type { Ingredient } from 'types'

type IngredientEditorProps = {
  ingredient: Ingredient
}

export default class IngredientEditor extends Component {
  props: IngredientEditorProps
  render () {
    const { ingredient } = this.props
    return <div>
      <TextField
        id={`ingredient-name-${ingredient.id}`}
        defaultValue={ingredient.name}
        floatingLabelText='Ingredient Name'
      />
    </div>
  }
}
