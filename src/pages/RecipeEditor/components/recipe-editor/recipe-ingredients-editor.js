/* global MouseEvent */
// @flow
import React, { Component } from 'react'
import cloneDeep from 'lodash.clonedeep'
import { Form, Button } from 'semantic-ui-react'

import RecipeIngredientEditor from './recipe-ingredient-editor'
import { DEFAULT_RECIPE_INGREDIENT } from '../../../../defaults'

type PROPS = {
  recipeIngredients: any[],
  updateIngredients: any => void,
  ingredients: { id: number, name: string }[],
  units: { id: number, name: string, abbr: string }[]
}

export default class RecipeIngredientsEditor extends Component<PROPS> {
  addIngredient(e: MouseEvent) {
    e.preventDefault()

    const { recipeIngredients, updateIngredients } = this.props
    const recipeIngredientsCopy = cloneDeep(recipeIngredients)
    recipeIngredientsCopy.push(cloneDeep(DEFAULT_RECIPE_INGREDIENT))
    updateIngredients(recipeIngredientsCopy)
  }

  removeIngredient(e: MouseEvent, index: number) {
    e.preventDefault()

    const { recipeIngredients, updateIngredients } = this.props
    const recipeIngredientsCopy = [
      ...recipeIngredients.slice(0, index),
      ...recipeIngredients.slice(index + 1)
    ]
    updateIngredients(recipeIngredientsCopy)
  }

  updatedIngredient(ingredient: any, index: number) {
    const { recipeIngredients, updateIngredients } = this.props
    const recipeIngredientsCopy = cloneDeep(recipeIngredients)
    recipeIngredientsCopy[index] = ingredient
    updateIngredients(recipeIngredientsCopy)
  }

  render() {
    const { recipeIngredients, ingredients, units } = this.props
    return (
      <div>
        <label>Ingredients</label>
        {recipeIngredients.map((ingredient, index) => (
          <RecipeIngredientEditor
            key={index}
            index={index}
            ingredients={ingredients}
            units={units}
            ingredient={ingredient}
            update={this.updatedIngredient.bind(this)}
            remove={this.removeIngredient.bind(this)}
          />
        ))}
        <Form.Field>
          <Button primary onClick={e => this.addIngredient(e)}>
            Add Ingredient
          </Button>
        </Form.Field>
      </div>
    )
  }
}
