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
    appRoot = FrontendController.getStatic('appRoot')
    FrontendController.getStatic('assets').js.addFile( appRoot + "/public/javascripts/lib/jquery-1.7.min.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/jquery.jcarousel.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/prettyCheckboxes.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/DD_belatedPNG-min.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/functions.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/spin.min.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/helpers.js")
    FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/layout.js")


    FrontendController.getStatic('assets').css.addFile(appRoot + "/public/stylesheets/style.css")
    FrontendController.getStatic('assets').css.addFile(appRoot + "/public/stylesheets/prettyCheckboxes.css")

    #if user is not logged in
    userPromise = self.getStatic('userPromise')
    unless userPromise
      FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/jquery.fancybox.pack.js")
      FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/lib/jquery.validate.min.js")
      FrontendController.getStatic('assets').js.addFile(appRoot + "/public/javascripts/user-session.js")

      FrontendController.getStatic('assets').css.addFile(appRoot + "/public/stylesheets/jquery.fancybox.css")


    next() if next?