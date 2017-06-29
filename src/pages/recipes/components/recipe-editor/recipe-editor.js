// @flow
import React, { Component } from 'react'
import { Input, Form } from 'semantic-ui-react'

import RichEditor from './rich-editor'
// import RecipeIngredientsEditor from './recipe-ingredients-editor'
import { DEFAULT_RECIPE } from '../../../../defaults'

import type { Recipe } from 'types'

type RecipeEditorProps = {
  recipe: ?Recipe
}

export default class RecipeEditor extends Component {
  props: RecipeEditorProps

  render () {
    const { recipe } = this.props
    const useRecipe = recipe || DEFAULT_RECIPE

    return (
      <Form>
        <h1>Recipe Editor</h1>
        <Form.Field>
          <label>Recipe Name</label>
          <Input
            defaultValue={useRecipe.name} />
        </Form.Field>

        <h2>Ingredients</h2>
        {/* { useRecipe.ingredients.map(i => <IngredientEditor key={i.id} ingredient={i} />) } */}

        <RichEditor text={useRecipe.instructions} />
      </Form>
    )
  }
}
