exports.mocks = require('./mocks')
exports.i18n  = require('./i18n')

exports.jsonParseSafe = (json)->
  if json
    JSON.parse(json)
  else
    null