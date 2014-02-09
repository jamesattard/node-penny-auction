exports.configDb = (app)->
  #
  # PRODUCTION
  #
  if app? and app.get("env") is 'production'
    config =
      #list of available DB models. Possible values: 'mongo'
      dbs: [
        'mongo'
      ]
      #MongoDb config object
      mongo:
        host: 'localhost'
      #    port:27017
        dbName: 'links_bookmarklet'

  #
  # DEVELOPMENT settings
  #
  else
    config =
    #list of available DB models. Possible values: 'mongo'
      dbs: [
        'mongo'
      ]
    #MongoDb config object
      mongo:
        host: 'localhost'
      #    port:27017
        dbName: 'links_bookmarklet'

  return config