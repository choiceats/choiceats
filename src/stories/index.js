// @flow
import React from 'react'
import { storiesOf } from '@storybook/react'

import IngredientTypeahead from '../pages/recipes/components/recipe-editor/ingredient-typeahead'
import 'semantic-ui-css/semantic.min.css'

import { INGREDIENTS } from './fixtures'

storiesOf('Ingredient Selector', module)
  .add('Basic', () => <IngredientTypeahead ingredients={INGREDIENTS} />)
  .add('Carrot Selected', () =>
    <IngredientTypeahead
      onSelect={data => console.log(data)}
      selectedIngredient={INGREDIENTS[2]}
      ingredients={INGREDIENTS}
    />
  )
