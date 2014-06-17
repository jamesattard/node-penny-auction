Sails   = require('sails')
request = require('request')
mocks   = require('../utils/mocks')
i18n    = require('../utils/i18n')
utils   = require('../utils')


baseUrl     = 'http://localhost:1337'
registerUrl = "#{baseUrl}/api/auth/local/register"

app = null


before (done)->
  Sails.lift
    log:
      level: 'error'
  , (err, liftedSails)->
    console.log "Sails lifted with error", err if err
    app = liftedSails
    done(err, liftedSails)

after (done)->
#  User.destroy({like: {username: "%#{testingUsernamePattern}%"}}).exec (err)->


  app.lower ->
    console.log "SHHHH"
    done()


describe "AuthController", ->

  testingUsernamePattern = 'testing-user'

  beforeEach ->
    @regData =
      username: testingUsernamePattern
      email: 'user655@example.com'
      password: 'abcdefgh'
      confirm_password: 'abcdefgh'



  describe "allows to register a local passport. ", ->

    describe "It validates registration form data and ", ->

      it "should return error messages if no data presented",  (done)->
        request.post registerUrl, {form: {}}, (error, response, body)->
          expect(utils.jsonParseSafe(body)).to.be.equal(mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] ))
          done()

      it "should return error messages if all fields except email are presented",  (done)->
        delete @regData.email
        request.post registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()

      it "should return error messages if all fields except username are presented",  (done)->
        delete @regData.username
        request.post registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("username", [i18n.__('No username was entered')] )
          expect(utils.jsonParseSafe(body)).to.be.equal(errors)
          done()


      it "should return error messages if password is absent",  (done)->
        delete @regData.password
        request.post registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("password", [i18n.__('Please enter password')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()

      it "should return error messages if confirm_password is absent",  (done)->
        delete @regData.confirm_password
        request.post registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please confirm your password')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()


      it "should return error messages if password != confirm_password",  (done)->
        @regData.confirm_password = @regData.password + "-"
        request.post registerUrl, {form: @regData}, (error, response, body)->
          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please enter the same value')] )
          expect(utils.jsonParseSafe(body)).to.be.equal( errors )
          done()


      it "should create a new user when all form data is valid",  (done)->
        request.post registerUrl, {form: @regData}, (error, response, body)=>
          console.log body
          successMessage = {
            "data": {
              "email":    @regData.email,
              "username": @regData.username
            },
            "messages": [
              "Registration completed"
            ],
            "redirectTo": "#{baseUrl}/home"
          }

          expect(utils.jsonParseSafe(body)).to.be.equal(successMessage)
          done()

