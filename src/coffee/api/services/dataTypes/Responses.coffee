class Responses
  @::SuccessJson    = require('./Responses/SuccessJson').SuccessJson
  @::ErrorJson      = require('./Responses/ErrorJson').ErrorJson
  @::NormalizedJson = require('./Responses/NormalizedJson').NormalizedJson

GLOBAL.Responses = Responses