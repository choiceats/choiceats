/* global MouseEvent, KeyboardEvent */
// @flow
import React, { Component } from 'react'
import { Editor, EditorState, RichUtils } from 'draft-js'
import styled from 'styled-components'

import 'draft-js/dist/Draft.css'
import './rich-editor.css'

type RichEditorState = {
  editorState: EditorState
}

export default class RichEditor extends Component {
  focus: () => void
  handleKeyCommand: (command: string) => string
  onTab: (event: KeyboardEvent) => void
  toggleBlockType: (type: string) => void
  toggleInlineStyle: (type: string) => void
  onChange: (state: EditorState) => void

  state: RichEditorState

  constructor (props: {}) {
    super(props)
    this.state = {
      editorState: EditorState.createEmpty()
    }

    this.focus = () => this.refs.editor.focus()
    this.onChange = (editorState) => this.setState(() => ({editorState}))

    this.handleKeyCommand = (command) => this._handleKeyCommand(command)
    this.onTab = (e) => this._onTab(e)
    this.toggleBlockType = (type) => this._toggleBlockType(type)
    this.toggleInlineStyle = (style) => this._toggleInlineStyle(style)
  }

  _handleKeyCommand (command: string) {
    const newState = RichUtils.handleKeyCommand(this.state.editorState, command)
    if (newState) {
      this.onChange(newState)
      return 'handled'
    }
    return 'not-handled'
  }

  _onTab (e: KeyboardEvent) {
    const maxDepth = 4
    this.onChange(RichUtils.onTab(e, this.state.editorState, maxDepth))
  }

  _toggleBlockType (blockType: string) {
    this.onChange(
      RichUtils.toggleBlockType(
        this.state.editorState,
        blockType
      )
    )
  }

  _toggleInlineStyle (inlineStyle: string) {
    this.onChange(
      RichUtils.toggleInlineStyle(
        this.state.editorState,
        inlineStyle
      )
    )
  }

  render () {
    const { editorState } = this.state
    return (
      <EditorContainer className='RichEditor-root'>
        <BlockStyleControls
          editorState={editorState}
          onToggle={this.toggleBlockType}
              />
        <InlineStyleControls
          editorState={editorState}
          onToggle={this.toggleInlineStyle}
              />
        <div className='RichEditor-editor'>
          <Editor
            editorState={editorState}
            onChange={this.onChange}
            handleKeyCommand={this.handleKeyCommand}
          />
        </div>
      </EditorContainer>
    )
  }
}

class StyleButton extends React.Component {
  onToggle: (e: MouseEvent) => void

  constructor () {
    super()
    this.onToggle = (e) => {
      e.preventDefault()
      this.props.onToggle(this.props.style)
    }
  }

  render () {
    let className = 'RichEditor-styleButton'
    if (this.props.active) {
      className += ' RichEditor-activeButton'
    }
    return (
      <span className={className} onMouseDown={this.onToggle}>
        {this.props.label}
      </span>
    )
  }
}

const BLOCK_TYPES = [
  {label: 'H1', style: 'header-one'},
  {label: 'H2', style: 'header-two'},
  {label: 'H3', style: 'header-three'},
  {label: 'Blockquote', style: 'blockquote'},
  {label: 'UL', style: 'unordered-list-item'},
  {label: 'OL', style: 'ordered-list-item'},
  {label: 'Code Block', style: 'code-block'}
]

const BlockStyleControls = (props) => {
  const {editorState} = props
  const selection = editorState.getSelection()
  const blockType = editorState
          .getCurrentContent()
          .getBlockForKey(selection.getStartKey())
          .getType()
  return (
    <div className='RichEditor-controls'>
      {BLOCK_TYPES.map((type) =>
        <StyleButton
          key={type.label}
          active={type.style === blockType}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
              />
            )}
    </div>
  )
}

var INLINE_STYLES = [
  {label: 'Bold', style: 'BOLD'},
  {label: 'Italic', style: 'ITALIC'},
  {label: 'Underline', style: 'UNDERLINE'},
  {label: 'Monospace', style: 'CODE'}
]

const InlineStyleControls = (props) => {
  var currentStyle = props.editorState.getCurrentInlineStyle()
  return (
    <div className='RichEditor-controls'>
      {INLINE_STYLES.map(type =>
        <StyleButton
          key={type.label}
          active={currentStyle.has(type.style)}
          label={type.label}
          onToggle={props.onToggle}
          style={type.style}
              />
            )}
    </div>
  )
}

const EditorContainer = styled.div`
  height: 400px;
  width: 100%;
  max-width: 550px;
  border: 1px solid gray;
`
