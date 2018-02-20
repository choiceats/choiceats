ChoicEats
===============

This app is in transition from React to Elm. Both rely on the same backend. to start the backend, clone the backend project from [github](https://github.com/choiceats/choiceats-server). Then run `cd CHOICEATS_SERVER_DIRECTORY && yarn build && yarn start`.

To start the React version of the client, run `yarn start`

To start the Elm version of the client, navigate to the project root and run `elm-live --output=elm.js src/Main.elm --pushstate --open --debug`. Note that you will need `elm` and `elm-live` installed (run `npm install -g elm elm-live`).


## Minimum Viable Product
TODO
* Edit recipes
  * Must pick existing units.
  * Must pick existing ingredients.
  * Instructions - Basic text for now. Rich text later.

DONE
* Display recipes
* Authentication
* Delete recipes
* Filter recipes by likes (youlike and then overall)
* Server side converter to display fractions instead of decimals

## Backlog
* Dictionary of plural/single ingredients on server side (i.e. eggs);

### Missing Ingredients
* Ground pork

### Ingredients to fix
* apple slices. large apples, sliced
* unitless ingredients may need to display quantity sometimes but not other times. e.g. ketchup would not show quantity, but eggs would

## Something Missing?
