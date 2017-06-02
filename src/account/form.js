/* global Event, KeyboardEvent, HTMLInputElement */
// @flow

import React, { Component } from 'react'
import styled from 'styled-components'
import TextField from 'material-ui/TextField'
import RaisedButton from 'material-ui/RaisedButton'
import FlatButton from 'material-ui/FlatButton'

import { Redirect } from 'react-router-dom'

import { login } from '../services/users'

export class LoginForm extends Component {
  onSubmit: (e: Event) => void
  onEmailChange: (e: KeyboardEvent) => void
  onPasswordChange: (e: KeyboardEvent) => void

  email: string
  password: string

  state: { error: boolean, message?: string, signedIn: boolean }

  constructor (props: {}) {
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

  render () {
    if (this.state.signedIn) {
      return <Redirect to={{ pathname: '/' }} />
    }

    return (
      <FormContainer>
        <form onSubmit={this.onSubmit}>
          <LoginHeader>Login</LoginHeader>
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
          <br /><br />
          <FlatButton
            label='Sign Up'
            
            />
          { (this.state.error)
            ? <Error>BAD PASSWORD!</Error>
            : null
          }
        </form>
      </FormContainer>
    )
  }
}


const LoginHeader = styled.h1`
  font-family: Fira Code;
  font-size: 25px;
`

const Error = styled.div`
  border: 1px solid red;
  background-color: #ff5555;
  padding: 5px 10px;
`

const FormContainer = styled.div`
  width: 500px;
  margin: auto
`
