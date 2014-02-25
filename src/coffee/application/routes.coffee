# File: src/coffee/application/routes.coffee

#
# Defines application routes
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#

#Include controllers
MainPageController  = require('./controllers/main_page').MainPageController
SessionController   = require('./controllers/session').SessionController

#init prefix used as root for API requests
apiPrefix =  configs.config.apiRoot.val

#export routes
module.exports = (app)->

  #Routes for ain page controller
  app.get "/", MainPageController.preprocessRequest, (req, resp)-> (new MainPageController).index(req, resp)

  #Routes for session controller
  app.post    "/#{apiPrefix}/session/login", SessionController.preprocessRequest, (req, resp)-> (new SessionController).doLogin(req, resp)
  app.post    "/#{apiPrefix}/session/logout", SessionController.preprocessRequest, (req, resp)-> (new SessionController).doLogout(req, resp)


