/* global HTMLInputElement, KeyboardEvent, Event */
// @flow
import React, { Component } from 'react'
import { Redirect } from 'react-router-dom'

import { Button, Form, Input } from 'semantic-ui-react'

import { FormContainer, FormHeader } from '../form-styles'

import { register } from '../../services/users'

type SignupField =
  | 'email'
  | 'firstName'
  | 'lastName'
  | 'password'
  | 'passwordCheck'
type State = {
  registered: boolean
}

export default class Signup extends Component<void, State> {
  inputs = {
    email: '',
    firstName: '',
    lastName: '',
    password: '',
    passwordCheck: ''
  }

  state = { registered: false }

  handleInputChange(key: SignupField, e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.inputs[key] = e.target.value
    }
  }

  handleSubmit(e: Event) {
    e.preventDefault()
    if (this.inputs.password === this.inputs.passwordCheck) {
      register(this.inputs)
      this.setState(() => ({ registered: true }))
    }
    console.log('passwords must match')
  }

  render() {
    if (this.state.registered) {
      return <Redirect to={{ pathname: '/' }} />
    }

    return (
      <FormContainer>
        <Form onSubmit={e => this.handleSubmit(e)}>
          <FormHeader>Signup!</FormHeader>
          <Form.Field>
            <label>Email</label>
            <Input onChange={e => this.handleInputChange('email', e)} />
          </Form.Field>
          <Form.Field>
            <label>First Name</label>
            <Input onChange={e => this.handleInputChange('firstName', e)} />
          </Form.Field>
          <Form.Field>
            <label>Last Name</label>
            <Input onChange={e => this.handleInputChange('lastName', e)} />
          </Form.Field>
          <Form.Field>
            <label>Password</label>
            <Input
              type="password"
              onChange={e => this.handleInputChange('password', e)}
            />
          </Form.Field>
          <Form.Field>
            <label>Re-Password</label>
            <Input
              type="password"
              onChange={e => this.handleInputChange('passwordCheck', e)}
            />
          </Form.Field>

          <br />
          <Button type="submit" primary onClick={e => this.handleSubmit(e)}>
            Signup
          </Button>
        </Form>
      </FormContainer>
    )
  }
}
