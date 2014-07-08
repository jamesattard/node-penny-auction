request = require('request').defaults({jar: true})
utils   = require('../utils/index')
{mocks, i18n} = utils
__ = i18n.__
errorResponseMock = mocks.api.errorResponse

describe "POST request to auction controller", (done)->

  identifier = "auction-post-user"

  beforeEach ->
    @_auctionForm =
      title: 'auction title'
      description: "description"
      startPrice: 123
      retailerPrice: 345
      startsAt: new Date
      expiresAt: new Date
      images: ['1.jpg', '2.jpg']

  afterEach: (done)->
    utils.auth.logout ->
      User.destroy({username: identifier}).exec done

  describe "[ACP-0001] returns 401 status code and StringError ", (done)->
    it "if user is not logged in", ->
      request.post gEnvConfig.auctionPostUrl, {form: @_auctionForm}, (error, response, body)->
        expect(response.statusCode).to.be.equal(401)

        errors = errorResponseMock.factory().addString( __("You are not authorized to perform this request") )
        expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

        done()

    it.only "if user is logged in but doesn't have admin privileges", (done)->

      utils.auth.regUserAndLogin identifier, "12345678", (err, user)=>
        expect(err).to.be.equal(null)
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          console.log "body", body
          expect(response.statusCode).to.be.equal(401)

          errors = errorResponseMock.factory().addString( __("You are not authorized to perform this request") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

  describe "[ACP-0002, ACP-0003] returns 400 status code and ValidationError", (done)->




