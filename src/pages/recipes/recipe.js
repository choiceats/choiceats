// @flow
import React from 'react'
import { connect } from 'react-redux'

import RecipeSimple from './recipe-simple'
import RecipeDetail from './recipe-detail'

import type { ConnectedProps, AppState } from 'types'
import type { RecipeProps } from './prop-types.flow'

type MappedProps = {
  selectedRecipeId: number
}

export const Recipe
  : (RecipeProps & ConnectedProps & MappedProps) => React.Element<*> =
    ({
      recipe,
      isLoggedIn,
      allowEdits,
      likes = 0,
      youLike,
      selectedRecipeId,
      dispatch,
      userId
    }) => {
      return selectedRecipeId === recipe.id
        ? <RecipeDetail recipe={recipe} userId={userId} />
        : <RecipeSimple recipe={recipe} userId={userId} />
    }

const mapStateToProps
  : (AppState) => MappedProps =
    (state) => {
      return {
        selectedRecipeId: state.ui.selectedRecipeId
      }
    }

export default connect(mapStateToProps)(Recipe)
