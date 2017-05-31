// @flow

import React, { Component } from 'react'
import { Route, Link } from 'react-router-dom'
import styled from 'styled-components'

import { LoginForm } from './form'
import { Signup } from './signup'

export class Account extends Component {
  getLink () {
    const { match, location } = this.props
    console.log('ULR', match.url, location.pathname)
    return location.pathname.endsWith('sign-up')
      ? <Link to={`${match.url}`}>Login</Link>
      : <Link to={`${match.url}/sign-up`}>Sign up</Link>
  }

  render () {
    const { match } = this.props

    return <AccountContainer>
      <ul>
        <li>
          { this.getLink() }
        </li>
      </ul>
      <Route exact path={match.url} component={LoginForm} />
      <Route path={`${match.url}/sign-up`} component={Signup} />
    </AccountContainer>
  }
}


const AccountContainer = styled.div``
