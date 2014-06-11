exports.makeErrorResponse = (errorType, message)->
  {
    errors: [
      {
        "errorType": errorType
        "message": message
      }
    ]
  }

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