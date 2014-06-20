class SerializableError
  toJSON: ->
    throw Error "toJSON is not implemented for child of SerializableError class"

GLOBAL.SerializableError = SerializableError