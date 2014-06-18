_ = require("underscore")

class ErrorResponse
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
    # 1. inErrors is array
    errors = []

    if _.isArray inErrors
      # translate messages and response with serverError
      for error in inErrors
        errors = @_smartPush @_normalizeError(error), errors
#        errors.push @_normalizeError(error)
    else
#      errors.push @_normalizeError(inErrors)
      errors = @_smartPush @_normalizeError(inErrors), errors

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
      errorNormalized =
        errorType : 'exception'
        messages  : inError.message

    # 1.3 of validation errors
    else if (_.isObject inError) and (_.isFunction inError.toJSON)
      errorNormalized = inError.toJSON()

    errorNormalized


  _smartPush: (inSrc, ioDest)->
    # if inSrc is array then merge it to ioDest
    if _.isArray inSrc
      ioDest = ioDest.concat inSrc

    # if inSrc is object then just push it
    else if _.isObject inSrc
      ioDest.push inSrc

    ioDest



GLOBAL.ErrorResponse = ErrorResponse