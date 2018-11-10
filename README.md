#ChoicEats
App for adding and sharing recipes.

## Getting Started
This repo is an Elm project. You can install `elm 0.19` with `npm install -g elm` if `npm` is installed.

To run the reactor for type debugging, run `elm reactor` and open a browser tab to `localhost:8000/src/Main.elm`. The request takes care of installing needed dependencies and compiling. Reloading the tab recompiles the file. If the file is the app, the app will show. If not, it will appear to hang without any type errors if there are no type errors.

To build a production version of the project, change to the root repo of the directory and run `./copy-changes.sh && ./build.sh`. This presupposes a UNIX like shell. Production frontend code can be run with any static file server, for example the python3 simple http server: `python3 -m http.server`

To start the backend, clone the [choiceats-server](https://github.com/choiceats/choiceats-server) repo. Then run `cd <CHOICEATS_SERVER_DIRECTORY> && yarn build && yarn start`.


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
* Apply tagging system to existing recipes
* Email recipes to friend, including link to the site, print version of the recipe, and a brief message of who it was sent by.
* Highlight place where you are in recipe with a tap/click. Slight background color.

### Missing Ingredients
* Ground pork

### Ingredients to fix
* apple slices. large apples, sliced
* unitless ingredients may need to display quantity sometimes but not other times. e.g. ketchup would not show quantity, but eggs would

## Something Missing?
