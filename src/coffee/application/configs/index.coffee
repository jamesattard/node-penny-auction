module.exports = (app)->
  config:   require('./config.js').config(app)
  db:       require('./db.js').configDb(app)
  getFrontendConfigs: ->
    configsStr = "window.appConfig = {};\n"
    for configFileName, configFileContent of @
      unless _.isFunction(@[configFileName])
        configsStr += 'appConfig[\'' + configFileName + '\'] = {};\n'
        for configFileParamName, configFileParamContent of configFileContent
          if configFileParamContent.allowInFrontend
            val = configFileParamContent.val
            if _.isString val
              val = "'#{val}'"
#            if _.isObject val
#              val = JSON.stringify( val )

            configsStr += ('appConfig[\'' + configFileName + '\'][\'' + configFileParamName + '\'] = ' + val + ";\n")
    configsStr