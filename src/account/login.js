/* global Event, KeyboardEvent, HTMLInputElement */
// @flow
import React, { Component } from 'react'
import { withRouter, Link } from 'react-router-dom'

import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'
import FlatButton from 'material-ui/FlatButton'

import { login } from '../services/users'

import { FormContainer, FormHeader, Error } from './styles'


import type { WithRouterProps } from '../../types/standard'

export class LoginForm extends Component {
  props: WithRouterProps

  onSubmit: (e: Event) => void
  onEmailChange: (e: KeyboardEvent) => void
  onPasswordChange: (e: KeyboardEvent) => void

  email: string
  password: string

  state: { error: boolean, message?: string }

  constructor (props: WithRouterProps) {
    super(props)
    this.state = {
      error: false,
      signedIn: false
    }

    this.onSubmit = this.handleSubmit.bind(this)
    this.onEmailChange = this.handleOnEmailChange.bind(this)
    this.onPasswordChange = this.handleOnPasswordChange.bind(this)
  }

  handleSubmit (e: Event) {
    e.preventDefault()

    login(this.email, this.password)
      .then(() => this.setState(() => ({ signedIn: true })))
      .catch((e: any) => {
        this.setState(() => ({ error: true, message: 'Bad password, bad!' }))
      })
  }

  handleOnEmailChange (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.email = e.target.value
    }
  }

  handleOnPasswordChange (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.password = e.target.value
    }
  }

  navigateToSignup () {
    const { history } = this.props
    history.push('/')
  }

  render () {
    const { match } = this.props
    return (
      <FormContainer>
        <form onSubmit={this.onSubmit}>
          <FormHeader>Login</FormHeader>
          <TextField
            onChange={this.onEmailChange}
            hintText='Email'
            floatingLabelText='Email Address'
            fullWidth
            type='text'
          />
          <TextField
            onChange={this.onPasswordChange}
            hintText='Password Field'
            floatingLabelText='Password'
            fullWidth
            type='password'
          />
          <br />
          <RaisedButton
            label='Login'
            fullWidth
            primary
            onClick={(e) => this.handleSubmit(e)}
          />
          <br />
          <br />
          <FlatButton>
            <Link to={`${match.url}/sign-up`}>Sign up</Link>
          </FlatButton>
          { (this.state.error)
            ? <Error>BAD PASSWORD!</Error>
            : null
          }
        </form>
      </FormContainer>
    )
  }
}

export default withRouter(LoginForm)
