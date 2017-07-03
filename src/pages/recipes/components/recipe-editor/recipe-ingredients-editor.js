/* global Event, MouseEvent, KeyboardEvent, HTMLInputElement */
// @flow
import React, { Component } from 'react'
import cloneDeep from 'lodash.clonedeep'
import { Dropdown, Select, Input, Form, Button } from 'semantic-ui-react'

import { DEFAULT_INGREDIENT } from '../../../../defaults'

import type { Recipe } from 'types'

type RecipeIngredientsEditorProps = {
  recipe: ?Recipe;
  ingredients: {id: number, name: string}[];
  units: {id: number, name: string, abbr: string}[];
}

type RecipeIngredientsEditorState = {
  editingRecipe: Recipe;
}

export default class RecipeIngredientsEditor extends Component {
  props: RecipeIngredientsEditorProps
  state: RecipeIngredientsEditorState

  componentWillMount () {
    const { recipe } = this.props
    this.setState(() => ({
      editingRecipe: cloneDeep(recipe)
    }))
  }

  addIngredient (e: MouseEvent) {
    e.preventDefault()

    const { editingRecipe } = this.state
    editingRecipe.ingredients.push(cloneDeep(DEFAULT_INGREDIENT))
    this.setState(() => ({editingRecipe}))
  }

  removeIngredient (e: MouseEvent, index: number) {
    e.preventDefault()

    const { editingRecipe } = this.state
    delete editingRecipe.ingredients[index]
    this.setState(() => ({editingRecipe}))
  }

  updatedIngredient (ingredient: any, index: number) {
    const { editingRecipe } = this.state
    editingRecipe.ingredients[index] = ingredient
    this.setState(() => ({editingRecipe}))
  }

  render () {
    const { ingredients, units } = this.props
    const { editingRecipe } = this.state
    return <div>
      <label>Ingredients</label>
      { editingRecipe && editingRecipe.ingredients.map((ingredient, index) =>
        <RecipeIngredientEditor
          key={index}
          index={index}
          ingredients={ingredients}
          units={units}
          ingredient={ingredient}
          update={this.updatedIngredient.bind(this)}
          remove={this.removeIngredient.bind(this)} />
      )}
      <Form.Field>
        <Button primary
          onClick={(e) => this.addIngredient(e)}>Add Ingredient</Button>
      </Form.Field>
    </div>
  }
}

class RecipeIngredientEditor extends Component {
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

  updateUnit (e: Event, data) {
    const { ingredient, update, index, units } = this.props
    const selectedUnit = units.find(u => u.id === data.value)
    const updatedIngredient = {
      ...ingredient,
      unit: selectedUnit
    }

    update(updatedIngredient, index)
  }

  updateIngredient (e: Event, data) {
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
          value={ingredient.unit ? ingredient.unit.id : null}
          width={4}
          selection
          onChange={this.updateUnit.bind(this)}
          options={units.map(i => ({ key: i.id, value: i.id, text: i.abbr }))} />

        <Form.Field
          control={Dropdown}
          width={8}
          placeholder='Enter Ingredient'
          search
          selection
          onChange={this.updateIngredient.bind(this)}
          value={ingredient.id}
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
