import React, { Component } from 'react'

export default class Elm extends Component {
  initialize(node) {
    if (node === null) return
    const app = this.props.src.embed.call(this, node, this.props.flags)

    if (typeof this.props.ports !== 'undefined') {
      this.props.ports.call(this, app.ports)
    }
  }

  componentDidMount() {
    this.initialize.call(this, this.mountNode)
  }

  shouldComponentUpdate(prevProps) {
    return false
  }

  render() {
    return <div ref={mountNode => (this.mountNode = mountNode)} />
  }
}
