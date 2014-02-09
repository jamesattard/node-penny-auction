# File: src/coffee/application/controllers/base/frontend_logged_user.coffee

# Base controller for front-end pages, accessible by LOGGED USERS ONLY.
#
# Who can access these pages:
# - autenticated users with 'user' priveleges
# - authenicated users with 'admin' priveleges
#
# @example:
#   FrontendLoggedUserController.preprocessRequest(req, res, next)
# @throw: ExceptionUserMessage
#
# @author <Alexey.Pedyashev@gmail.com> Alexey Pedyashev

FrontendController = require('./frontend').FrontendController

class exports.FrontendLoggedUserController extends FrontendController
  constructor: ->
    super

  ##
  # Function to process HTTP request.
  #
  # Overrides FrontendController.preprocessRequest
  #
  # @throw: ExceptionUserMessage
  ##
  @preprocessRequest: (req, res, next)->
    super
    if @_user? and @_user
    else
      throw new ExceptionUserMessage 'error', 'You must be logged in to access this page'