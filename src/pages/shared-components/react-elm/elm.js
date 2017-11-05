import React, { Component } from 'react'

export default class Elm extends Component {
  initialize(node) {
    if (node === null) return
    const app = this.props.src.embed.bind(this)(node, this.props.flags)

    if (typeof this.props.ports !== 'undefined') {
      this.props.ports.bind(this)(app.ports)
    }
  }

  shouldComponentUpdate(prevProps) {
    return false
  }

  render() {
    return React.createElement('div', { ref: this.initialize.bind(this) })
  }
}
