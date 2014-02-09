#userController  = user.userController

MainPageController = require('./controllers/main_page').MainPageController
apiPrefix = 'api'

module.exports = (app)->

  app.get "/", MainPageController.preprocessRequest, (req, resp)-> (new MainPageController).index(req, resp)



#  myMiddleware = (req, resp, next)->
#    console.log 'works'
#    next()
#  app.get "/", myMiddleware, (new MainPageController).index

  #user
#  app.post    "/#{apiPrefix}/user/register", userController.register


