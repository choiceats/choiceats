// flow-typed signature: 25a346523de87fbad8b783ce81a366b3
// flow-typed version: <<STUB>>/material-ui_v^0.18.1/flow_v0.47.0

/**
 * This is an autogenerated libdef stub for:
 *
 *   'material-ui'
 *
 * Fill this stub out by replacing all the `any` types.
 *
 * Once filled out, we encourage you to share your work with the
 * community by sending a pull request to:
 * https://github.com/flowtype/flow-typed
 */

declare module 'material-ui' {
  declare module.exports: any;
}

declare module 'material-ui/AppBar' {
  declare export default class AppBar extends React$Component {
    props: {
      title: string;
      iconElementRight: React$Element;
    }
  }
}

declare module 'material-ui/Card' {
  declare class AppBar extends React$Component {
    props: { }
  }
}

declare module 'material-ui/TextField' {
  declare export default class TextField extends React$Component {
    props: {
      hintText: string;
      floatingLabelText: string;
      type: string;
    }
  }
}

declare module 'material-ui/styles/MuiThemeProvider' {
  declare export default class MuiThemeProvider extends React$Component {

  }
}

declare module 'material-ui/RaisedButton' {
  declare export default class RaisedButton extends React$Component {

  }
}

declare module 'material-ui/FlatButton' {
  declare export default class FlatButton extends React$Component {
    props: {
      label: string;
    }
  }
}
