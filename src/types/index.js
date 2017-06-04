export type WithRouterProps = {
  history: { push: (string) => void };
  match: { url: string };
}

export type ConnectedProps = {
  dispatch: (action: any) => void;
}

export type User = {
  id: string;
  token: string;
}

export type Recipe = {
  name: string;
  author: string;
  ingredients: string;
  instructions: boolean;
}
