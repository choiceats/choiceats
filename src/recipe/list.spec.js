import React from 'react'
import { RecipeList, Loading } from './List'
import {shallow} from 'enzyme'

describe('RecipeList', () => {
	let props = null
	beforeEach(function () {
		props = {
      data: null
		}
	})

	afterEach(function () {
	})

	describe('render', function() {
		it('renders Loading element when data is missing', function() {
			const wrapper = shallow(<RecipeList {...props} userToken={null} />)
			expect(wrapper.find(Loading).length).toBe(1)
    });
	})
})
