/* global HTMLInputElement, KeyboardEvent, Event */
// @flow
import React, { Component } from 'react'
import { Redirect } from 'react-router-dom'

import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'

import { FormContainer, FormHeader } from './styles'

import { register } from '../services/users'

type SignupField =
  'email' | 'firstName' | 'lastName' | 'password' | 'passwordCheck'

export class Signup extends Component {
  inputs = {
    email: '',
    firstName: '',
    lastName: '',
    password: '',
    passwordCheck: ''
  }

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
      <FormContainer>
        <form onSubmit={(e) => this.handleSubmit(e)}>
          <FormHeader>Signup!</FormHeader>
          <TextField
            floatingLabelText='Email'
            fullWidth
            onChange={(e) => this.handleInputChange('email', e)} />

          <TextField
            floatingLabelText='First Name'
            fullWidth
            onChange={(e) => this.handleInputChange('firstName', e)} />

          <TextField
            floatingLabelText='Last Name'
            fullWidth
            onChange={(e) => this.handleInputChange('lastName', e)} />

          <TextField
            floatingLabelText='Password'
            fullWidth
            onChange={(e) => this.handleInputChange('password', e)} />

          <TextField
            floatingLabelText='Re-Password'
            fullWidth
            onChange={(e) => this.handleInputChange('passwordCheck', e)} />
          <br />
          <RaisedButton
            label='Signup'
            fullWidth
            primary
            onClick={(e) => this.handleSubmit(e)}
          />
        </form>
      </FormContainer>
    )
  }
}
