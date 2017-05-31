/* global HTMLInputElement, KeyboardEvent, Event */
// @flow
import React, { Component } from 'react'
import styled from 'styled-components'
import { Redirect } from 'react-router-dom'

import { register } from '../services/users'

type SignupField =
  'email' | 'firstName' | 'lastName' | 'password' | 'passwordCheck'

export class Signup extends Component {
  inputs: {
    email: string,
    firstName: string,
    lastName: string,
    password: string,
    passwordCheck: string
  } = {}

  state: { registered: boolean } = { registered: false }

  handleInputChange (key: SignupField, e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.inputs[key] = e.target.value
    }
  }

  handleSubmit (e: Event) {
    e.preventDefault()
    if (this.inputs.password === this.inputs.passwordCheck) {
      register(this.inputs)
      this.setState(() => ({ registered: true }))
    }
    console.log('passwords must match')
  }

  render () {
    if (this.state.registered) {
      return <Redirect to={{ pathname: '/' }} />
    }

    return (
      <SignupContainer>
        <form onSubmit={(e) => this.handleSubmit(e)}>
          <h1>Signup!</h1>
          <p>Email</p>
          <input type='text' onChange={(e) => this.handleInputChange('email', e)} />
          <p>First Name</p>
          <input type='text' onChange={(e) => this.handleInputChange('firstName', e)} />
          <p>Last Name</p>
          <input type='text' onChange={(e) => this.handleInputChange('lastName', e)} />
          <p>Password</p>
          <input type='text' onChange={(e) => this.handleInputChange('password', e)} />
          <p>Re-Password</p>
          <input type='text' onChange={(e) => this.handleInputChange('passwordCheck', e)} />
          <br />
          <input type='submit' value='SIGN UP!' />
        </form>
      </SignupContainer>
    )
  }
}


const SignupContainer = styled.div``
