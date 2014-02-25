exports.config = (app)->
  #
  # PRODUCTION settings
  #
  if app? and app.get("env") is 'production'
    config =
      baseUrl:
        val: 'http://node-auc.rrs-lab.com'
        allowInFrontend: true
      apiRoot:
        val: 'api'
        allowInFrontend: true
      appPort:
        val: 8002
        allowInFrontend: true


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
      appPort:
        val: 3000
        allowInFrontend: true


  return config