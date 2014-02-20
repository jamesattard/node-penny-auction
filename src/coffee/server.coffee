###
Module dependencies.
###
#global._ = require "underscore"

# Core
{CoreController, RrsCore} = require './core'
global.RrsCore = RrsCore

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
  key: 'express.sid'
  cookie:
    maxAge: 12 * 1000 * 60 * 60 * 10

app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

srv = http.createServer(app)
io  = require('socket.io').listen(srv)

# https://github.com/creationix/howtonode.org/blob/master/articles/socket-io-auth/server.js
cookie = require("cookie")
connect = require("connect")
io.set "authorization", (handshakeData, accept) ->

  # check if there's a cookie header
  if handshakeData.headers.cookie

    # if there is, parse the cookie
    handshakeData.cookie = cookie.parse(handshakeData.headers.cookie)

    # the cookie value should be signed using the secret configured above (see line 17).
    # use the secret to to decrypt the actual session id.
    sessionJsonCookie = connect.utils.parseSignedCookie(handshakeData.cookie["express.sid"], 'cssa21csacs-*562312scas+-csa32ca2c3sa')
    handshakeData.session = connect.utils.parseJSONCookie(sessionJsonCookie)

    # if the session id matches the original value of the cookie, this means that
    # we failed to decrypt the value, and therefore it is a fake.

    # reject the handshake
    return accept("Cookie is invalid.", false)  if handshakeData.cookie["express.sid"] is sessionJsonCookie
  else

    # if there isn't, turn down the connection with a message
    # and leave the function.
    return accept("No cookie transmitted.", false)

  # accept the incoming connection
  accept null, true
  return


CoreController.setStatic 'srv', srv

srv.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

#include routes configuration file
routes = require("./application/routes.js")(app)
require("./application/listeners")(io)



try

catch e
  #send user-level exceptions to browser
  if typeof e is 'ExceptionUserMessage'
    Helper.json.setSuccess false
    Helper.json.addMessage(e.getName(), e.getMessage())
  else
    console.log e