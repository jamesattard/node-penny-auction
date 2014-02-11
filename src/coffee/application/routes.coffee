#userController  = user.userController

MainPageController  = require('./controllers/main_page').MainPageController
SessionController   = require('./controllers/session').SessionController

apiPrefix = 'api'

module.exports = (app)->

  #Main page
  app.get "/", MainPageController.preprocessRequest, (req, resp)-> (new MainPageController).index(req, resp)

  #session
  app.post    "/#{apiPrefix}/session/login", SessionController.preprocessRequest, (req, resp)-> (new SessionController).doLogin(req, resp)
  app.post    "/#{apiPrefix}/session/logout", SessionController.preprocessRequest, (req, resp)-> (new SessionController).doLogout(req, resp)


