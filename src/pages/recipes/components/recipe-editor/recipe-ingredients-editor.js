// @flow
import React, { Component } from 'react'
import { Dropdown, Select, Input, Form } from 'semantic-ui-react'

import type { Recipe } from 'types'

type IngredientEditorProps = {
  recipe: ?Recipe;
  ingredients: {id: number, name: string}[];
  units: {id: number, name: string, abbr: string}[];
}

export default class RecipeIngredientsEditor extends Component {
  props: IngredientEditorProps
  render () {
    const { recipe, ingredients, units } = this.props
    return <div>
      { recipe && recipe.ingredients.map(i => <RecipeIngredientEditor ingredients={ingredients} units={units} ingredient={i} />) }
    </div>
  }
}

class RecipeIngredientEditor extends Component {
  render () {
    const { ingredient, ingredients, units } = this.props
    return (
      <Form.Group>
        <Form.Field
          control={Input}
          width={2}
          value={ingredient.quantity}
          placeholder='#' />

        <Form.Field
          control={Select}
          placeholder='Units'
          value={ingredient.unit ? ingredient.unit.id : null}
          width={4}
          selection
          options={units.map(i => ({ key: i.id, value: i.id, text: i.abbr }))} />

        <Form.Field
          control={Dropdown}
          width={8}
          placeholder='Enter Ingredient'
          search
          selection
          value={ingredient.id}
          options={ingredients.map(i => ({ key: i.id, value: i.id, text: i.name }))} />
      </Form.Group>
    )
  }
}
