import * as React from 'react';
import { ApolloClient, createNetworkInterface, ApolloProvider, gql, graphql } from 'react-apollo';

import './App.css';

const client = new ApolloClient({
  networkInterface: createNetworkInterface({
    uri: 'http://localhost:4000/graphql'
  })
});

const recipeQuery = gql`
  query RecipeQuery {
    recipes {
      author
      ingredients
      instructions
      name
    }
  }
`;

interface Recipe {
  author: String,
  ingredients: String,
  instructions: String,
  name: String
}

interface RecipesProps {
  data?: {
    loading: string,
    error: string,
    recipes: Recipe[]
  }
}

const Recipes = ({data}: RecipesProps): JSX.Element => {
  if (!data) return <div></div>;

  const { recipes, loading } = data;
  if (loading) {
    return <div>loading</div>;
  }
  
  if (recipes) {
    return (
      <ul>
        { recipes.map(recipe => <li><strong>{ recipe.name }</strong><br />{recipe.ingredients} </li>) }
      </ul>
    );
  }
  else {
    return <div>Couldn't find recipies</div>
  }
}

const ConnectedRecipes = graphql(recipeQuery)(Recipes);



class App extends React.Component<{}, null> {
  render() {
    return (
      <ApolloProvider client={client}>
        <ConnectedRecipes />
      </ApolloProvider>
    );
  }
}

export default App;
