request = require('request').defaults({jar: true})
utils   = require('../utils/index')

exports.login  =  login = (identifier, password, done)->
  formData =
    identifier: identifier
    password: password
  request.post gEnvConfig.loginUrl, {form: formData}, (err, response, body)->
    console.log "body", body
    if err
      done err
    else
      if response.statusCode is 200
        done null, utils.jsonParseSafe(body).data
      else
        done utils.jsonParseSafe(body)

exports.loginDefaultAdmin  = (done)->
  login app.config.app.auth.defaultAdmin.identifier,  app.config.app.auth.defaultAdmin.password, done



exports.logout  = (done)->
  request.post gEnvConfig.logoutUrl, {}, (err, response, body)->
    done null, utils.jsonParseSafe(body)



exports.regUser = regUser  = (usernamePattern, password, done)->
  regData =
    username: usernamePattern
    email: usernamePattern + '@example.com'
    password: password
    confirm_password: password

  request.post gEnvConfig.registerUrl, {form: regData}, (err, response, body)->
    if err
      done err
    else
      if response.statusCode is 201
        done null, utils.jsonParseSafe(body).data
      else
        done "Invalid status code: #{response.statusCode }"

exports.regUserAndLogin  = (usernamePattern, password, done)->
  regUser usernamePattern, password, (err, user)->
    if err
      done err
    else
      console.log user.email, password
      login user.email, password, done






