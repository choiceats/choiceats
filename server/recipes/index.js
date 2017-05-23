module.exports = function(app) {
  app.get('/recipes', loadRecipes)
  app.post('/recipes', /*isLoggedIn,*/ createRecipe )
  app.put('/recipes/:id', /*isLoggedIn,*/ updateRecipe )
  app.delete('/recipes/:id', /*isLoggedIn,*/ deleteRecipe)
}

function loadRecipes(req, res, next) {

  res.send('loadRecipes not impemented yet\n')
  return null
}

function createRecipe(req, res, next) {
  const { body={} } = req
  const { author, name, ingredients, instructions } = body
  const newRecipe = {
    author,
    name,
    ingredients,
    instructions
  }
  const expectedFields = [
    'author',
    'name',
    'ingredients',
    'instructions'
  ]

  const missingFieldsTemplate = 'Unable to add recipe, these fields are missing:'
  const missingFieldsError = checkFieldsMissing(newRecipe, expectedFields, missingFieldsTemplate)
  if (missingFieldsError) {
    res.send(missingFieldsError)
    return null
  }

  res.send('createRecipe not implemented yet\n')
  return null

}

function updateRecipe(req, res, next) {
  const { body = {}, params = {} } = req
  const {id} = params
  const {
    name,
    ingredients,
    instructions,
    author
  } = body
  const requestLogTemplate = `
User tried to update recipe of id ${id} with
name: ${name},
ingredients: ${ingredients},
instructions: ${instructions},
author: ${author}
`

  console.log(requestLogTemplate)

  res.send('updateRecipe not route handler not implemented yet\n')

  return null
}


function deleteRecipe(err, req, res, next) {
  const { params = {} } = req
  const {id} = params

  res.send('deleteRecipe to be implemented\n')
  return null

}


function checkFieldsMissing(requestObject, expectedFields, errorTemplate) {
  const missingFields = Object.keys(requestObject).filter(fieldName => !requestObject[fieldName])
  if ( missingFields.length ) {
    return missingFields.reduce((accumulator, field) => accumulator + ' ' + field, errorTemplate) + '\n'
  }
  else {
    return null
  }
}
