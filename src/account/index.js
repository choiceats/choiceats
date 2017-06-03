// @flow

import React, { Component } from 'react'
import { Route } from 'react-router-dom'
import styled from 'styled-components'

import { LoginForm } from './login'
import { Signup } from './signup'

export class Account extends Component {
  render () {
    const { match } = this.props

    return (
      <AccountContainer>
        <Route exact path={match.url} component={LoginForm} />
        <Route path={`${match.url}/sign-up`} component={Signup} />
      </AccountContainer>
    )
  }
}

const AccountContainer = styled.div``
