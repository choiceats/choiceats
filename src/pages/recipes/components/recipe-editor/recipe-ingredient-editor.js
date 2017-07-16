/* global Event, KeyboardEvent, HTMLInputElement */
// @flow
import React, { Component } from 'react'
import { Select, Input, Form, Button } from 'semantic-ui-react'
import IngredientTypeahead from './ingredient-typeahead'

import type { Ingredient } from 'types'

import './recipe-editor.css'

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

  updateIngredient (selectedIngredient: Ingredient) {
    const { ingredient, update, index } = this.props
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
      <Form.Group className='recipe-editor-group' >
        <Form.Field
          control={Input}
          width={2}
          onChange={(e) => this.updateQuantity(e)}
          value={ingredient.quantity}
          placeholder='#' />

        <Form.Field
          control={Select}
          placeholder='Units'
          size='mini'
          value={ingredient.unit ? ingredient.unit.id : ''}
          width={4}
          selection
          onChange={this.updateUnit.bind(this)}
          options={unitOptionsWithBlank} />

        <Form.Field width={6}>
          <IngredientTypeahead
            selectedIngredient={ingredient}
            onSelect={this.updateIngredient.bind(this)}
            ingredients={ingredients} />
        </Form.Field>
        <Form.Field>
          <Button
            negative
            onClick={(e) => remove(e, index)}>X
          </Button>
        </Form.Field>

      </Form.Group>
    )
  }
}
