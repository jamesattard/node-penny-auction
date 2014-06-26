request = require('request')
utils   = require('../utils/index')

exports.loginDefaultAdmin  = (done)->
  formData = app.config.app.auth.defaultAdmin
  request.post gEnvConfig.loginUrl, {auth: formData}, (err, response, body)=>
    if err
      done err
    else
      if response.statusCode is 200
        done null, utils.jsonParseSafe(body).data
      else
        done utils.jsonParseSafe(body)



exports.logout  = (done)->
  request.post gEnvConfig.logoutUrl, {}, (err, response, body)=>
    done null, utils.jsonParseSafe(body)



exports.regUser  = (usernamePattern, password, done)->
  regData =
    username: usernamePattern
    email: usernamePattern + '@example.com'
    password: password
    confirm_password: password

  request.post gEnvConfig.registerUrl, {form: regData}, (err, response, body)=>
    if err
      done err
    else
      if response.statusCode is 201
        done null, utils.jsonParseSafe(body).data
      else
        done utils.jsonParseSafe(body)