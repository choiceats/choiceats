/* global Event, KeyboardEvent, HTMLInputElement */
// @flow

import React, { Component } from 'react'
import styled from 'styled-components'

import { login, setToken } from '../services/users'

export class Login extends Component {
  onSubmit: (e: Event) => void
  onEmailChange: (e: KeyboardEvent) => void
  onPasswordChange: (e: KeyboardEvent) => void

  email: string
  password: string

  state: { isLoggedIn: boolean, error: boolean, message?: string }

  constructor (props: {}) {
    super(props)
    this.state = {
      error: false,
      isLoggedIn: false
    }

    this.onSubmit = this.handleSubmit.bind(this)
    this.onEmailChange = this.handleOnEmailChange.bind(this)
    this.onPasswordChange = this.handleOnPasswordChange.bind(this)
  }

  handleSubmit (e: Event) {
    e.preventDefault()

    login(this.email, this.password)
      .catch((e: any) => {
        this.setState(() => ({ error: true, message: 'Bad password, bad!' }))
      })
  }

  handleOnEmailChange (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.email = e.target.value
    }
    console.log('email', this.email)
  }

  handleOnPasswordChange (e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.password = e.target.value
    }
    console.log('password', this.password)
  }

  render () {
    if (this.state.isLoggedIn) {
      return null
    }

    return <LoginContainer>
      <form onSubmit={this.onSubmit}>
        <LoginHeader>Login</LoginHeader>
        <InputLabel>Email:</InputLabel>
        <input name='email' type='text' onChange={this.onEmailChange} />
        <InputLabel>Password:</InputLabel>
        <input name='password' type='password' onChange={this.onPasswordChange} />
        <input type='submit' value='Login' />
      </form>
      { (this.state.error)
        ? <Error>BAD PASSWORD!</Error>
        : null
      }
    </LoginContainer>
  }
}

const LoginContainer = styled.div``

const LoginHeader = styled.h1`
  font-size: 15px;
`

const Error = styled.div`
  border: 1px solid red;
  background-color: #ff5555;
  padding: 5px 10px;
`

const InputLabel = styled.p`
  font-size: 13px;
  color: #333;
`
