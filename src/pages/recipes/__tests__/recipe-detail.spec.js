/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import { DEFAULT_RECIPE } from '../../../defaults'
import { RecipeDetail } from '../recipe-detail'
import IngredientList from '../components/ingredient-list'

describe('Recipe Detail', () => {
  it('should render ingredients', () => {
    const wrapper = shallow(<RecipeDetail data={{ recipe: DEFAULT_RECIPE }} />)
    expect(wrapper.find(IngredientList).length).toBe(1)
  })

  it('should show "loading" if we are loading', () => {
    const wrapper = shallow(<RecipeDetail data={{ loading: true }} />)
    expect(wrapper.text()).toContain('LOADING')
  })
})
