/* eslint-env jest */
// @flow
import React from 'react'
import { shallow } from 'enzyme'
import { Input, Form } from 'semantic-ui-react'

import RecipeEditor from '../recipe-editor'
import { DEFAULT_INGREDIENT } from '../../../../defaults'

import type { Recipe } from 'types'

describe('Recipe: Recipe Editor::', () => {
  let fakeRecipe: Recipe
  beforeEach(() => {
    fakeRecipe = {
      id: null,
      author: 'Some dude',
      name: 'Cool Recipe',
      instructions: '1. Mix well',
      ingredients: [],
      description: ''
    }
  })

  it('should render a from to fill out', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    expect(wrapper.find(Form).length).toBe(1)
  })

  it('should render an input field for the Recipe Name', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const textField = wrapper.find(Form.Field)
    expect(textField.length).toBe(1)

    const label = textField.find('label')
    expect(label.length).toBe(1)
    expect(label.text()).toBe('Recipe Name')

    const input = textField.find(Input)
    expect(input.length).toBe(1)
    expect(input.props().defaultValue).toBe(fakeRecipe.name)
  })

  it('should render a rich text input for description', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const richTextComponent = wrapper.find('RichEditor')
    expect(richTextComponent.length).toBe(1)
    expect(richTextComponent.props().text).toBe(fakeRecipe.instructions)
  })

  it('should not render an ingredient editor if we don\'t have any ingredients', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const ingredientComponent = wrapper.find('IngredientEditor')
    expect(ingredientComponent.length).toBe(0)
  })

  it('should render an ingredient editor if we have ingredients', () => {
    fakeRecipe.ingredients.push({ ...DEFAULT_INGREDIENT })
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const ingredientComponent = wrapper.find('IngredientEditor')
    expect(ingredientComponent.length).toBe(1)
  })
})
