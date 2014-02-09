
FrontendController = require('./base/frontend').FrontendController

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


  index: (req, res)=>
    res.render @_getViewName(),
      jsTags  : @_assets.js.renderTags()
      cssTags : @_assets.css.renderTags()


