

declare module 'draft-js' {
  declare export class Editor extends React$Component<*> {
  }

  declare export class EditorState {
    getSelection: () => any;
    getCurrentInlineStyle: () => any;
    getCurrentContent: () => any;
    static createEmpty: () => any;
  }

  declare export class RichUtils {
    static toggleInlineStyle: (...any) => any;
    static toggleBlockType: (...any) => any;
    static onTab: (...any) => any;
    static handleKeyCommand: (...any) => any;
  }
}
