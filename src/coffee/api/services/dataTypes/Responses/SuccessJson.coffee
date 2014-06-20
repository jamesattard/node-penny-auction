_ = require("underscore")

class SuccessJson
  constructor: (@data = {})->

  toJSON: ->
    {
      data: @data
      messages: @messages
    }

exports.SuccessJson = SuccessJson