/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import { RecipeList } from '../recipe-list'

describe('Recipe List', () => {
  it('should show "loading" if we are loading', () => {
    const wrapper = shallow(<RecipeList data={{ loading: true }} />)
    expect(wrapper.dive().text()).toContain('LOADING')
  })
})

