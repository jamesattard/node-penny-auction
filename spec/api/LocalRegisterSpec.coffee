
request = require('request')
utils   = require('../utils')
{mocks, i18n} = utils


@registerUrl = null



describe "AuthController", (done)->

  # cleanup test results
  after (done)->
    User.destroy({like: {username: "%#{testingUsernamePattern}%"}}).exec (err, deletedUsers)->
      async.each deletedUsers, (user, callback)->
        Passport.destroy({user: user.id}).exec ->
          callback()
      , ->
        done()

  testingUsernamePattern = 'register-testing-user'

  beforeEach ->
    @registerUrl = "#{app.config.app.baseUrl}/api/auth/local/register"
    
    @regData =
      username: testingUsernamePattern
      email: 'user655@example.com'
      password: 'abcdefgh'
      confirm_password: 'abcdefgh'



  describe "allows to register a local passport. ", (done)->

    describe "It validates registration form data and ", (done)->

      describe "according to [LPR-0001] shall return JSON with 'ValidationMessage' error ", ->

        it "if no fields were sent with request ",  (done)->
          request.post @registerUrl, {form: {}}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("No email was entered") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if all fields except email were sent",  (done)->
          delete @regData.email
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("No email was entered") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()

        it "all fields are valid, but email is empty",  (done)->
          @regData.email = ''
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("No email was entered") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()



      describe "according to [LPR-0002] shall return JSON with 'ValidationMessage' error ", ->
        it "if email has incorrect format (1)",  (done)->
          @regData.email = 'email@email'
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("Please enter valid email") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get() )
            done()

        it "if email has incorrect format (2)",  (done)->
          @regData.email = 'email@email.'
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("Please enter valid email") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get() )
            done()

        it "if email has incorrect format (3)",  (done)->
          @regData.email = '@email.com'
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'email', i18n.__("Please enter valid email") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get() )
            done()

      describe "according to [LPR-0003] shall return JSON with 'ValidationMessage' error ", ->
        it "if username field is absent",  (done)->
          delete @regData.username
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'username', i18n.__("No username was entered") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()

        it "if username field is empty",  (done)->
          @regData.username = ''
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'username', i18n.__("No username was entered") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
            done()



      describe "according to [LPR-0004] shall return JSON with 'ValidationMessage' error ", ->
        it "if password field is absent",  (done)->
          delete @regData.password
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'password', i18n.__("Please enter password") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()

        it "if password field is empty",  (done)->
          @regData.password = ''
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'password', i18n.__("Please enter password") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()



      describe "according to [LPR-0005] shall return JSON with 'ValidationMessage' error ", ->
        it "if confirm_password field is absent",  (done)->
          delete @regData.confirm_password
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'confirm_password', i18n.__("Please confirm your password") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()

        it "if confirm_password field is empty",  (done)->
          @regData.confirm_password = ''
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'confirm_password', i18n.__("Please confirm your password") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()



      describe "according to [LPR-0006] shall return JSON with 'ValidationMessage' error ", ->
        it "if confirm_password  field differs from the password field",  (done)->
          @regData.confirm_password = @regData.password + "-"
          request.post @registerUrl, {form: @regData}, (error, response, body)->
            errors = mocks.api.errorResponse.factory().addValidation( 'confirm_password', i18n.__("Please enter the same value") )
            expect(utils.jsonParseSafe(body)).to.deep.equal( errors.get() )
            done()


      describe "according to [LPR-0007] shall return  'NormalizedJson'  and create user ", ->
        it "if all fields are correct",  (done)->
          request.post @registerUrl, {form: @regData}, (error, response, body)=>
            normalizedJsonResponse = {
              "data": {
                "email":    @regData.email,
                "username": @regData.username
              }
              "messages": [
                i18n.__("Registration completed")
              ]
            }

            #check API's response
            responseJson = utils.jsonParseSafe(body)
            expect(responseJson.messages).to.deep.equal(normalizedJsonResponse.messages)
            expect(responseJson.data.email).to.be.equal(normalizedJsonResponse.data.email)
            expect(responseJson.data.username).to.be.equal(normalizedJsonResponse.data.username)

            expect(responseJson.data.createdAt).to.not.empty
            expect(responseJson.data.updatedAt).to.not.empty
            expect(responseJson.data.id).to.not.empty

            #check that user actually exists in DB
            try
              User.findOne({username: @regData.username, email: @regData.email}).exec (err, user)=>
                expect(err).to.be.equal(null)
                expect(user).to.not.equal(null)
                expect(user.username).to.be.equal(@regData.username)
                expect(user.email).to.be.equal(@regData.email)
            catch e
              done()
              throw e

            done()

