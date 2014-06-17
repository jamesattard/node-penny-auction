
request = require('request')
utils   = require('../utils')
{mocks, i18n} = utils


@registerUrl = null



describe "AuthController", (done)->

  # cleanup test results
  after (done)->
    User.destroy({like: {username: "%#{testingUsernamePattern}%"}}).exec (err)->

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

      it "should return error messages if no data presented",  (done)->
        request.post @registerUrl, {form: {}}, (error, response, body)->
          expect(utils.jsonParseSafe(body)).to.be.equal(mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] ))
          done()

      it "should return error messages if all fields except email are presented",  (done)->
        delete @regData.email
        request.post @registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()

      it "should return error messages if all fields except username are presented",  (done)->
        delete @regData.username
        request.post @registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("username", [i18n.__('No username was entered')] )
          expect(utils.jsonParseSafe(body)).to.be.equal(errors)
          done()


      it "should return error messages if password is absent",  (done)->
        delete @regData.password
        request.post @registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("password", [i18n.__('Please enter password')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()

      it "should return error messages if confirm_password is absent",  (done)->
        delete @regData.confirm_password
        request.post @registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please confirm your password')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()


      it "should return error messages if password != confirm_password",  (done)->
        @regData.confirm_password = @regData.password + "-"
        request.post @registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please enter the same value')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()


      it "should create a new user when all form data is valid",  (done)->
        request.post @registerUrl, {form: @regData}, (error, response, body)=>
          console.log body
          successMessage = {
            "data": {
              "email":    @regData.email,
              "username": @regData.username
            },
            "messages": [
              [i18n.__("Registration completed")]
            ],
            "redirectTo": "#{app.config.app.baseUrl}/home"
          }

          expect(utils.jsonParseSafe(body)).to.be.equal(successMessage)

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

