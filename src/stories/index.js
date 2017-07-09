// @flow
import React from 'react'
import { storiesOf } from '@storybook/react'

import IngredientTypeahead from '../pages/recipes/components/recipe-editor/ingredient-typeahead'

import 'semantic-ui-css/semantic.min.css'

// import { linkTo } from '@storybook/addon-links'

// import { Button, Welcome } from '@storybook/react/demo'

// storiesOf('Welcome', module).add('to Storybook', () => <Welcome showApp={linkTo('Button')} />)

// storiesOf('Button', module)
//   .add('with text', () => <Button onClick={action('clicked')}>Hello Button</Button>)
//   .add('with some emoji', () => <Button onClick={action('clicked')}>😀 😎 👍 💯</Button>)

const TEST_INGREDIENTS = [
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

storiesOf('Ingredient Selector', module)
  .add('Basic', () =>
    <IngredientTypeahead
      ingredients={TEST_INGREDIENTS} />
  )
  .add('Carrot Selected', () =>
    <IngredientTypeahead
      onSelect={(data) => console.log(data)}
      selectedIngredient={TEST_INGREDIENTS[2]}
      ingredients={TEST_INGREDIENTS} />
  )
