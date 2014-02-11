exports.config = (app)->
  #
  # PRODUCTION settings
  #
  if app? and app.get("env") is 'production'
    app.get("env") is 'development'
    config =
      baseUrl:
        val: 'http://localhost:3000'
        allowInFrontend: true
      apiRoot:
        val: 'api'
        allowInFrontend: true
      appPort: 8001


  #
  # DEVELOPMENT settings
  #
  else
    config =
      baseUrl:
        val: 'http://localhost:3000'
        allowInFrontend: true
      apiRoot:
        val: 'api'
        allowInFrontend: true
      appPort: 3000


  return config