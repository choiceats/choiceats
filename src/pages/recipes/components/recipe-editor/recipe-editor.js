/* globals HTMLInputElement, HTMLTextAreaElement, Event */
// @flow
import React, { Component } from 'react'
import { gql, graphql } from 'react-apollo'
import cloneDeep from 'lodash.clonedeep'
import { Input, Form, TextArea, Button } from 'semantic-ui-react'

import RecipeIngredientsEditor from './recipe-ingredients-editor'
import { DEFAULT_RECIPE } from '../../../../defaults'

import type { Recipe, Ingredient } from 'types'

type RecipeEditorProps = {
  recipe: ?Recipe;
  units: any;
  ingredients: any;
  mutate: (any) => window.Promise;
}

type RecipeEditorState = {
  editingRecipe: Recipe;
}

export class RecipeEditor extends Component {
  props: RecipeEditorProps
  state: RecipeEditorState

  componentWillMount () {
    const { recipe } = this.props
    this.setState(() => ({
      editingRecipe: recipe ? cloneDeep(recipe) : DEFAULT_RECIPE
    }))
  }

  updateIngredients (newIngredients: Ingredient[]) {
    const { editingRecipe } = this.state
    const newRecipe = {
      ...editingRecipe,
      ingredients: newIngredients
    }
    this.setState(() => ({editingRecipe: newRecipe}))
  }

  updateProp (e: Event, prop: string) {
    const { editingRecipe } = this.state
    if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
      const newRecipe = {
        ...editingRecipe,
        [prop]: e.target.value
      }
      this.setState(() => ({editingRecipe: newRecipe}))
    }
  }

  onSave (e: Event, recipe: Recipe) {
    const { mutate } = this.props
    e.preventDefault()

    mutate({
      variables: { recipe }
    })
    .then(({data}) => console.log('Got back data', data))
    .catch((error) => console.error('Got back error', error))
  }

  render () {
    const { editingRecipe } = this.state
    const { ingredients, units } = this.props

    return (
      <Form>
        <h1>Recipe Editor</h1>
        <Form.Field>
          <label>Recipe Name</label>
          <Input
            onChange={e => this.updateProp(e, 'name')}
            value={editingRecipe.name} />
        </Form.Field>

        <Form.Field>
          <label>Description</label>
          <TextArea
            onChange={e => this.updateProp(e, 'description')}
            value={editingRecipe.description} />
        </Form.Field>

        <Form.Field>
          <label>Instructions</label>
          <TextArea
            onChange={e => this.updateProp(e, 'instructions')}
            value={editingRecipe.instructions} />
        </Form.Field>

        <RecipeIngredientsEditor
          recipeIngredients={editingRecipe.ingredients}
          ingredients={ingredients}
          updateIngredients={newIngredients => this.updateIngredients(newIngredients)}
          units={units} />

        <Button onClick={e => this.onSave(e, editingRecipe)}>Save</Button>
      </Form>
    )
  }
}

const gqlStuff = gql`
mutation submitRepository($repoFullName: Recipe!) {
  submitRepository(repoFullName: $repoFullName) {
    recipe
  }
}
`

export default graphql(gqlStuff)(RecipeEditor)
