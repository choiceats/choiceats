module.exports = function(app) {
  app.get('/', sendBundle)
}

function sendBundle(err, req, res, next) {
  res.sendFile('index.html', {
    root: static_path
  })
  return null
}
