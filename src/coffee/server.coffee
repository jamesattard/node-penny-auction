###
Module dependencies.
###
#global._ = require "underscore"

# Core
{CoreController} = require './core'

# Express-genereted requires
express = require("express")
http    = require("http")
path    = require("path")
app     = express()
engine  = require('ejs-locals')

global.configs = require('./application/configs')(app)

CoreController.setStatic 'app', app
CoreController.setStatic 'appRoot', __dirname

#NODE_ENV=production node server.js
console.log "ENV: ", app.get("env")

initializers = require('./application/initializers')(app)

# all environments
app.set "port", process.env.PORT or configs.config.appPort
app.set "views", path.join(__dirname, "application/views")
app.engine('ejs', engine)
app.set "view engine", "ejs"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.cookieSession
  secret: 'cssa21csacs-*562312scas+-csa32ca2c3sa'
  cookie:
    maxAge: 12 * 1000 * 60 * 60 * 10

# sets 'is user authendicated' flag
#app.use (req, res, next)->
##  console.log req.session.user
#  Helper.json.setIsUserAuthed( req.session.user? )
#  next()

app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

srv = http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

CoreController.setStatic 'srv', srv

#include routes configuration file
routes = require("./application/routes.js")(app)

try

catch e
  #send user-level exceptions to browser
  if typeof e is 'ExceptionUserMessage'
    Helper.json.setSuccess false
    Helper.json.addMessage(e.getName(), e.getMessage())
  else
    console.log e