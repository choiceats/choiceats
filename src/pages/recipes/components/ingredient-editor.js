import React, { Component } from 'react'
import { Input } from 'semantic-ui-react'

import type { Ingredient } from 'types'

type IngredientEditorProps = {
  ingredient: Ingredient
}

export default class IngredientEditor extends Component {
  props: IngredientEditorProps
  render () {
    const { ingredient } = this.props
    return <div>
      <Input
        id={`ingredient-name-${ingredient.id}`}
        defaultValue={ingredient.name}
      />
    </div>
  }
}
