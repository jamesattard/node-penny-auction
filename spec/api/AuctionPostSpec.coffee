request = require('request')
utils   = require('../utils/index')
{mocks, i18n} = utils
__ = i18n.__
errorResponseMock = mocks.api.errorResponse

describe "[ACP-0001] POST request to auction controller", (done)->

  beforeEach ->

  describe "returns 401 status code and StringError ", ->
    it "if user is not logged in", ->
      request.post @auctionPostUrl, {form: {}}, (error, response, body)->
        expect(response.statusCode).to.be.equal(401)

        errors = mocks.api.errorResponse.factory().addString( __("You are not authorized to perform this request") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

#    it "if user is logged in but doesnt have admin priveleges", ->
#      request.post @auctionPostUrl, {form: {}}, (error, response, body)->
#        expect(response.statusCode).to.be.equal(401)
#
#        errors = mocks.api.errorResponse.factory().addString( __("You are not authorized to perform this request") )
#        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())
#
#        done()