_ = require("underscore")

class SuccessJsonResponse
  constructor: (@data = {}, @messages=[])->
    @messages = [@messages] if _.isString @messages

  toJSON: ->
    {
      data: @data
      messages: @messages
    }

GLOBAL.SuccessJsonResponse = SuccessJsonResponse