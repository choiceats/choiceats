
declare module 'styled-components' {
  declare module.exports: {
    div: (strings: string[]) => ReactClass;
    h1: any;
    p: (strings: string[]) => ReactClass;
  }
}
