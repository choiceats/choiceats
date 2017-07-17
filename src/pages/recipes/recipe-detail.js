// @flow
import React from 'react';
import styled, { keyframes } from 'styled-components';
import { Link } from 'react-router-dom';
import { Button, Card, Modal, Icon } from 'semantic-ui-react';
import { selectRecipeToDelete } from '../../state/action-creators';

import IngredientList from './components/ingredient-list';

import type { RecipeProps } from './prop-types.flow';

type OtherProps = {
  selectedRecipeId: string,
  recipeIdToDelete: string,
  userId?: number,
  youLike?: boolean
};

type HigherOrderProps = {
  dispatch: any,
  goToRecipeList: () => void,
  likeRecipe: (arg: {}) => any,
  deleteRecipe: (arg: {
    variables: { recipeId: null | string | number }
  }) => any
};

export const RecipeDetail: (
  RecipeProps & OtherProps & HigherOrderProps
) => React.Element<*> = ({
  goToRecipeList,
  dispatch,
  recipe,
  selectedRecipeId,
  recipeIdToDelete,
  likeRecipe,
  deleteRecipe,
  youLike = false,
  userId = 0
}) =>
  <RecipeCard>
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
          style={{ display: 'flex', alignItems: 'space-around' }}
        >
          <Icon
            name="smile"
            size="big"
            color={youLike ? 'green' : 'black'}
            onClick={() => {
              likeRecipe({
                variables: {
                  recipeId: recipe.id,
                  userId
                }
              })
                .then(({ data }) => {
                  console.log('got data', data);
                })
                .catch(error => {
                  console.log('there was an error sending the query', error);
                });
            }}
          />
          {!!recipe.likes &&
            <span>
              Likes: {recipe.likes} {recipe.youLike && '(including you)'}
            </span>}
          {!recipe.likes && <span>Be the first to like this</span>}
          {userId !== recipe.authorId &&
            <Button
              negative
              onClick={() => {
                dispatch(selectRecipeToDelete(recipe.id || null));
              }}
            >
              Delete
            </Button>}
        </Card.Description>
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
              deleteRecipe({
                variables: {
                  recipeId: recipe.id || null
                }
              })
                .then(data => {
                  const recipeWasDeleted =
                    data &&
                    data.data &&
                    data.data.deleteRecipe &&
                    data.data.deleteRecipe.deleted === true;
                  if (recipeWasDeleted) {
                    goToRecipeList();
                  }
                })
                .catch(error => {
                  console.log('something went wrong:', error);
                });
              dispatch(selectRecipeToDelete(null));
            }}
          >
            Yes
          </Button>
        ]}
        header={`Do you really want to delete ${recipe.name}?`}
      />
    </Card>
  </RecipeCard>;

const slideIn = keyframes`
  from {
    margin-left: 100%;
  }

  to {
    margin-left: 0%;
  }
`;

const RecipeCard = styled.div`animation: ${slideIn} .25s linear;`;

const Description = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`;

const Directions = styled.div`
  margin-top: 15px;
  white-space: pre-wrap;
`;

export default RecipeDetail;
