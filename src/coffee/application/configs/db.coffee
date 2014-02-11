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
        dbName: 'penny_auction'

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
        dbName: 'penny_auction'

  return config