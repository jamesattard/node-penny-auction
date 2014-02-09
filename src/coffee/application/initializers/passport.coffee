class exports.Initializer
  constructor: (app)->
    #import modules
    passport      = require('passport')
    LocalStrategy = require('passport-local').Strategy
    FacebookStrategy = require('passport-facebook').Strategy
    app.set 'passport', passport
    app.set 'localStrategy', LocalStrategy

    #passport.js' middlware
    app.use passport.initialize()
    app.use passport.session()

    # Passport's local strategy
    passport.use new LocalStrategy
      usernameField: 'email'
      passwordField: 'password'
    ,(username, password, done)->
      console.log '===============!!!!!!', username, password
      Model.instanceOf('user').login username, password, (user)->
        console.log 'user', user
        if user
          done null, true, user
        else
          done null, false, 'Incorrect login or password'


    passport.use new FacebookStrategy
      clientID: '429222097114916'
      clientSecret: '33be7ce13ab45683ea7ccb54eda7c644'
      callbackURL: "http://localhost:3000/api/user/facebook-callback"
    ,(accessToken, refreshToken, profile, done)->
      console.log "************ passport.use new FacebookStrategy", accessToken, refreshToken, profile, done
      user = null
      done(null, profile);



    passport.serializeUser (user, done)->
      console.log '/////////////// passport.serializeUser', user
      done(null, user);

    passport.deserializeUser (obj, done) ->
      console.log '\\\\\\\\\\\\\\\\\\\\ passport.deserializeUser', id
#      Model.instanceOf('user').getById
      done(null, obj)
#      User.findById id, (err, user)->
#        done(err, user)