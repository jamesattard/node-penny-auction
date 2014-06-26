exports =
  mocks : require('./mocks')
  i18n  : require('./i18n')
  auth  : require('./authHelper')

exports.jsonParseSafe = (json)->
  if json
    JSON.parse(json)
  else
    null