// @flow
import { ApolloClient, createNetworkInterface } from 'react-apollo'
import * as user from './users'
import endpoints from './endpoints'

const authenicationMiddleware = {
  applyMiddleware (req, next) {
    if (!req.options.headers) {
      req.options.headers = {}
    }

    const userInfo = user.getUser()
    if (userInfo) {
      const token = userInfo.token
      if (token !== null) {
        req.options.headers.authorization = `Bearer ${token}`
      }
    }

    next()
  }
}

const networkInterface = createNetworkInterface({
  uri: `${endpoints.protocol}://${endpoints.url}:${endpoints.port}/graphql`
})

networkInterface.use([authenicationMiddleware])

const client = new ApolloClient({
  networkInterface
})

export { client }
