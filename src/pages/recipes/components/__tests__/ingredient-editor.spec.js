/* eslint-env jest */
// @flow
import React from 'react'
import { shallow } from 'enzyme'

import { DEFAULT_INGREDIENT } from '../../../../defaults'
import IngredientEditor from '../ingredient-editor'

describe('Recipies : Components : IngredientEditor::', () => {
  let fakeIngredient
  beforeEach(() => {
    fakeIngredient = { ...DEFAULT_INGREDIENT, id: 123 }
  })

  it('should show a text field for the ingredient name', () => {
    const wrapper = shallow(<IngredientEditor ingredient={fakeIngredient} />)
    const textField = wrapper.find('Input')
    expect(textField.length).toBe(1)
    expect(textField.props().id).toBe('ingredient-name-123')
    expect(textField.props().defaultValue).toBe(fakeIngredient.name)
  })
})
