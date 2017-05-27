import React, { Component } from 'react';
import { ApolloProvider } from 'react-apollo';

import { client } from './services/apollo-client';
import { ConnectedRecipes } from './recipe/List';


class App extends Component {
  render() {
    return (
      <ApolloProvider client={client}>
        <ConnectedRecipes />
      </ApolloProvider>
    );
  }
}

export default App;
