class DevError
  constructor: (@message)->
    @name = @constructor.name

  @:: = new Error()
  @::constructor = @

GLOBAL.DevError = DevError