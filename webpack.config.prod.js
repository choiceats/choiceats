const path = require('path');
const HtmlWebPackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const commonOptions = require('./webpack.config.common.js');

module.exports = {
    entry: commonOptions.entry,
    output: commonOptions.output,
    module: commonOptions.module,

    mode: 'production',
    plugins: [
        ...commonOptions.plugins,
        new webpack.DefinePlugin({
            api_url: JSON.stringify("http://choiceats.com")
        })
    ]
}

