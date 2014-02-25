# File: src/coffee/application/controllers/main_page.coffee

FrontendController  = require('./base/frontend').FrontendController
Model               = require('../../core/models').Model

# Controller to serve main page
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#
class exports.MainPageController extends FrontendController
  constructor: ->
    super

  ##
  # Function to process HTTP request.
  #
  # Overrides FrontendController.preprocessRequest
  #
  ##
  @preprocessRequest: (req, res, next)->
    super


  # Renders main page
  index: (req, res)=>

    viewName = @_getViewName()
    @_assets.css.addFile("font-awesome")
    @_assets.js.addFile("auction")
    @_assets.js.addFile("#{viewName}")

    @_assets.compile()

    #get view name here since the _getViewName uses function-caller's name to build view name
    Model.instanceOf('auction').findAll().then( (auctions)=>
      userPromise = @get('userPromise')
      if userPromise
        userPromise.then (user)=>
          res.render viewName,
            title: 'Auctions home'
            jsTags  : @_assets.renderJs()
            cssTags : @_assets.renderCss()
            auctions: auctions
            getSecsDiffToDate: getSecsDiffToDate
            configs: configs.getFrontendConfigs()
            user: user
        .fail (e)-> console.log e.toJson()
      else
        res.render viewName,
          title: 'Auctions home'
          jsTags  : @_assets.renderJs()
          cssTags : @_assets.renderCss()
          auctions: auctions
          getSecsDiffToDate: getSecsDiffToDate
          configs: configs.getFrontendConfigs()
          user: null
    )
    .fail (e)-> console.log e.toJson()


#  createTestAuction: ->
#    auctionData =
#      title:          "iPod touch"
#      description:    "iPod touch description"
#      images:         ["https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSC5N7RemEVUvZne55CvHOKwQRaCHgsZiJxvtSAl9mk9vFq12Sp"]
#      bidders:        [{}]
#      startingPrice:  5.1
#      retailerPrice:  99.99
#      startDate:      new Date(2014, 0, 30, 15, 15)
#      endDate:        new Date(2017, 5, 15, 12)
#
#    Model.instanceOf('auction').save(auctionData).then( ->
#      console.log 'saved'
#    )
#    .fail (e)-> console.log e.toJson()



