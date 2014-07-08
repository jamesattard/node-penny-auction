_ = require("underscore")

module.exports =
  # Enforce model schema in the case of schemaless databases
  schema: true

  types:
    arrayMinLen: (arr, len)->
      _.isArray(arr) and arr.length >= len
    arrayMaxLen: (arr, len)->
      # added 'not array' condition to show only arrayMinLen's message in case if 'arr' is not array
      (not _.isArray(arr) ) or ( _.isArray(arr) and arr.length <= len )
    imagesValid: (images)->
      valid = 0
      for image in images
        #copy image
        if fs.existsSync("#{sails.config.app.tmpDir }/#{image}")
          valid++

      if valid is 0
        false
      else
        true


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
      type: "array"
      arrayMinLen: 1
      arrayMaxLen: 6
      imagesValid: true

#    toJSON: ->
#      data = @toObject()
#      delete data.password
#      data

#  afterValidate: (values, next)->
#    copied = 0
#    for image in values.images
#      #copy image
#      console.log "#{sails.config.app.tmpDir }/#{image}"
#      if fs.existsSync("#{sails.config.app.tmpDir }/#{image}")
#        copied++
#
#    if copied is 0
#      next "Unable to copy images from temp directory"
#    else
#      next null
