import React from 'react'
import { Typeahead } from 'react-typeahead'

export default ({ingredients, selectedIngredient, onSelect}) => {
  return <Typeahead
    options={ingredients}
    value={selectedIngredient.name}
    displayOption='name'
    searchOptions={(inputValue, options) =>
      options.filter(o => o.name.toLowerCase().indexOf(inputValue.toLowerCase()) > -1)
    }
    onOptionSelected={ingredient => onSelect(ingredient)}
    maxVisible={4} />
}
