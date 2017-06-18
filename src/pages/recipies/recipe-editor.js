// @flow
import React, { Component } from 'react'
import TextField from 'material-ui/TextField'

import RichEditor from './components/rich-editor'
import { DEFAULT_RECIPE } from '../../defaults'

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
      <form>
        <h1>Recipe Editor</h1>
        <TextField
          id='recipe-name'
          floatingLabelText='Recipe Name'
          defaultValue={useRecipe.name} />

        <RichEditor text={useRecipe.instructions} />
      </form>
    )
  }
}
