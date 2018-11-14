#ChoicEats
App for adding and sharing recipes.

## Getting Started
`yarn` installs all dependencies. Elm installs Elm dependencies on its own.

`./build.sh` creates a production bundle.

`./watcher.sh` runs dev mode (use `server.sh` to serve output files).

`./server.sh` serves static files for both production and development bundles.

`./reactor.sh` allows type debugging by file.
Browser requests install dependencies (when needed) and (re)compile code.
Any type errors will show after about one second.
Navigating to `localhost:8000/src/Main.elm` type checks the whole project.
`localhost:8000` exposes a file explorer for type checking single files.


Run the backend by cloning [choiceats-server](https://github.com/choiceats/choiceats-server) and running `cd choiceats-server && yarn && yarn build && yarn start`.


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
