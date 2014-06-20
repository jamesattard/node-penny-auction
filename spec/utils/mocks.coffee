_ = require('underscore')
# @deprecated. Use mocks,api.errorResponse instead
exports.makeErrorResponse = (errorType, message)->
  {
    errors: [
      {
        "errorType": errorType
        "message": message
      }
    ]
  }

# @deprecated. Use mocks,api.errorResponse.addValidation.get() instead
exports.makeValidationErrorsResponse = (field, messages)->
  {
    errors: [
      {
        errorType : 'validation'
        field     : field
        messages  : messages
      }
    ]
  }

class ErrorResponseMock
  constructor: ->
    @errors = []

  factory: ->
    new ErrorResponseMock

  addString: (message)->
    @errors.push
      errorType: 'string'
      message: message

    @

  addException: (message)->
    @errors.push
      errorType: 'exception'
      message: message

    @

  addCustom: (errorData)->
    @errors.push errorData
    @

  addValidation: (field, messages)->
    messages = [messages] unless _.isArray messages
    @errors.push
      errorType : 'validation'
      field     : field
      messages  : messages

    @

  get: ->
    json = {errors: @errors}
    @errors = []
    json

exports.api =
  errorResponse   : new ErrorResponseMock
