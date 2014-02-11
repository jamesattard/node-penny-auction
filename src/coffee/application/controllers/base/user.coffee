# File: src/coffee/application/controllers/base/user.coffee

CoreController  = require('../../../core/controller.js').CoreController
Model           = require('../../../core/models').Model

# Base controller to handle common user-related operation. Can be extended by both front-end and admin controllers
#
# Who can access these pages:
# - non-authenticated users
# - autenticated users with 'user' priveleges
# - authenicated users with 'admin' priveleges
#
# @example:
#   BaseUserController.preprocessRequest(req, res, next)
#
# @author <Alexey.Pedyashev@gmail.com> Alexey Pedyashev
class exports.BaseUserController extends  CoreController
  self = BaseUserController

  constructor: ->
    super

  @preprocessRequest: (req, res, next)->
    super

    #get user's id from session and read user's data from cache/DB
    userId = req.session.userId

    #@todo: add "read user's data from cache/DB"
    userPromise = false
    if userId
      userPromise = Model.instanceOf('user').getById(userId)

    self.setStatic('userPromise', userPromise)


