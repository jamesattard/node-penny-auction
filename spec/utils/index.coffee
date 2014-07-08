exports.mocks = require('./mocks')
exports.i18n  = require('./i18n')
exports.auth  = require('./authHelper')

exports.jsonParseSafe = (json)->
  if json
    JSON.parse(json)
  else
    null