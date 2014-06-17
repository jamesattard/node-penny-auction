exports.jsonParseSafe = (json)->
  if json
    JSON.parse(json)
  else
    null