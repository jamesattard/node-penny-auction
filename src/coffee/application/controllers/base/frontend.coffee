# File: src/coffee/application/controllers/base/frontend.coffee

# Base controller for front-end pages. It's intended to be used as base class for pages which are allowed for both
# authenticated and non-authenticated users.
#
# Addes common JS/CSS files (which are used by all front-end pages) to the assets rendering queue
#
# Who can access these pages:
# - non-authenticated users
# - autenticated users with 'user' priveleges
# - authenicated users with 'admin' priveleges
#
# @author <Alexey.Pedyashev@gmail.com> Alexey Pedyashev

BaseUserController = require('./user').BaseUserController

class exports.FrontendController  extends BaseUserController
  self = FrontendController

  constructor: ->
    super

  ##
  # Function to process HTTP request.
  #
  # Overrides UserController.preprocessRequest
  ##
  @preprocessRequest: (req, res, next)->
    super

    #Add common JS/CSS files
#    appRoot = FrontendController.getStatic('appRoot')

    FrontendController.getStatic('assets').js.addFile("lib/jquery-1.7.min")
    FrontendController.getStatic('assets').js.addFile("lib/jquery.jcarousel")
    FrontendController.getStatic('assets').js.addFile("lib/prettyCheckboxes")
    FrontendController.getStatic('assets').js.addFile("lib/DD_belatedPNG-min")
    FrontendController.getStatic('assets').js.addFile("lib/functions")
    FrontendController.getStatic('assets').js.addFile("lib/spin.min")
    FrontendController.getStatic('assets').js.addFile("lib/helpers")
    FrontendController.getStatic('assets').js.addFile("layout")


    FrontendController.getStatic('assets').css.addFile("style")
    FrontendController.getStatic('assets').css.addFile("prettyCheckboxes")

    #if user is not logged in
    userPromise = self.getStatic('userPromise')
    unless userPromise
      FrontendController.getStatic('assets').js.addFile("lib/jquery.fancybox.pack")
      FrontendController.getStatic('assets').js.addFile("lib/jquery.validate.min")
      FrontendController.getStatic('assets').js.addFile("user-session")

      FrontendController.getStatic('assets').css.addFile("jquery.fancybox")


    next() if next?