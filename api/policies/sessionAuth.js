// Generated by CoffeeScript 1.7.1

/*
sessionAuth

@module      :: Policy
@description :: Simple policy to allow any authenticated user
Assumes that your login action in one of your controllers sets `req.session.authenticated = true;`
@docs        :: http://sailsjs.org/#!documentation/policies
 */
module.exports = function(req, res, next) {
  console.log("req.session.authenticated", req.session);
  if (req.session.authenticated) {
    return next();
  }
  return res.forbidden("You are not permitted to perform this action.");
};
