// @flow
import React from 'react'
import ReactDOM from 'react-dom'
import App from './app'
import registerServiceWorker from './registerServiceWorker'
import injectTapEventPlugin from 'react-tap-event-plugin'

import 'semantic-ui-css/semantic.min.css'

injectTapEventPlugin()

ReactDOM.render(
  <App />,
  document.getElementById('root')
)

registerServiceWorker()
