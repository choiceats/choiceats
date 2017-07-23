/* globals HTMLInputElement, HTMLTextAreaElement, Event */
// @flow
import React, { Component } from 'react'
import styled, { keyframes } from 'styled-components'
import cloneDeep from 'lodash.clonedeep'
import { Input, Form, TextArea, Button, Loader } from 'semantic-ui-react'

import RecipeIngredientsEditor from './recipe-ingredients-editor'
import { DEFAULT_RECIPE } from '../../../../defaults'

import type { Recipe, Ingredient } from 'types'

import './recipe-editor.css'

type RecipeEditorProps = {
  recipe: ?Recipe,
  units: any,
  ingredients: any,
  onSave: Recipe => void,
  isSavingRecipe?: boolean,
  recipeSaveError?: boolean
}

type RecipeEditorState = {
  editingRecipe: Recipe
}

export default class RecipeEditor extends Component {
  props: RecipeEditorProps
  state: RecipeEditorState

  componentWillMount() {
    const { recipe } = this.props
    this.setState(() => ({
      editingRecipe: recipe ? cloneDeep(recipe) : DEFAULT_RECIPE
    }))
  }

  updateIngredients(newIngredients: Ingredient[]) {
    const { editingRecipe } = this.state
    const newRecipe = {
      ...editingRecipe,
      ingredients: newIngredients
    }
    this.setState(() => ({ editingRecipe: newRecipe }))
  }

  updateProp(e: Event, prop: string) {
    const { editingRecipe } = this.state
    if (
      e.target instanceof HTMLInputElement ||
      e.target instanceof HTMLTextAreaElement
    ) {
      const newRecipe = {
        ...editingRecipe,
        [prop]: e.target.value
      }
      this.setState(() => ({ editingRecipe: newRecipe }))
    }
  }

  onSave(e: Event, recipe: Recipe) {
    const { onSave } = this.props
    e.preventDefault()
    onSave(recipe)
  }

  render() {
    const { editingRecipe } = this.state
    const {
      ingredients,
      isSavingRecipe = false,
      recipeSaveError,
      units
    } = this.props

    return (
      <RecipeEditorContainer>
        <Form className="recipe-editor-form">
          <h1>Recipe Editor</h1>
          <Form.Field>
            <label>Recipe Name</label>
            <Input
              onChange={e => this.updateProp(e, 'name')}
              value={editingRecipe.name}
            />
          </Form.Field>

          <Form.Field>
            <label>Description</label>
            <TextArea
              onChange={e => this.updateProp(e, 'description')}
              value={editingRecipe.description}
            />
          </Form.Field>

          <RecipeIngredientsEditor
            recipeIngredients={editingRecipe.ingredients}
            ingredients={ingredients}
            updateIngredients={newIngredients =>
              this.updateIngredients(newIngredients)}
            units={units}
          />

          <Form.Field>
            <label>Instructions</label>
            <TextArea
              onChange={e => this.updateProp(e, 'instructions')}
              value={editingRecipe.instructions}
            />
          </Form.Field>

          {!isSavingRecipe
            ? <Button onClick={e => this.onSave(e, editingRecipe)}>Save</Button>
            : <Loader inline active size="tiny">
                Saving
              </Loader>}
          {recipeSaveError && <SaveError>Unable to save recipe.</SaveError>}
        </Form>
      </RecipeEditorContainer>
    )
  }
}

const slideIn = keyframes`
  from {
    margin-left: 100%;
  }

  to {
    margin-left: 0%;
  }
`

const RecipeEditorContainer = styled.div`
  animation: ${slideIn} .25s linear;
  min-width: 260px;
`

const SaveError = styled.div`color: red;`
// based off 50px padding and 10px margin to give 320px look, supporting iPhone5 and wider
