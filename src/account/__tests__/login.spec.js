/* eslint-env jest */
import React from 'react'
import { shallow } from 'enzyme'

import { LoginForm } from '../login'
import { login } from '../../services/users'

jest.mock('../../services/users')

function testAsync (asyncTest) {
  return (done) => {
    return asyncTest()
      .then(() => {
        done()
      })
  }
}

describe('Login Form', () => {
  let history
  let match
  let wrapper

  beforeEach(() => {
    history = {
      push: jest.fn()
    }
    match = { url: 'hello.world' }
    wrapper = shallow(
      <LoginForm
        history={history}
        match={match} />
    )
  })

  it('should display a login form', () => {
    expect(wrapper.find('form').length).toBe(1)
  })

  it('should update the email address when input has changed', () => {
    const event = {}
    event.target = document.createElement('input')
    event.target.value = 'jim@gmail.com'

    wrapper.find('TextField').at(0).simulate('change', event)
    expect(wrapper.instance().email).toEqual('jim@gmail.com')
  })

  it('should update the password when input has changed', () => {
    const event = {}
    event.target = document.createElement('input')
    event.target.value = 'secret'

    wrapper.find('TextField').at(1).simulate('change', event)
    expect(wrapper.instance().password).toEqual('secret')
  })

  describe('form submittion', () => {
    let event

    beforeEach(() => {
      history.push.mockClear()
      event = {
        preventDefault: jest.fn()
      }
    })

    it('should prefent the default form submition', () => {
      wrapper.find('RaisedButton').simulate('click', event)
      expect(event.preventDefault).toBeCalled()
    })

    it('should try to login if the form is submited', () => {
      const event = {}
      event.preventDefault = jest.fn()
      wrapper.instance().email = 'joe'
      wrapper.instance().password = 'secret'
      wrapper.find('RaisedButton').simulate('click', event)

      expect(login).toBeCalledWith('joe', 'secret')
    })

    it('should redirect (history) to the main page after the login is successful', testAsync(async () => {
      const event = {}
      let loginPromise
      login.mockImplementation(() => {
        loginPromise = Promise.resolve()
        return loginPromise
      })
      event.preventDefault = jest.fn()
      wrapper.find('RaisedButton').simulate('click', event)

      await loginPromise
      expect(history.push).toBeCalledWith('/')
    }))

    xit('should show an error if login failed', (done) => {
      const event = {}
      let loginPromise
      login.mockImplementation(() => {
        loginPromise = new Promise((resolve, reject) => {
          setTimeout(() => reject(), 2000)
        })
        return loginPromise
      })

      event.preventDefault = jest.fn()
      wrapper.find('RaisedButton').simulate('click', event)

      loginPromise
        .then(() => {
          console.log('SHOULD FAILE')
          done()
        })
        .catch((e) => {
          console.log('WRApp')
          wrapper.update()
          console.log('wrapper.find', wrapper.instance().state)

          expect(wrapper.find('Error').length).toEqual('BAD PASSWORD!')
          done()
        })
    })
  })
})
