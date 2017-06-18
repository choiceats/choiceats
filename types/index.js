// @flow

import type { Dispatch } from 'redux'

export type ConnectedProps = {
  dispatch: Dispatch<*>;
}

export type User = {
  id: string;
  token: string;
}

export type Ingredient = {
  name: string;
}

export type Recipe = {
  id: ?string;
  author: string;
  ingredients: Ingredient[];
  instructions: string;
  name: string;
}

export type Action = {
  type: ?string
}
