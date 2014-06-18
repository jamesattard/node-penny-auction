passport = require("passport")
path = require("path")
url = require("url")

###
Passport Service

A painless Passport.js service for your Sails app that is guaranteed to
Rock Your Socks™. It takes all the hassle out of setting up Passport.js by
encapsulating all the boring stuff in two functions:

passport.endpoint()
passport.callback()

The former sets up an endpoint (/auth/:provider) for redirecting a user to a
third-party provider for authentication, while the latter sets up a callback
endpoint (/auth/:provider/callback) for receiving the response from the
third-party provider. All you have to do is define in the configuration which
third-party providers you'd like to support. It's that easy!

Behind the scenes, the service stores all the data it needs within "Pass-
ports". These contain all the information required to associate a local user
with a profile from a third-party provider. This even holds true for the good
ol' password authentication scheme – the Authentication Service takes care of
encrypting passwords and storing them in Passports, allowing you to keep your
User model free of bloat.
###

# Load authentication protocols
passport.protocols = require("./protocols")

###
Connect a third-party profile to a local user

This is where most of the magic happens when a user is authenticating with a
third-party provider. What it does, is the following:

1. Given a provider and an identifier, find a mathcing Passport.
2. From here, the logic branches into two paths.

- A user is not currently logged in:
1. If a Passport wassn't found, create a new user as well as a new
Passport that will be assigned to the user.
2. If a Passport was found, get the user associated with the passport.

- A user is currently logged in:
1. If a Passport wasn't found, create a new Passport and associate it
with the already logged in user (ie. "Connect")
2. If a Passport was found, nothing needs to happen.

As you can see, this function handles both "authentication" and "authori-
zation" at the same time. This is due to the fact that we pass in
`passReqToCallback: true` when loading the strategies, allowing us to look
for an existing session in the request and taking action based on that.

For more information on auth(entication|rization) in Passport.js, check out:
http://passportjs.org/guide/authenticate/
http://passportjs.org/guide/authorize/

@param {Object}   req
@param {Object}   query
@param {Object}   profile
@param {Function} next
###
passport.connect = (req, query, profile, next) ->
  strategies = sails.config.passport
  config = strategies[profile.provider]
  user = {}

  # Set the authentication provider.
  query.provider = req.param("provider")

  # If the profile object contains a list of emails, grab the first one and
  # add it to the user.
  user.email = profile.emails[0].value  if profile.hasOwnProperty("emails")

  # If the profile object contains a username, add it to the user.
  user.username = profile.username  if profile.hasOwnProperty("username")

  # If neither an email or a username was available in the profile, we don't
  # have a way of identifying the user in the future. Throw an error and let
  # whoever's next in the line take care of it.
  return next(new Error("Neither a username or email was available", null))  unless Object.keys(user).length
  Passport.findOne
    provider: profile.provider
    identifier: query.identifier.toString()
  , (err, passport) ->
    return next(err)  if err
    unless req.user

      # Scenario: A new user is attempting to sign up using a third-party
      #           authentication provider.
      # Action:   Create a new user and assign them a passport.
      unless passport
        User.create user, (err, user) ->
          return next(err)  if err
          query.user = user.id
          Passport.create query, (err, passport) ->

            # If a passport wasn't created, bail out
            return next(err)  if err
            next err, user
            return

          return


        # Scenario: An existing user is trying to log in using an already
        #           connected passport.
        # Action:   Get the user associated with the passport.
      else

        # If the tokens have changed since the last session, update them
        passport.tokens = query.tokens  if query.hasOwnProperty("tokens") and query.tokens isnt passport.tokens

        # Save any updates to the Passport before moving on
        passport.save (err, passport) ->
          return next(err)  if err

          # Fetch the user associated with the Passport
          User.findOne passport.user, next
          return

    else

      # Scenario: A user is currently logged in and trying to connect a new
      #           passport.
      # Action:   Create and assign a new passport to the user.
      unless passport
        query.user = req.user.id
        Passport.create query, (err, passport) ->

          # If a passport wasn't created, bail out
          return next(err)  if err
          next err, req.user
          return


        # Scenario: The user is a nutjob or spammed the back-button.
        # Action:   Simply pass along the already established session.
      else
        next null, req.user
    return

  return


###
Create an authentication endpoint

For more information on authentication in Passport.js, check out:
http://passportjs.org/guide/authenticate/

@param  {Object} req
@param  {Object} res
###
passport.endpoint = (req, res) ->
  strategies = sails.config.passport
  provider = req.param("provider")
  options = {}

  # If a provider doesn't exist for this endpoint, send the user back to the
  # login page
  return res.redirect("/login")  unless strategies.hasOwnProperty(provider)

  # Attach scope if it has been set in the config
  options.scope = strategies[provider].scope  if strategies[provider].hasOwnProperty("scope")

  # Load authentication strategies
  @loadStrategies req

  # Redirect the user to the provider for authentication. When complete,
  # the provider will redirect the user back to the application at
  #     /auth/:provider/callback
  @authenticate(provider, options) req, res, req.next
  return


###
Create an authentication callback endpoint

For more information on authentication in Passport.js, check out:
http://passportjs.org/guide/authenticate/

@param {Object}   req
@param {Object}   res
@param {Function} next
###
passport.callback = (req, res, next) ->
  provider  = req.param("provider", "local")
  action    = req.param("action")

  # Passport.js wasn't really built for local user registration, but it's nice
  # having it tied into everything else.
  if provider is "local" and action isnt `undefined`
    if action is "register" and not req.user
      @protocols.local.register req, res, next
    else if action is "connect" and req.user
      @protocols.local.connect req, res, next
    else
      next new Error("Invalid action")
  else

    # Load authentication strategies
    @loadStrategies req

    if provider is "local" and action is `undefined`
      # check if identifier and password are not empty
      identifier  = req.param('identifier', '')
      password    = req.param('password', '')
      console.log "identifier", identifier, identifier is ''
      if identifier is ''
        return next new ValidationError "identifier", "No email was entered"

    # The provider will redirect the user to this URL after approval. Finish
    # the authentication process by attempting to obtain an access token. If
    # access was granted, the user will be logged in. Otherwise, authentication
    # has failed.
    @authenticate(provider, next) req, res, req.next
  return


###
Load all strategies defined in the Passport configuration

For example, we could add this to our config to use the GitHub strategy
with permission to access a users email address (even if it's marked as
private) as well as permission to add and update a user's Gists:

github: {
name: 'GitHub',
protocol: 'oauth2',
scope: [ 'user', 'gist' ]
options: {
clientID: 'CLIENT_ID',
clientSecret: 'CLIENT_SECRET'
}
}

For more information on the providers supported by Passport.js, check out:
http://passportjs.org/guide/providers/

@param {Object} req
###
passport.loadStrategies = (req) ->
  self = this
  strategies = sails.config.passport
  Object.keys(strategies).forEach (key) ->
    options = passReqToCallback: true
    Strategy = undefined
    if key is "local"

      # Since we need to allow users to login using both usernames as well as
      # emails, we'll set the username field to something more generic.
      _.extend options,
        usernameField: "identifier"


      # Only load the local strategy if it's enabled in the config
      if strategies.local
        Strategy = strategies[key].strategy
        self.use new Strategy(options, self.protocols.local.login)
    else
      protocol = strategies[key].protocol
      callback = strategies[key].callback
      callback = path.join("auth", key, "callback")  unless callback
      Strategy = strategies[key].strategy
      switch protocol
        when "oauth", "oauth2"
          options.callbackURL = url.resolve(req.baseUrl, callback)
        when "openid"
          options.returnURL = url.resolve(req.baseUrl, callback)
          options.realm = req.baseUrl
          options.profile = true

      # Merge the default options with any options defined in the config. All
      # defaults can be overriden, but I don't see a reason why you'd want to
      # do that.
      _.extend options, strategies[key].options
      self.use new Strategy(options, self.protocols[protocol])
    return

  return

passport.serializeUser (user, next) ->
  next null, user.id
  return

passport.deserializeUser (id, next) ->
  User.findOne id, next
  return

module.exports = passport