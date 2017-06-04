export type WithRouter = {
  history: { push: (string) => void };
  match: { url: string };
}

export type Connected = {
  dispatch: (action: any) => void;
}
