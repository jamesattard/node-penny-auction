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

    it "if user is logged in but doesn't have admin privileges", (done)->

      utils.auth.regUserAndLogin identifier, "12345678", (err, user)=>
        expect(err).to.be.equal(null)
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          console.log "body", body
          expect(response.statusCode).to.be.equal(401)

          errors = errorResponseMock.factory().addString( __("You are not authorized to perform this request") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

  describe "[ACP-0002, ACP-0003] returns 400(\"Bad Request\") status code and ValidationError", (done)->
    it  "if title is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.title
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "title", __("Please enter title") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if title is empty", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.title = ""
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "title", __("Please enter title") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if title's lenght is > 100", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.title = ""
        for i in [0..100]
          @_auctionForm.title += "+"
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "title", __("Max lenght of titile is 100 symbols") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if description is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.description
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "description", __("Please enter description") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()


    it "if startPrice is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.startPrice
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "startPrice", [__("Please enter start price"),
                                                                             __("Start price must be numeric")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if startPrice is not numeric", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.startPrice = "as"
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "startPrice",  __("Start price must be numeric") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if startPrice is not numeric", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.startPrice = -1
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "startPrice",  __("Start price must be more than 0.01") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()




    it  "if retailerPrice is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.retailerPrice
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "retailerPrice", [__("Please enter retailer price"),
                                                                             __("Retailer price must be numeric")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it  "if retailerPrice is not numeric", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.retailerPrice = "as"
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "retailerPrice",  __("Retailer price must be numeric") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if retailerPrice is not numeric", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.retailerPrice = -1
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "retailerPrice",  __("Retailer price must be more than 0.01") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()




    it  "if startsAt is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.startsAt
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "startsAt", [__("Please select when auction starts"),
                                                                                __("Auction start must be datetime")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if startsAt is not datetime", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.startsAt = "a3ss"
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "startsAt",  __("Auction start must be datetime") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()



    it  "if expiresAt is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.expiresAt
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "expiresAt", [__("Please select when auction expires"),
                                                                           __("Auction expiration time must be datetime")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if expiresAt is not datetime", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.expiresAt = "a3ss6s"
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "expiresAt",  __("Auction expiration time must be datetime") )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()



    it  "if images is absent", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        delete @_auctionForm.images
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "images",  [__( "Please upload images"),
                                                                          __( "Incorrect format of images list"),
                                                                          __( "You must upload 1 image at least")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()

    it "if images array contains 7 items", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.images = ['1.jpg','2.jpg','3.jpg','4.jpg','5.jpg','6.jpg','7.jpg']
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "images",  [ __( "You can upload maximum 6 images")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()


    it.only  "if all images dont exist in tmp dir", (done)->
      utils.auth.loginDefaultAdmin (err, user)=>
        expect(err).to.be.equal(null)

        @_auctionForm.images = ['1.jpg','2.jpg','3.jpg','4.jpg','5.jpg','6.jpg']
        request.post gEnvConfig.auctionsUrl, {form: @_auctionForm}, (error, response, body)->
          expect(response.statusCode).to.be.equal(400)

          errors = errorResponseMock.factory().addValidation( "images",  [ __( "Unable to copy images from temp directory")] )
          expect(utils.jsonParseSafe(body)).to.deep.equal(errors.get())

          done()












