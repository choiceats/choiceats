// @flow
import React, { Component } from 'react';
import styled from 'styled-components';

import type { Recipe as TRecipe } from './types';

type RecipeProps = {
  recipe: TRecipe
};

export const Recipe = ({recipe}: RecipeProps) => {
  return <Container>
    <Name>{ recipe.name }</Name>
    <Contents>
      <Ingredients>{ recipe.ingredients }</Ingredients>
      <Instructions>{ recipe.instructions }</Instructions>
    </Contents>
  </Container>
};

const Container = styled.div`
  width: 500px;
  margin: auto;
  margin-bottom: 10px;
  padding: 10px 15px;
  border: 1px solid red;
`;

const Name = styled.div`
  font-size: 36px;
  font-family: sans-serif;
`;

const Contents = styled.div``;
const Ingredients = styled.div`
  margin-top: 15px;
  font-family: monospace;
  white-space: pre-wrap;
`;

const Instructions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`;
