// @flow
import React from 'react'
import styled, { keyframes } from 'styled-components'
import { Link } from 'react-router-dom'
import { Button, Card, Modal, Icon, Loader } from 'semantic-ui-react'
import {
  selectRecipeToDelete,
  setRecipeStatus,
  setRecipeLikeStatus
} from '../../state/action-creators'
import {
  UPDATE,
  DELETE,
  PENDING,
  SUCCESS,
  FAIL
} from '../../state/action-types'

import IngredientList from './components/ingredient-list'

import { gql } from 'react-apollo'
import type { RecipeProps } from './prop-types.flow'

//TODO: Remove the id from all searches, not just empty search of searchFilter "all"
//The problem is that it gets loaded separately for all the searches.
//Or perhaps better yet, have all searchText and searchFilter write to the same data store instead of creating duplicate stores
const recipesQuery = gql`
  query RecipeQuery($searchText: String, $searchFilter: String) {
    recipes(searchText: "", searchFilter: "all") {
      id
      author
      authorId
      description
      imageUrl
      name
      likes
      youLike
    }
  }
`

const readSingleRecipeFromCache = id => gql`
  query RecipeById($recipeId: Int!) {
    recipe(recipeId: "${id}") {
      id
      author
      authorId
      description
      imageUrl
      name
      instructions
      ingredients {
        name
        unit {
          name
          abbr
        }
        quantity
      }
      likes
      youLike
    }
  }
`

type OtherProps = {
  selectedRecipeId: string,
  isChangingLike: boolean,
  isDeletingRecipe: boolean,
  deleteRecipeError: boolean,
  recipeIdToDelete: string,
  userId?: string,
  youLike?: boolean
}

type HigherOrderProps = {
  dispatch: any,
  goToRecipeList: () => void,
  likeRecipe: (arg: {}) => any,
  deleteRecipe: (arg: {
    variables: { recipeId: null | string | number }
  }) => any
}

export const RecipeDetail: (
  RecipeProps & OtherProps & HigherOrderProps
) => React.Element<*> = ({
  goToRecipeList,
  dispatch,
  recipe,
  selectedRecipeId,
  recipeIdToDelete,
  isChangingLike = false,
  isDeletingRecipe,
  deleteRecipeError,
  likeRecipe,
  deleteRecipe,
  userId = 0
}) =>
  <RecipeCard style={{ paddingBottom: '3px' }}>
    <Card fluid>
      <Card.Content>
        <Card.Header>
          {recipe.name}
        </Card.Header>
        <Card.Meta>
          {recipe.author}
        </Card.Meta>
        <Card.Description>
          {recipe.id && <Link to={`/recipe/${recipe.id}/edit`}>Edit</Link>}
          <Description>
            {recipe.description}
          </Description>
          <IngredientList ingredients={recipe.ingredients || []} />
          <Directions>
            {recipe.instructions}
          </Directions>
        </Card.Description>
        <Card.Description
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center'
          }}
        >
          <span>
            <Icon
              name="favorite"
              size="big"
              loading={isChangingLike}
              color={recipe.youLike ? 'teal' : 'grey'}
              onClick={() => {
                dispatch(
                  setRecipeLikeStatus({
                    id: recipe.id,
                    operation: UPDATE,
                    status: PENDING
                  })
                )
                likeRecipe({
                  variables: {
                    recipeId: recipe.id,
                    userId
                  }
                })
                  .then(({ data }) => {
                    dispatch(
                      setRecipeLikeStatus({
                        id: recipe.id,
                        operation: UPDATE,
                        status: SUCCESS
                      })
                    )
                  })
                  .catch(error => {
                    console.log('there was an error sending the query', error)
                    dispatch(
                      setRecipeLikeStatus({
                        id: recipe.id,
                        operation: UPDATE,
                        status: FAIL
                      })
                    )
                  })
              }}
            />
            {!!recipe.likes &&
              <span>
                Likes: {recipe.likes} {recipe.youLike && '(including you)'}
              </span>}
            {!recipe.likes && <span>Be the first to like this</span>}
          </span>
          {userId !== recipe.authorId &&
            (!isDeletingRecipe
              ? <Button
                  negative
                  onClick={() => {
                    dispatch(selectRecipeToDelete(recipe.id || null))
                  }}
                >
                  Delete
                </Button>
              : <Loader inline active size="tiny">
                  Deleting
                </Loader>)}
        </Card.Description>
        {deleteRecipeError &&
          <DeleteError>Unable to delete recipe.</DeleteError>}
      </Card.Content>
      <Modal
        open={recipeIdToDelete && recipeIdToDelete === recipe.id}
        onClose={() => dispatch(selectRecipeToDelete(null))}
        actions={[
          <Button
            key={'no'}
            onClick={() => dispatch(selectRecipeToDelete(null))}
          >
            No
          </Button>,
          <Button
            key={'yes'}
            onClick={() => {
              dispatch(selectRecipeToDelete(null))
              dispatch(
                setRecipeStatus({
                  id: recipe.id,
                  operation: DELETE,
                  status: PENDING
                })
              )
              deleteRecipe({
                variables: {
                  recipeId: recipe.id || null
                },
                update: (
                  store,
                  { data: { deleteRecipe: { deleted, recipeId, __typename } } }
                ) => {
                  //data is the only element within the second arg
                  if (deleted) {
                    const listCache = store.readQuery({ query: recipesQuery })
                    const recipeIndexToDelete = listCache.recipes.findIndex(
                      recipe => recipe.id === recipeId
                    )

                    listCache.recipes.splice(recipeIndexToDelete, 1)

                    store.writeQuery({
                      query: recipesQuery,
                      data: { recipes: listCache.recipes }
                    })
                    store.writeQuery({
                      query: readSingleRecipeFromCache(recipe.id),
                      data: { recipe: null }
                    })
                  }

                  //https://github.com/apollographql/apollo-client/issues/621
                }
              })
                .then(data => {
                  const recipeWasDeleted =
                    data &&
                    data.data &&
                    data.data.deleteRecipe &&
                    data.data.deleteRecipe.deleted === true

                  if (recipeWasDeleted) {
                    dispatch(
                      setRecipeStatus({
                        id: recipe.id,
                        operation: DELETE,
                        status: SUCCESS
                      })
                    )
                    goToRecipeList()
                  } else {
                    dispatch(
                      setRecipeStatus({
                        id: recipe.id,
                        operation: DELETE,
                        status: FAIL
                      })
                    )
                  }
                })
                .catch(error => {
                  dispatch(
                    setRecipeStatus({
                      id: recipe.id,
                      operation: DELETE,
                      status: FAIL
                    })
                  )
                  console.log('something went wrong:', error)
                })
            }}
          >
            Yes
          </Button>
        ]}
        header={`Do you really want to delete ${recipe.name}?`}
      />
    </Card>
  </RecipeCard>

const slideIn = keyframes`
  from {
    margin-left: 100%;
  }

  to {
    margin-left: 0%;
  }
`

const RecipeCard = styled.div`animation: ${slideIn} .25s linear;`

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

const Directions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`

const DeleteError = styled.div`color: red;`

export default RecipeDetail
