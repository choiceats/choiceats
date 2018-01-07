/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import { DEFAULT_RECIPE } from '../../../defaults'
import { RecipeDetail } from '../recipe-detail'
import IngredientList from '../components/ingredient-list'

describe('Recipe Detail', () => {
  it('should render ingredients', () => {
    const wrapper = shallow(<RecipeDetail recipe={DEFAULT_RECIPE} />)
    expect(wrapper.find(IngredientList).length).toBe(1)
  })
})
