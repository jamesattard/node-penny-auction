validator = require("validator")

###
Local Authentication Protocol

The most widely used way for websites to authenticate users is via a username
and/or email as well as a password. This module provides functions both for
registering entirely new users, assigning passwords to already registered
users and validating login requesting.

For more information on local authentication in Passport.js, check out:
http://passportjs.org/guide/username-password/
###

###
Register a new user

This method creates a new user from a specified email, username and password
and assign the newly created user a local Passport.

@param {Object}   req
@param {Object}   res
@param {Function} next
###
exports.register = (req, res, next) ->
  email = req.param("email")
  username = req.param("username")
  password = req.param("password")
  confirmPassword = req.param("confirm_password")

  unless email
    return next new ValidationError("email", "No email was entered")

  if not validator.isEmail(email)
    return next new ValidationError "email", "Please enter valid email"

  unless username
    return next(new ValidationError("username", "No username was entered"))
  unless password
    return next new ValidationError "password", "Please enter password"
  unless confirmPassword
    return next new ValidationError "confirm_password", "Please confirm your password"
  if password isnt confirmPassword
    return next new ValidationError "confirm_password", "Please enter the same value"


  User.create
    username: username
    email: email
  , (err, user) ->
    if err
      return next "Error.Passport.User.Exists"
    Passport.create
      protocol: "local"
      password: password
      user: user.id
    , (err, passport) ->
      next err, user
      return

    return

  return


###
Assign local Passport to user

This function can be used to assign a local Passport to a user who doens't
have one already. This would be the case if the user registered using a
third-party service and therefore never set a password.

@param {Object}   req
@param {Object}   res
@param {Function} next
###
exports.connect = (req, res, next) ->
  user = req.user
  password = req.param("password")
  Passport.findOne
    protocol: "local"
    user: user.id
  , (err, passport) ->
    return next(err)  if err
    unless passport
      Passport.create
        protocol: "local"
        password: password
        user: user.id
      , (err, passport) ->
        next err, user
        return

    else
      next null, user
    return

  return


###
Validate a login request

Looks up a user using the supplied identifier (email or username) and then
attempts to find a local Passport associated with the user. If a Passport is
found, its password is checked against the password supplied in the form.

@param {Object}   req
@param {string}   identifier
@param {string}   password
@param {Function} next
###
exports.login = (req, identifier, password, next) ->
  isEmail = validator.isEmail(identifier)
  query = {}
  if isEmail
    query.email = identifier
  else
    query.username = identifier
  console.log "query", query
  User.findOne query, (err, user) ->
    return next(err)  if err
    unless user
#      if isEmail
#        error = "Error.Passport.Email.NotFound"
#      else
#        error = "Error.Passport.Username.NotFound"
      return next("Incorrect email or password")
    Passport.findOne
      protocol: "local"
      user: user.id
    , (err, passport) ->
      if passport
        passport.validatePassword password, (err, res) ->
          return next(err)  if err
          unless res
            next "Error.Passport.Password.Wrong"
          else
            next null, user

      else
        next "Error.Passport.Password.NotSet"
