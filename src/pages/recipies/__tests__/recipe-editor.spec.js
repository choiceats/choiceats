/* eslint-env jest */
// @flow
import React from 'react'
import { shallow } from 'enzyme'

import RecipeEditor from '../recipe-editor'

import type { Recipe } from 'types'

describe('Recipe: Recipe Editor::', () => {
  let fakeRecipe: Recipe
  beforeEach(() => {
    fakeRecipe = {
      id: null,
      author: 'Some dude',
      name: 'Cool Recipe',
      instructions: '1. Mix well',
      ingredients: []
    }
  })

  it('should render a from to fill out', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    expect(wrapper.find('form').length).toBe(1)
  })

  it('should render an input field for the Recipe Name', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const textField = wrapper.find('TextField')
    expect(textField.length).toBe(1)
    expect(textField.props().defaultValue).toBe(fakeRecipe.name)
    expect(textField.props().id).toBe('recipe-name')
    expect(textField.props().floatingLabelText).toBe('Recipe Name')
  })

  it('should render a rich text input for description', () => {
    const wrapper = shallow(<RecipeEditor recipe={fakeRecipe} />)
    const richTextComponent = wrapper.find('RichEditor')
    expect(richTextComponent.length).toBe(1)
    expect(richTextComponent.props().text).toBe(fakeRecipe.instructions)
  })
})
