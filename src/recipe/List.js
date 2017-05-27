// @flow
import React, { Component } from 'react';
import { gql, graphql } from 'react-apollo';
import styled from 'styled-components';

import type { RecipeListProps } from './types';

import { Recipe } from './Recipe';

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
      return <List>
        { recipes.map(recipe => <Recipe recipe={recipe} /> ) }
      </List>;
    }
    else {
      return <Error>Couldn't find recipies</Error>
    }
  }
}

const List = styled.div``;
const Loading = styled.div`
  width: 100%;
  font-size: 36px;
  font-family: sans-serif;
  text-align: center;
  padding: 20px 40px;
  border: 1px solid #224466;
  background-color: salmon;
`;

const Error = styled.div`
  padding: 20px 40px;
  border: 1px solid #224466;
  background-color: salmon;
`


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
