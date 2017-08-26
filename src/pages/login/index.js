// @flow
import React, { Component } from 'react'
import { withRouter, Link } from 'react-router-dom'
import { connect } from 'react-redux'

import { Button, Form, Input } from 'semantic-ui-react'

import { login as loginAction } from '../../state/action-creators'
import { login } from '../../services/users'

import { FormContainer, FormHeader, Error } from '../form-styles'

import type { ContextRouter } from 'react-router-dom'
import type { ConnectedProps } from 'types'

type PROPS = ContextRouter & ConnectedProps
type STATE = {
  error: boolean,
  message?: string
}

export class Login extends Component<PROPS, STATE> {
  onSubmit: (e: Event) => Promise<any>
  onEmailChange: (e: KeyboardEvent) => void
  onPasswordChange: (e: KeyboardEvent) => void

  email: string
  password: string

  constructor(props: ContextRouter & ConnectedProps) {
    super(props)
    this.state = {
      error: false,
      signedIn: false
    }

    this.onSubmit = this.handleSubmit.bind(this)
    this.onEmailChange = this.handleOnEmailChange.bind(this)
    this.onPasswordChange = this.handleOnPasswordChange.bind(this)
  }

  async handleSubmit(e: Event): Promise<any> {
    const { history, dispatch } = this.props
    e.preventDefault()
    try {
      const userInfo = await login(this.email, this.password)
      dispatch(loginAction(userInfo))
      history.push('/')
    } catch (e) {
      this.setState({ error: true, message: 'Bad password, bad!' })
    }
  }

  handleOnEmailChange(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.email = e.target.value
    }
  }

  handleOnPasswordChange(e: KeyboardEvent) {
    if (e.target instanceof HTMLInputElement) {
      this.password = e.target.value
    }
  }

  render() {
    const { match } = this.props
    return (
      <FormContainer>
        <Form onSubmit={this.onSubmit}>
          <FormHeader>Login</FormHeader>
          <Form.Field>
            <label>Email</label>
            <Input onChange={this.onEmailChange} />
          </Form.Field>
          <Form.Field>
            <label>Password</label>
            <Input onChange={this.onPasswordChange} type="password" />
          </Form.Field>

          <br />
          <Button primary type="submit">
            Login
          </Button>

          <br />
          <br />
          <Button>
            <Link to={`${match.url}/sign-up`}>Sign up</Link>
          </Button>
          {this.state.error
            ? <Error id="form-error">BAD PASSWORD!</Error>
            : null}
        </Form>
      </FormContainer>
    )
  }
}

export default withRouter(connect()(Login))
