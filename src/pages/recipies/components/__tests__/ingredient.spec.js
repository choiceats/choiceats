/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import Ingredient from '../ingredient'

describe('Recipe Ingredient::', () => {
  it('should render an ingredient\'s info', () => {
    const ingredient = {
      name: 'Sugar',
      quantity: 13,
      unit: {
        name: 'Cups',
        abbr: 'C.'
      }
    }

    const wrapper = shallow(<Ingredient ingredient={ingredient} />).dive()
    expect(wrapper.text()).toContain('Sugar')
    expect(wrapper.text()).toContain('13')
    expect(wrapper.text()).toContain('C.')
  })
})
