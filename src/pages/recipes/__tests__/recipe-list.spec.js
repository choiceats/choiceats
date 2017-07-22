/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import RecipeList from '../recipe-list'
import Recipe from '../recipe'

describe('Recipe List', () => {
  it('renders one recipe per recipe passed', () => {
    const recipes = [{ id: 1 }, { id: 2 }, { id: 3 }]
    const wrapper = shallow(<RecipeList recipes={recipes} />)
    expect(wrapper.find(Recipe).length).toBe(3)
  })
})
