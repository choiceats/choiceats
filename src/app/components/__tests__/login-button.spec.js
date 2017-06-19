/* eslint-env jest */
// @flow
import React from 'react'
import { shallow } from 'enzyme'

import LoginButton from '../login-button'

describe('Login Form', () => {
  let wrapper

  beforeEach(() => {
    wrapper = shallow(
      <LoginButton />
    )
  })

  it('should display a Link to "/login"', () => {
    expect(wrapper.find('Link').length).toBe(1)
    expect(wrapper.find('Link').props().to).toEqual('/login')
  })

  it('should display a Button', () => {
    expect(wrapper.find('Button').length).toBe(1)
  })
})
