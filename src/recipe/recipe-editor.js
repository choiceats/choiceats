import React from 'react'
import {Editor, EditorState, RichUtils} from 'draft-js'
import styled from 'styled-components'
import './recipe-editor.css'

export class RecipeEditor extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      recipeName: EditorState.createEmpty(),
      recipeIngredients: EditorState.createEmpty(),
      recipeInstructions: EditorState.createEmpty()
    }
    this.onChange = (key, value) => this.setState(() => ({[key]: value}))
  }

  handleKeyCommand (command) {
    const newState = RichUtils.handleKeyCommand(this.state.recipeName, command)
    if (newState) {
      this.onChange(newState)
      return 'handled'
    }
    return 'not-handled'
  }

  _onBoldClick () {
    this.onChange(RichUtils.toggleInlineStyle(this.state.recipeName, 'BOLD'))
  }

  render () {
    return (
      <EditorContainer>
        <EditorTitle>Recipe Editor</EditorTitle>
        <button onClick={this._onBoldClick.bind(this)}>Bold</button>
        <EditorLabel>Recipe Name</EditorLabel>
        <Editor
          editorState={this.state.recipeName}
          onChange={(val) => this.onChange('recipeName', val)}
          handleKeyCommand={this.handleKeyCommand}
        />
        <EditorLabel>Ingredients</EditorLabel>
        <Editor
          editorState={this.state.recipeIngredients}
          onChange={(val) => this.onChange('recipeIngredients', val)}
          handleKeyCommand={this.handleKeyCommand}
        />
        <EditorLabel>Instructions</EditorLabel>
        <Editor
          editorState={this.state.recipeInstructions}
          onChange={(val) => this.onChange('recipeInstructions', val)}
          handleKeyCommand={this.handleKeyCommand}
        />
      </EditorContainer>
    )
  }
}

const EditorContainer = styled.div`
  height: 400px;
  width: 100%;
  max-width: 550px;
  border: 1px solid gray;
`

const EditorLabel = styled.label`
  font-weight: bold;
`

const EditorTitle = styled.div`
  border-bottom: 1px solid gray;
`
