// @flow
import React, { Component } from 'react'
import styled from 'styled-components'
import { Link } from 'react-router-dom'
import { Card } from 'semantic-ui-react'

import type { RecipeProps } from './prop-types.flow'

export default class Recipe extends Component {
  props: RecipeProps

  render () {
    const { recipe } = this.props
    if (!recipe.id) {
      return null
    }

    return (
      <Link to={{pathname: `/recipe/${recipe.id}`}}>
        <Card fluid style={{marginBottom: 15}}>
          <Card.Content>
            <Card.Header>
              {recipe.name}
            </Card.Header>
            <Card.Meta>{recipe.author}</Card.Meta>
            <Card.Description>
              <Description>{ recipe.description }</Description>
            </Card.Description>
          </Card.Content>
        </Card>
      </Link>
    )
  }
}

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

// =======
// export const Recipe
//  : (RecipeProps & ConnectedProps & MappedProps) => React.Element<*> =
//    ({
//      recipe,
//      isLoggedIn,
//      allowEdits,
//      likes = 0,
//      youLike,
//      selectedRecipeId,
//      recipeIdToDelete,
//      dispatch,
//      userId
//    }) => {
//      return selectedRecipeId === recipe.id
//        ? <RecipeDetail recipe={recipe} userId={userId} recipeIdToDelete={recipeIdToDelete} dispatch={dispatch}/>
//        : <RecipeSimple recipe={recipe} userId={userId} />
//    }
//
// const mapStateToProps
//  : (AppState) => MappedProps =
//    (state) => {
//      return {
//        selectedRecipeId: state.ui.selectedRecipeId,
//        recipeIdToDelete: state.ui.recipeIdToDelete
//      }
//    }
// >>>>>>> Stashed changes
