request = require('request').defaults({jar: true})
utils   = require('../utils/index')
{mocks, i18n} = utils
__ = i18n.__
errorResponseMock = mocks.api.errorResponse

describe "[ACP-0001] POST request to auction controller", (done)->

  beforeEach ->
    @_auctionForm =
      title: 'auction title'
      description: "description"
      startPrice: 123
      retailerPrice: 345
      startsAt: new Date
      expiresAt: new Date
      images: ['1.jpg', '2.jpg']

  describe "returns 401 status code and StringError ", (done)->
    it "if user is not logged in", ->
      request.post gEnvConfig.auctionPostUrl, {form: @_auctionForm}, (error, response, body)->
        expect(response.statusCode).to.be.equal(401)

        errors = errorResponseMock.factory().addString( __("You are not authorized to perform this request") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it.only "if user is logged in but doesn't have admin privileges", (done)->
      identifier = "auction-post-user"
      utils.auth.regUserAndLogin identifier, "12345678", (err, user)=>
        expect(err).to.be.equal(null)
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          console.log "body", body
          expect(response.statusCode).to.be.equal(401)

          errors = errorResponseMock.factory().addString( __("You are not authorized to perform this request") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

