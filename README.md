ChoicEats
===============

Two terminals:

First, compile and start the server
```
cd CHOICEATS_SERVER_DIRECTORY && yarn build && yarn start
```

Second, start up the client
```
yarn start
```
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

### Custom configuration
Although this app uses create react app, the elm portion changes webpack configuration in node_modules\react-scripts\config\webpack.config.dev.js in the following ways

```
module.exports.resolve.extensions = ['.web.js', '.js', '.json', '.web.jsx', '.jsx', '.elm']
```

`module.exports.module.rules` has another array entry:
```
{
  test: /\.elm$/,
  exclude: [/elm-stuff/, /node_modules/],
  loader: require.resolve('elm-webpack-loader')
},
```

The `` entry that looks like this:

```
{
  // "oneOf" will traverse all following loaders until one will
  // match the requirements. When no loader matches it will fall
  // back to the "file" loader at the end of the loader list.
  oneOf: [
    // "url" loader works like "file" loader except that it embeds assets
    // smaller than specified limit in bytes as data URLs to avoid requests.
    // A missing "test" is equivalent to a match.
    {
      test: [/\.bmp$/, /\.gif$/, /\.jpe?g$/, /\.png$/, /\.elm$/],
      loader: require.resolve('url-loader'),
      options: {
        limit: 10000,
        name: 'static/media/[name].[hash:8].[ext]',
      },
    },
    ...
    ...
  ]
}
```

has the images entry test changed to [/\.bmp$/, /\.gif$/, /\.jpe?g$/, /\.png$/, /\.elm$/],

See these links for adding ELM into a React project:

* http://elm-lang.org/blog/how-to-use-elm-at-work
* https://codeburst.io/using-elm-in-react-from-the-ground-up-e3866bb0369d
* https://github.com/ceddlyburge/elm-in-react/blob/master/src/elm/Buttons.elm
* https://medium.com/javascript-inside/building-a-react-redux-elm-bridge-8f5b875a9b76

## Something Missing?
