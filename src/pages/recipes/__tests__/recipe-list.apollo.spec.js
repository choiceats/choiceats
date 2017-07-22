/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'
import Loading from '../../shared-components/loading'

import { RecipeListApollo } from '../recipe-list.apollo.js'

describe('Recipe List Apollo', () => {
  it('should show Loading component when loading recipes', () => {
    const wrapper = shallow(<RecipeListApollo data={{ loading: 'loading' }} />)
    expect(wrapper.find(Loading).length).toBe(1)
  })
})
