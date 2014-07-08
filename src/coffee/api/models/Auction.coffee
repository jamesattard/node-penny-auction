module.exports =
  # Enforce model schema in the case of schemaless databases
  schema: true
  attributes:
    title:
      type: "string"
      required: true
      maxLength: 100

    description:
      type: "string"
      required: true

    startPrice:
      type: "int"

    retailerPrice:
      type: "int"

    startsAt:
      type: "datetime"

    expiresAt:
      type: "datetime"

    images:
      type: 'array'

#    toJSON: ->
#      data = @toObject()
#      delete data.password
#      data