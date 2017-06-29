// @flow
import React, { Component } from 'react'
import { Dropdown, Input } from 'semantic-ui-react'

type IngredientEditorProps = {
  ingredients: {id: number, name: string}[];
  units: {id: number, name: string, abbr: string}[];
}

export default class IngredientEditor extends Component {
  props: IngredientEditorProps
  render () {
    const { ingredients, units } = this.props

    return <div>
      <Input
        placeholder='#' />
      <Dropdown placeholder='Units'
        selection
        options={units.map(i => ({ key: i.id, value: i.id, text: i.abbr }))} />

      <Dropdown placeholder='Enter Ingredient'
        search
        selection
        options={ingredients.map(i => ({ key: i.id, value: i.id, text: i.name }))} />
    </div>
  }
}
