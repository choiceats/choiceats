// @flow
import React from 'react'
import styled from 'styled-components'

export const NotFound = () =>
  <NotFoundContainer>
    <NotFoundImage src="http://hrwiki.org/w/images/0/03/404.PNG" />
  </NotFoundContainer>

export default NotFound

const NotFoundContainer = styled.div`
  max-width: 100%;
  margin: 0 auto;
  text-align: center;
`

const NotFoundImage = styled.img`max-width: 100%;`
