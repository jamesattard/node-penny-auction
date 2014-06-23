request = require('request')
utils   = require('../utils/index')
{mocks, i18n} = utils
__ = i18n.__
errorResponseMock = mocks.api.errorResponse

describe "The UserController::set-role function", (done)->

  beforeEach ->
    @userSetRoleUrl = "#{app.config.app.baseUrl}/api/users/set-role"
    @roleFormData =
      userId: ''
      role: 'admin'

  describe "returns 400 http status code with ValidationError", ->
    it "if empty form is submitted [UCSR-0001, UCSR-0002]", ->
      request.post @userSetRoleUrl, {form: {}}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = mocks.api.errorResponse.factory().addValidation( __("No user id") ).addValidation( __("Role name must not be empty") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if userId is absent [UCSR-0001]", ->
      delete @roleFormData.userId
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = mocks.api.errorResponse.factory().addValidation( __("No user id") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if userId is empty [UCSR-0002]", ->
      @roleFormData.userId = ''
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = mocks.api.errorResponse.factory().addValidation( __("No user id") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    



