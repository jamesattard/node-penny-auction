request = require('request')
async   =  require('async')
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

        errors = errorResponseMock.factory().addValidation( __("No user id") ).addValidation( __("Role name must not be empty") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if userId is absent [UCSR-0001]", ->
      delete @roleFormData.userId
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = errorResponseMock.factory().addValidation( __("No user id") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if userId is empty [UCSR-0002]", ->
      @roleFormData.userId = ''
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = errorResponseMock.factory().addValidation( __("No user id") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if  user is not found by userId [UCSR-0005]", ->
      @roleFormData.userId = '*-*-'
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = errorResponseMock.factory().addValidation( __("No user found") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()


    it "if user is not found by userId and the 'role' fields value doesn't contain valid role [UCSR-0003, UCSR-0005]", ->
      @roleFormData.userId  = '*-*-'
      @roleFormData.role    = 'invalid_role'
      request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
        expect(response.statusCode).to.be.equal(400)

        errors = errorResponseMock.factory().addValidation( __("Invalid role") ).addValidation( __("No user found") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it "if user has been found and the 'role' fields value doesn't contain valid role [UCSR-0003]", ->
      @roleFormData.role    = 'invalid_role'
      utils.auth.loginDefaultAdmin (err, adminUser)=>
        expect(err).to.be.equal(null)

        if err
          done()
        else
          @roleFormData.userId = adminUser.id
          request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
            expect(response.statusCode).to.be.equal(400)

            errors = errorResponseMock.factory().addValidation( __("Invalid role") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

            utils.logout (err, data)->
              expect(err).to.be.equal(null)
              done()


    it "if user has role [UCSR-0004]", ->
      @roleFormData.role    = 'invalid_role'
      utils.auth.loginDefaultAdmin (err, adminUser)=>
        expect(err).to.be.equal(null)

        if err
          done()
        else
          @roleFormData.userId  = adminUser.id
          @roleFormData.role    = 'admin'
          request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
            expect(response.statusCode).to.be.equal(400)

            errors = errorResponseMock.factory().addValidation( __("User already has this role") )
            expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

            utils.logout (err, data)->
              expect(err).to.be.equal(null)
              done()



  describe "returns 201 http status code with Responses::NormalizedJson", ->
    it "if all fields are valid [UCSR-0006]", ->
      usernamePattern = "set-role-test"
      password        = "12345678"
      utils.regUser usernamePattern, password, (err, user)=>
        expect(err).to.be.equal(null)
        if err
          done()
        else
          @roleFormData.userId  = user.id
          request.post @userSetRoleUrl, {form: @roleFormData}, (error, response, body)->
            expect(response.statusCode).to.be.equal(200)

            #clean up db
            User.destroy({like: {username: "%#{usernamePattern}%"}}).exec (err, deletedUsers)->
              async.each deletedUsers, (user, callback)->
                Passport.destroy({user: user.id}).exec ->
                  callback()
              , ->
                done()




