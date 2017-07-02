// @flow
import React, { Component } from 'react'
import { Input, Form, TextArea, Button } from 'semantic-ui-react'

import RecipeIngredientsEditor from './recipe-ingredients-editor'
import { DEFAULT_RECIPE } from '../../../../defaults'

import type { Recipe } from 'types'

type RecipeEditorProps = {
  recipe: ?Recipe;
  units: any;
  ingredients: any;
}

export default class RecipeEditor extends Component {
  props: RecipeEditorProps
  state: {
    editingRecipe: Recipe
  }

  componetWillMount () {
    this.setState(() => ({

    }))
  }

  addIngredient () {
    console.log('oh ya')
  }

  render () {
    const { recipe, ingredients, units } = this.props
    const useRecipe = recipe || DEFAULT_RECIPE

    return (
      <Form>
        <h1>Recipe Editor</h1>
        <Form.Field>
          <label>Recipe Name</label>
          <Input value={useRecipe.name} />
        </Form.Field>

        <Form.Field>
          <label>Description</label>
          <TextArea value={useRecipe.description} />
        </Form.Field>

        <Form.Field>
          <label>Instructions</label>
          <TextArea value={useRecipe.instructions} />
        </Form.Field>

        <RecipeIngredientsEditor
          recipe={recipe}
          ingredients={ingredients}
          units={units} />
        <Form.Field>
          <Button primary
            onClick={() => this.addIngredient()}>Add Ingredient</Button>
        </Form.Field>
      </Form>
    )
  }
}
