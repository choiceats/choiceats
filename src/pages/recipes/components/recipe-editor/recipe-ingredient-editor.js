/* global Event, KeyboardEvent, HTMLInputElement */
// @flow
import React, { Component } from 'react'
import { Dropdown, Select, Input, Form, Button } from 'semantic-ui-react'

const BLANK_UNIT = {
  key: null,
  value: null,
  text: 'N/A'
}

type DropdownData = {
  value: string;
}

export default class RecipeIngredientEditor extends Component {
  updateQuantity (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      const { ingredient, update, index } = this.props
      const updatedIngredient = {
        ...ingredient,
        quantity: e.target.value
      }

      update(updatedIngredient, index)
    }
  }

  updateUnit (e: Event, data: DropdownData) {
    const { ingredient, update, index, units } = this.props
    const selectedUnit = units.find(u => u.id === data.value)
    const updatedIngredient = {
      ...ingredient,
      unit: selectedUnit
    }

    update(updatedIngredient, index)
  }

  updateIngredient (e: Event, data: DropdownData) {
    const { ingredient, update, index, ingredients } = this.props
    const selectedIngredient = ingredients.find(i => i.id === data.value)
    const updatedIngredient = {
      ...ingredient,
      ...selectedIngredient
    }

    update(updatedIngredient, index)
  }

  render () {
    const { index, ingredient, ingredients, units, remove } = this.props
    const unitOptionsWithBlank = units.map(i => ({ key: i.id, value: i.id, text: i.abbr }))
    unitOptionsWithBlank.unshift(BLANK_UNIT)

    return (
      <Form.Group>
        <Form.Field
          control={Input}
          width={2}
          onChange={(e) => this.updateQuantity(e)}
          value={ingredient.quantity}
          placeholder='#' />

        <Form.Field
          control={Select}
          placeholder='Units'
          value={ingredient.unit ? ingredient.unit.id : ''}
          width={4}
          selection
          onChange={this.updateUnit.bind(this)}
          options={unitOptionsWithBlank} />

        <Form.Field
          control={Dropdown}
          width={8}
          placeholder='Enter Ingredient'
          search
          selection
          onChange={this.updateIngredient.bind(this)}
          value={ingredient.id || ''}
          options={ingredients.map(i => ({ key: i.id, value: i.id, text: i.name }))} />

        <Form.Field>
          <Button
            negative
            onClick={(e) => remove(e, index)}>remove
          </Button>
        </Form.Field>

      </Form.Group>
    )
  }
}
