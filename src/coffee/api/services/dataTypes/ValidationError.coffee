###
  @example new ValidationError field, messages
  @example new ValidationError WLValidationError
###

validationMessages = require("../../validations")

class ValidationError extends SerializableError
  constructor: ->
    if arguments.length is 0
      throw DevError "No arguments passed to ValidationError constructor"

    @_errors = []

    if arguments.length is 2
      @_addNew arguments[0], arguments[1]
    else if arguments.length is 1
      @_parseModelValidations arguments[0]


  toJSON: ->
    @_errors

  _addNew: (field, messages)->
    messages = [messages] if _.isString messages

    @_errors.push
      errorType : 'validation'
      field     : field
      messages  : messages

  _parseModelValidations: (inError) ->
    for field, details of inError.invalidAttributes
      messages = []
      for detail in details
        messages.push(validationMessages.get( inError.model, "#{field}.#{detail.rule}") )#(detail.message)

      @_addNew field, messages

    @_errors


GLOBAL.ValidationError = ValidationError