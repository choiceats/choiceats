// @flow
import React, { Component } from 'react';
import { gql, graphql } from 'react-apollo';
import type { RecipeListProps } from './types';


class RecipeList extends Component {
  props: RecipeListProps;

  render () {
    const { data } = this.props;
    if (!data) return <div></div>;

    const { recipes, loading } = data;
    if (loading) {
      return <div>loading</div>;
    }

    if (recipes) {
      return (
        <ul>
          {recipes.map(recipe => <li><strong>{recipe.name}</strong><br />{recipe.ingredients}</li>) }
        </ul>
      );
    }
    else {
      return <div>Couldn't find recipies</div>
    }
  }
}

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


const ConnectedRecipes = graphql(recipeQuery)(RecipeList);
export { ConnectedRecipes };
