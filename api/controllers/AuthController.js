// Generated by CoffeeScript 1.7.1

/*
Authentication Controller

This is merely meant as an example of how your Authentication controller
should look. It currently includes the minimum amount of functionality for
the basics of Passport.js to work.
 */
var AuthController;

AuthController = {

  /*
  Render the login page
  
  The login form itself is just a simple HTML form:
  
  <form role="form" action="/auth/local" method="post">
  <input type="text" name="identifier" placeholder="Username or Email">
  <input type="password" name="password" placeholder="Password">
  <button type="submit">Sign in</button>
  </form>
  
  You could optionally add CSRF-protection as outlined in the documentation:
  http://sailsjs.org/#!documentation/config.csrf
  
  A simple example of automatically listing all available providers in a
  Handlebars template would look like this:
  
  {{#each providers}}
  <a href="/auth/{{slug}}" role="button">{{name}}</a>
  {{/each}}
  
  @param {Object} req
  @param {Object} res
   */
  login: function(req, res) {
    var providers, strategies;
    strategies = sails.config.passport;
    providers = {};
    Object.keys(strategies).forEach(function(key) {
      if (key === "local") {
        return;
      }
      providers[key] = {
        name: strategies[key].name,
        slug: key
      };
    });
    res.view({
      providers: providers,
      errors: req.flash("error")
    });
  },

  /*
  Log out a user and return them to the homepage
  
  Passport exposes a logout() function on req (also aliased as logOut()) that
  can be called from any route handler which needs to terminate a login
  session. Invoking logout() will remove the req.user property and clear the
  login session (if any).
  
  For more information on logging out users in Passport.js, check out:
  http://passportjs.org/guide/logout/
  
  @param {Object} req
  @param {Object} res
   */
  logout: function(req, res) {
    req.logout();
    res.redirect("/");
  },

  /*
  Render the registration page
  
  Just like the login form, the registration form is just simple HTML:
  
  <form role="form" action="/auth/local/register" method="post">
  <input type="text" name="username" placeholder="Username">
  <input type="text" name="email" placeholder="Email">
  <input type="password" name="password" placeholder="Password">
  <button type="submit">Sign up</button>
  </form>
  
  @param {Object} req
  @param {Object} res
   */
  register: function(req, res) {
    res.view({
      errors: req.flash("error")
    });
  },

  /*
  Create a third-party authentication endpoint
  
  @param {Object} req
  @param {Object} res
   */
  provider: function(req, res) {
    passport.endpoint(req, res);
  },

  /*
  Create a authentication callback endpoint
  
  This endpoint handles everything related to creating and verifying Pass-
  ports and users, both locally and from third-aprty providers.
  
  Passport exposes a login() function on req (also aliased as logIn()) that
  can be used to establish a login session. When the login operation
  completes, user will be assigned to req.user.
  
  For more information on logging in users in Passport.js, check out:
  http://passportjs.org/guide/login/
  
  @param {Object} req
  @param {Object} res
   */
  callback: function(req, res) {
    return passport.callback(req, res, function(err, user) {
      if (err) {
        return res.serverError(err);
      } else {
        return req.login(user, function(err) {
          if (err) {
            return res.serverError(err);
          } else {
            if (req.param("action") === "register") {
              return res.created(new Responses.prototype.NormalizedJson(user, "Registration completed"));
            } else {
              req.session.authenticated = true;
              req.session.userRoles = user.roles;
              return res.ok(new Responses.prototype.NormalizedJson(user, "You have been logged successfully, please wait"));
            }
          }
        });
      }
    });
  }
};

module.exports = AuthController;
