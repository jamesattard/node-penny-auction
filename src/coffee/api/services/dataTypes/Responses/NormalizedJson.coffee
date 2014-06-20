class NormalizedJson
  constructor: (@data = {}, @messages=[])->
    @messages = [@messages] if _.isString @messages

  toJSON: ->
    {
      data: @data
      messages: @messages
    }

exports.NormalizedJson = NormalizedJson