###
isAdmin

@module      :: Policy
@description :: Simple policy to allow admin authenticated user
Assumes that your login action in one of your controllers sets `req.session.authenticated = true;`
@docs        :: http://sailsjs.org/#!documentation/policies
###
module.exports = (req, res, next) ->

  # User is allowed, proceed to the next policy,
  # or if this is the last policy, the controller
  return next()  if req.user.isAdmin

  # User is not allowed
  # (default res.forbidden() behavior can be overridden in `config/403.js`)
  res.unauthorized "You are not authorized to perform this request"