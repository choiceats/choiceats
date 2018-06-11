const webpack = require('webpack');
const commonOptions = require('./webpack.config.common.js');

module.exports = {
    entry: {
        'elm-dev-bootstrap': [
            './src/assets/index-elm.js'
        ]
    },
    output: Object.assign(
        {},
        commonOptions.output,
        {filename: 'elm-dev-bootstrap.js'},
    ),
    module: commonOptions.module,

    mode: 'production',
    plugins: [
        new webpack.DefinePlugin({
            api_url: JSON.stringify("http://localhost:4000")
        })
    ]
}
