
declare module 'styled-components' {
  declare export function keyframes (any): string;
  
  declare export default {
    div: (strings: string[]) => ReactClass;
    img: (strings: string[]) => ReactClass;
    h1: any;
    p: (strings: string[]) => ReactClass;
  }
}
