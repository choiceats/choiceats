/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import { RecipeListApollo } from '../recipe-list.apollo.js'

describe('Recipe List Apollo', () => {
  it('should show "loading" if we are loading', () => {
    const wrapper = shallow(<RecipeListApollo data={{ loading: 'loading' }} />)
    expect(wrapper.dive().text()).toContain('LOADING')
  })
})
