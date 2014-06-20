###
  The ErrorJson class is designed to construct error response

  It can handle following data passed to its constructor:(as single object or array of these objects)
    * String - will be serialized to hash like that has following format
      {
        errorType: 'string',
        message: "....."
      }
    * Error or class derived from Error (std javascript exception error)- will be serialized to hash like that has following format
      {
        errorType: 'exception',
        message: "....."
      }
    * Instance of any class derived from SerializableError class (toJSON() will be called to get error's data for response)
      all childs of SerializableError class implements toJSON() function that will be used to serialize array

  @example
    new ErrorJson "User not found"
    new ErrorJson new Error "User not found"
    new ErrorJson new ValidationError "email", "Please enter email"

    new ErrorJson ["User not found", new Error("User not found"), new ValidationError("email", "Please enter email"), ]
###
_ = require("underscore")

class ErrorJson
  constructor: (inErrors)->
    @_errors = @_prepareErrorsForSending(inErrors)


  toJSON: ->
    errors: @_errors


  ###
    Takes error(s) and return array of objects with following format:
    {
    errorType: 'string|validation|exception',
    message: 'some error description',
    field: '<name of the field that causes error (FOR errorType=validation ONLY)>'
    }
  ###
  _prepareErrorsForSending: (inErrors) ->

    errors = []

    # 1. inErrors is array
    if _.isArray inErrors
      # translate messages and response with serverError
      for error in inErrors
        errorJson = @_normalizeError(error)
        errors = @_smartPush errorJson, errors if errorJson
    # 2. inErrors is object
    else
      errorJson = @_normalizeError(inErrors)
      errors = @_smartPush errorJson, errors if errorJson

    errors

  _normalizeError: (inError)->
    # 1.1 of strings
    if typeof inError is 'string'
      errorNormalized =
        errorType: 'string'
        message: sails.__( inError )

    # Scenarion 1.2
    # inError is instance of Error
    else if inError instanceof Error
      if sails.config.environment isnt 'production'
        errorNormalized =
          errorType : 'exception'
          message  : inError.message
      else
        errorNormalized = false

    # 1.3 of validation errors
    else if (inError instanceof SerializableError)
      errorNormalized = inError.toJSON()

    errorNormalized


  ###
    pushes inSrc to ioDest if inSrc is flat object
    merges inSrc into ioDest if inSrc is array

    @returns ioDest with added/merged inSrc
  ###
  _smartPush: (inSrc, ioDest)->
    # if inSrc is array then merge it to ioDest
    if _.isArray inSrc
      ioDest = ioDest.concat inSrc

    # if inSrc is object then just push it
    else if _.isObject inSrc
      ioDest.push inSrc

    ioDest



exports.ErrorJson = ErrorJson