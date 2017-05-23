const express = require('express')
const path = require('path')
const compress = require('compression')
const bodyParser = require('body-parser') 
const cookieParser = require('cookie-parser')
const config = require('./config');

const app = express()

const static_path = path.join(__dirname, '../build')
app.use(express.static(static_path))
app.use(cookieParser())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.use(compress())

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization, Access-Control-Allow-Credentials");
  res.header("Access-Control-Allow-Credentials", "true");
  next();
});

app.listen(config.port, function (err) {
  if (err) {console.log(err) }
  console.log(`Listening at localhost:${config.port}`)
})

//Order matters for route matching
require('./home/index')(app)
require('./recipes/index')(app)
