/* eslint-env jest */
// @flow
import React from 'react'
import { shallow } from 'enzyme'
import { Form } from 'semantic-ui-react'

import RecipeEditor from '../recipe-editor/recipe-editor'
// import { DEFAULT_INGREDIENT } from '../../../../defaults'

import type { Recipe } from 'types'

describe('Recipe: Recipe Editor::', () => {
  let fakeRecipe: Recipe
  let ingredients: any[]
  let units: any[]
  let defaultProps

  beforeEach(() => {
    fakeRecipe = {
      id: null,
      imageUrl: '',
      author: 'Some dude',
      name: 'Cool Recipe',
      instructions: '1. Mix well',
      ingredients: [],
      description: '',
      tags: []
    }

    ingredients = []
    units = []

    defaultProps = {
      recipe: fakeRecipe,
      ingredients,
      units,
      onSave: () => {},
      isSavingRecipe: false,
      recipeSaveError: false
    }
  })

  it('should render a from to fill out', () => {
    const wrapper = shallow(<RecipeEditor {...defaultProps} />)
    expect(wrapper.find(Form).length).toBe(1)
  })

  it("should not render an ingredient editor if we don't have any ingredients", () => {
    const wrapper = shallow(<RecipeEditor {...defaultProps} />)
    const ingredientComponent = wrapper.find('IngredientEditor')
    expect(ingredientComponent.length).toBe(0)
  })
})
