Sails   = require('sails')
request = require('request')
mocks   = require('../utils/mocks')
i18n    = require('../utils/i18n')

baseUrl     = 'http://localhost:1337'
registerUrl = "#{baseUrl}/api/auth/local/register"

describe "AuthController", ->
  sails = null
  beforeEach (done)->

    # Lift Sails and start the server
    Sails.lift
        log:
          level: 'error'
    , (err, liftedSails)->
      sails = liftedSails
      done(err, liftedSails)

  afterEach (done)->
    Sails.lower(done)

  describe "allows to register a local passport. ", ->

    describe "It validates registration form data and ", ->
      beforeEach ->
        @regData =
          username: 'user655'
          email: 'user655@example.com'
          password: 'abcdefgh'
          confirm_password: 'abcdefgh'

      it "should return error messages if no data presented",  (done)->
        request.post registerUrl, {form: {}}, (error, response, body)->
          expect(JSON.parse(body)).toEqual(mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] ))
          done()

#      it "should return error messages if all fields except email are presented",  (done)->
#        delete @regData.email
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          errors = mocks.makeValidationErrorsResponse("email", [i18n.__("No email was entered")] )
#          expect(JSON.parse(body)).toEqual( errors )
#          done()
#
#      it "should return error messages if all fields except username are presented",  (done)->
#        delete @regData.username
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          errors = mocks.makeValidationErrorsResponse("username", [i18n.__('No username was entered')] )
#          expect(JSON.parse(body)).toEqual(errors)
#          done()
#
#
#      it "should return error messages if password is absent",  (done)->
#        delete @regData.password
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          errors = mocks.makeValidationErrorsResponse("password", [i18n.__('Please enter password')] )
#          expect(JSON.parse(body)).toEqual( errors )
#          done()
#
#      it "should return error messages if confirm_password is absent",  (done)->
#        delete @regData.confirm_password
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please confirm your password')] )
#          expect(JSON.parse(body)).toEqual( errors )
#          done()
#
#
#      it "should return error messages if password != confirm_password",  (done)->
#        @regData.confirm_password = @regData.password + "-"
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          errors = mocks.makeValidationErrorsResponse("confirm_password", [i18n.__('Please enter the same value')] )
#          expect(JSON.parse(body)).toEqual( errors )
#          done()
#
#
#      it "should create a new user when all form data is valid",  (done)->
#        request.post registerUrl, {form: @regData}, (error, response, body)->
#          console.log body
#          successMessage = {
#            "data": {
#              "email":    @regData.email,
#              "username": @regData.username
#            },
#            "messages": [
#              "Registration completed"
#            ],
#            "redirectTo": "#{baseUrl}/home"
#          }
#
#          expect(JSON.parse(body)).toEqual(successMessage)
#          done()


