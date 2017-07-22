import React from 'react'
import { Loader } from 'semantic-ui-react'

const Loading = () =>
  <Loader
    active
    inline="centered"
    size="massive"
    style={{ paddingBottom: '6px' }}
  >
    Loading
  </Loader>

export default Loading
