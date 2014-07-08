module.exports =
  # Enforce model schema in the case of schemaless databases
  schema: true
  attributes:
    title:
      required: true
      maxLength: 100

    description:
      required: true

    startPrice:
      required: true
      type: "numeric"
      min: 0.01

    retailerPrice:
      required: true
      type: "numeric"
      min: 0.01

    startsAt:
      required: true
      type: "datetime"

    expiresAt:
      required: true
      type: "datetime"

    images:
      required: true
      type: 'array'

#    toJSON: ->
#      data = @toObject()
#      delete data.password
#      data