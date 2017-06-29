// @flow
import React from 'react'
import { storiesOf } from '@storybook/react'

import RecipeIngredientsEditor from '../pages/recipes/components/recipe-editor/recipe-ingredients-editor'

import 'semantic-ui-css/semantic.min.css'
// import { action } from '@storybook/addon-actions'
// import { linkTo } from '@storybook/addon-links'

// import { Button, Welcome } from '@storybook/react/demo'

// storiesOf('Welcome', module).add('to Storybook', () => <Welcome showApp={linkTo('Button')} />)

// storiesOf('Button', module)
//   .add('with text', () => <Button onClick={action('clicked')}>Hello Button</Button>)
//   .add('with some emoji', () => <Button onClick={action('clicked')}>😀 😎 👍 💯</Button>)

const TEST_INGREDIENT = [
  {
    id: 1,
    name: 'Apples'
  }, {
    id: 2,
    name: 'Corn Beef'
  }, {
    id: 3,
    name: 'Carrot'
  }, {
    id: 4,
    name: 'Orange'
  }, {
    id: 5,
    name: 'Zest'
  }, {
    id: 6,
    name: 'Crisco'
  }
]

const TEST_UNITS = [
  {
    id: 1,
    name: 'Teaspoon',
    abbr: 'tsp.'
  }, {
    id: 2,
    name: 'Gallon',
    abbr: 'g.'
  }, {
    id: 3,
    name: 'Cups',
    abbr: 'C.'
  }, {
    id: 4,
    name: 'Liter',
    abbr: 'L.'
  }
]

storiesOf('IngredientEditor', module)
  .add('basic', () =>
    <RecipeIngredientsEditor
      units={TEST_UNITS}
      ingredients={TEST_INGREDIENT} />
  )
