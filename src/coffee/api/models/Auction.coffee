_ = require("underscore")
mkdirp = require('mkdirp')

module.exports =
  # Enforce model schema in the case of schemaless databases
  schema: true

  types:
    arrayMinLen: (arr, len)->
      _.isArray(arr) and arr.length >= len
    arrayMaxLen: (arr, len)->
      # added 'not array' condition to show only arrayMinLen's message in case if 'arr' is not array
      (not _.isArray(arr) ) or ( _.isArray(arr) and arr.length <= len )

    ###
    Checks if images are exists in tmp dir (i.e. if they were uploaded before via AJAX)
    ###
    imagesValid: (images)->
      valid = 0
#      validImages = []
      for image in images
        if fs.existsSync("#{sails.config.app.tmpDir }/#{image}")
          valid++
#          validImages.push image

#      images = validImages
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
      type: "decimal"
      min: 0.01

    retailerPrice:
      required: true
      type: "decimal"
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

    toJSON: (jsonFormat)->
      data = @toObject()
      # if client requests response in JsonApi format, then add namespace
      if jsonFormat is "jsonapi"
        data =
          "auction": data
      data

  afterValidate: (auction, next)->
    validImages = []
    for image in auction.images
      if fs.existsSync("#{sails.config.app.tmpDir }/#{image}")
        validImages.push image

    auction.images = validImages
    next null, auction

  ###
    After auction was created in DB, copy valid images to auctions dir

    NOTE: images were validated by imagesValid rule so all images in DB should be existing
  ###
  afterCreate: (newAuction, next)->
    auctionImagesDir = "#{sails.config.app.baseDir}/uploads/auctions/#{newAuction.id}"
    mkdirp auctionImagesDir,  (err)->
      if err
        next err
      else
        for image in newAuction.images
          #copy image
          tmpImage = "#{sails.config.app.tmpDir }/#{image}"
          fs.createReadStream(tmpImage).pipe(fs.createWriteStream("#{auctionImagesDir}/#{image}"))
          fs.unlink(tmpImage)
        next()

