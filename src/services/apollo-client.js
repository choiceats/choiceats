// @flow
import { ApolloClient, createNetworkInterface } from 'react-apollo'
import * as user from './users'

const authenicationMiddleware = {
  applyMiddleware(req, next) {
    if (!req.options.headers) {
      req.options.headers = {}
    }
    req.options.headers.authorization = `Bearer ${user.getToken()}`
    next();
  }
};

const networkInterface = createNetworkInterface({
  uri: 'http://localhost:4000/graphql'
})

networkInterface.use([authenicationMiddleware]);

const client = new ApolloClient({
  networkInterface
})

export { client }
