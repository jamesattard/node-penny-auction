Sails   = require('sails')
request = require('request')
utils   = require('../utils')
{mocks, i18n} = utils



describe "AuthController", (done)->

  testingUsernamePattern = 'login-testing-user'

  # cleanup DB after tests
  after (done)->
    User.destroy({like: {username: "%#{testingUsernamePattern}%"}}).exec (err)->


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
      email: email
      password: password



  describe "allows to login using a local passport. ", (done)->

    describe "It validates login form data and ", (done)->

      describe "according to [LPL-0001] shall return JSON with 'ValidationMessage' error ", ->

        it "if email and password are empty",  (done)->
          request.post @loginUrl, {form: {}}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'email', i18n.__("No email was entered") )
            .addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()

        it "if email is empty but password is not",  (done)->
          delete @loginData.email
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'email', i18n.__("No email was entered") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()

        it "if password is empty but email is not",  (done)->
          delete @loginData.password
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Please enter password") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()


      describe "according to [LPL-0002] shall return JSON with 'ValidationMessage' error ", ->
        it "if email format  is incorrect (1)",  (done)->
          @loginData.email = "email@email"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()

        it "if email format  is incorrect (2)",  (done)->
          @loginData.email = "email@email."
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()

        it "if email format  is incorrect (3)",  (done)->
          @loginData.email = "email@.com"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Please enter valid email") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()


      describe "according to [LPL-0003] shall return JSON with 'ValidationMessage' error ", ->
        it "if  password length is < 8",  (done)->
          @loginData.password = "1234567"
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Password's length must be 8 symbols minimum") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()


      describe "according to [LPL-0004] shall return JSON with 'ValidationMessage' error ", ->
        it "if  both login and email are valid but user with given email and/or password doesn't exist in db",  (done)->
          request.post @loginUrl, {form: @loginData}, (error, response, body)->
            errors = mocks.api.errorResponse.addValidation( 'password', i18n.__("Incorrect email or password") )

            expect(utils.jsonParseSafe(body)).to.be.equal(errors.get())
            done()

      describe "according to [LPL-0005] shall return 'NormalizedJson'", ->
        it "if  login and password are valid and user is exist in DB",  (done)->
          request.post @registerUrl, {form: @regData}, (error, response, body)=>

            expect(response.statusCode).to.be.equal(200)

            request.post @loginUrl, {form: @loginData}, (error, response, body)=>
              normalizedJsonResponse =
                data:
                  username: @loginData.username
                  email:    @loginData.email
                messages: [i18n.__("You have been logged successfully, please wait") ]

              expect(utils.jsonParseSafe(body)).to.be.equal(normalizedJsonResponse)
              done()