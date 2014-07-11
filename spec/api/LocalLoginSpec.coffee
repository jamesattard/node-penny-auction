async   =  require('async')
Sails   = require('sails')
request = require('request')
utils   = require('../utils')
{mocks, i18n} = utils



describe "AuthController", (done)->

  testingUsernamePattern = 'login-testing-user'

  # cleanup DB after tests
  after (done)->
    User.destroy({like: {username: "%#{testingUsernamePattern}%"}}).exec (err, deletedUsers)->
      async.each deletedUsers, (user, callback)->
        Passport.destroy({user: user.id}).exec ->
          callback()
      , ->
        done()


  beforeEach ->
    @registerUrl = "#{app.config.app.baseUrl}/api/auth/local/register"
    @loginUrl    = "#{app.config.app.baseUrl}/api/auth/local"

    password  = 'aAbFcde5647Hfgh'
    email     = 'user1545676-896@example.com'
    @regData =
      username: testingUsernamePattern
      email: email
      password: password
      confirm_password: password

    @loginData =
      identifier: email
      password: password



  describe "allows to login using a local passport. ", (done)->

    describe "It validates login form data and ", (done)->

      describe "according to [LPL-0001] shall return JSON with 'ValidationMessage' error ", ->

        it "if email and password are absent",  (done)->
          request.post @loginUrl, {form: {}}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("No email was entered") )
            .addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if email and password are empty",  (done)->
          @loginData.identifier = ''
          @loginData. password = ''
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            console.log response.statusCode, body
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("No email was entered") )
            .addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if email is empty but password is not",  (done)->
          @loginData.identifier = ''
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("No email was entered") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if email is absent but password is not",  (done)->
          delete @loginData.identifier
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("No email was entered") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if password is absent but email is not",  (done)->
          delete @loginData.password
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if password is empty but email is not",  (done)->
          @loginData.password = ''
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()


      describe "according to [LPL-0002] shall return JSON with 'ValidationMessage' error ", ->
        it "if email format  is incorrect (1)",  (done)->
          @loginData.identifier = "email@email"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if email format  is incorrect (2)",  (done)->
          @loginData.identifier = "email@email."
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if email format  is incorrect (3)",  (done)->
          @loginData.identifier = "email@.com"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'identifier', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()


      describe "according to [LPL-0003] shall return JSON with 'ValidationMessage' error ", ->
        it "if  password length is < 8",  (done)->
          @loginData.password = "1234567"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'password', i18n.__("Password's length must be 8 symbols minimum") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()


      describe "according to [LPL-0004] shall return JSON with 'ValidationMessage' error ", ->
        it  "if  both login and email are valid but user with given email and/or password doesn't exist in db",  (done)->
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addString( i18n.__("Incorrect email or password") )

            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

      describe "according to [LPL-0005] shall return 'NormalizedJson'", ->
        it "if  login and password are valid and user is exist in DB",  (done)->
          request.post @registerUrl, {form: @regData}, (error, response, body)=>

            expect(response.statusCode).to.be.equal(201)

            request.post @loginUrl, {form: @loginData}, (error, response, body)=>
              normalizedJsonResponse =
                data:
                  email:        @regData.email
                  username:     @regData.username
                messages: [i18n.__("You have been logged successfully, please wait") ]

              responseJson = utils.jsonParseSafe(body)
              expect(responseJson.messages).to.deep.equal(normalizedJsonResponse.messages)
              expect(responseJson.data.email).to.be.equal(normalizedJsonResponse.data.email)
              expect(responseJson.data.username).to.be.equal(normalizedJsonResponse.data.username)

              expect(responseJson.data.createdAt).to.not.empty
              expect(responseJson.data.updatedAt).to.not.empty
              expect(responseJson.data.id).to.not.empty

              done()