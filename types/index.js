// @flow

import type { Dispatch } from 'redux'

export type ConnectedProps = {
  dispatch: Dispatch<*>;
}

export type User = {
  id: number;
  token: string;
}

export type Unit = {
  id: number;
  name: string;
  abbr: string;
}

export type Ingredient = {
  id: ?number;  // Null id means unsaved
  name: string;
  unit: ?Unit;
  quantity: number;
}

export type Recipe = {
  id: ?number;  // Null id means unsaved
  author: string;
  ingredients: Ingredient[];
  instructions: string;
  name: string;
}

export type Action = {
  type: ?string
}
