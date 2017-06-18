// @flow
export type ConnectedProps = {
  dispatch: (action: any) => void;
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
