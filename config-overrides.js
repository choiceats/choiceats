const rewireRelay = require('react-app-rewire-relay')

module.exports = function override (config, env) {
  config = rewireRelay(config, env)
  return config
}
