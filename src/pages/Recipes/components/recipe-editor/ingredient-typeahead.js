import React, { Component } from 'react'
import { Typeahead } from 'react-typeahead'

export default class IngredientTypeahead extends Component {
  constructor() {
    super()
    this.state = {}
  }

  // TODO: This is a recommended hack to get around a bug not
  // updating the value.
  // https://github.com/fmoo/react-typeahead/issues/214#issuecomment-245218554
  componentWillReceiveProps(nextProps) {
    const { selectedIngredient } = this.props
    if (selectedIngredient !== nextProps.selectedIngredient) {
      console.log('changed')
      this.typeahead.setState({ entryValue: nextProps.selectedIngredient.name })
    }
  }

  render() {
    const { ingredients, selectedIngredient, onSelect } = this.props

    return (
      <Typeahead
        ref={ref => {
          this.typeahead = ref
        }}
        options={ingredients}
        value={selectedIngredient ? selectedIngredient.name : ''}
        displayOption="name"
        searchOptions={(inputValue, options) =>
          options.filter(
            o => o.name.toLowerCase().indexOf(inputValue.toLowerCase()) > -1
          )
        }
        onOptionSelected={ingredient => onSelect(ingredient)}
        maxVisible={6}
      />
    )
  }
}
