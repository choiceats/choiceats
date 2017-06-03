declare module 'react-test-renderer' {
  declare type RendererResult = {
    toJSON(): ReactTestRendererJSON;
    unmount(nextElement?: ReactElement<any>): void;
  }

  declare type ReactTestRendererJSON = {
    type: string;
    props: { [propName: string]: string };
    children: null | Array<string | ReactTestRendererJSON>;
  }

  declare type TestRendererOptions = {
      createNodeMock(element: ReactElement<any>): any;
  }
 
  declare type createObj = {
    create: (React$Element) => RendererResult
  }

  declare export default createObj;
}