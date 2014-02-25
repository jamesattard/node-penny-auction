# File: src/coffee/application/models/auction.coffee

Q       = require('q')
Model = require('../../core/models').Model
mongoose = require('mongoose')

# Model that implements DB-related operations for auctions
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#
class exports.Auction extends Model.Mongo
  # Mongoose Schema  description
  _schemaDescription =
    title:          String
    description:    String
    images:         [ String ]
    bidders:        [{userId: mongoose.Schema.ObjectId, username: String}]
    lastBidder:     { userId: mongoose.Schema.ObjectId, username: String}
    startingPrice:  Number
    currentPrice:   Number
    retailerPrice:  Number
    startDate:      Date
    endDate:        Date

  constructor: ->
    #fields which shouldn't be read from DB
#    @_hiddenFields = []

    #call parent class' constuctor
    super(_schemaDescription)


  # Saves user data do DB
  #
  # @param  [Hash]        inUserData    User data to be saved
  # @param  [callback]    onComplete    callback function that is called once save operation is completed. Signature:
  #                                     onComplete(err, exception) - where err and exception are null when saving was OK
  #
  # @todo: add updating of user when _id is presented
  #
  save: (inData)->
    defer = Q.defer()

    doc = @createMongooseDocument(inData)

    #save the document
    doc.save (err)->
      if err
        defer.reject new ExceptionUserMessage("error", "Unable to save")
      else
        defer.resolve()

    defer.promise


  # Creates user and returns it or finds user with email=inUserData.email and returns it
  #
  # @param  [Hash]        inUserData    User data to be saved
  # @param  [callback]    onComplete    callback function that is called once save operation is completed. Signature:
  #                                     onComplete(err, info) - where err and info is either userData or instance of ExceptionUserMessage
  #
  findAll: ->
    defer = Q.defer()
    @getMongooseModel().find().exec (err, result)->
      if err
        defer.reject new ExceptionUserMessage("error", "An error has occured while reading auctions")
      else
        defer.resolve result

    defer.promise


  doBid: (inAuctionId, inUser)->
    Model.instanceOf('user').getTokens(inUser._id).then (tokens)=>
      if tokens > 0
        @getById(inAuctionId).then (auction)=>
          if auction.lastBidder.userId.toHexString() isnt inUser._id.toHexString()
            return @_doBid(inAuctionId, inUser)
          else
            defer = Q.defer()
            defer.resolve auction: auction
            return defer.promise
      else
        defer = Q.defer()
        defer.reject new ExceptionUserMessage("error", "You do not have tokens to continue bidding")
        defer.promise



  _doBid: (inAuctionId, inUser)->
    defer = Q.defer()

    options     = {}
    conditions  = {"_id": inAuctionId}
    bidder      =
      userId    : inUser._id
      username  : inUser.username
    # @todo: add curent bid val

    update =
      $addToSet: {bidders: bidder }
      lastBidder: bidder
      $inc: {currentPrice: 0.01 }
    @getMongooseModel().update conditions, update, options, (err, affected)->
      if err
        defer.reject new ExceptionUserMessage("error", "DB error")
      else
        defer.resolve affected

    defer.promise.then =>
      Model.instanceOf('user').decrementTokens(inUser._id).then (tokens)=>
        @getById(inAuctionId).then (auction)=>
          defer1 = Q.defer()
          data =
            auction : auction
            tokens  : tokens
          defer1.resolve data

          defer1.promise







  # Check if user with given email is already exists in DB
  #
  # @param  [String]      inEmail       Email address to be checked
  # @param  [String]      onComplete    Callback to be called when operation is completed, Accepts one param: isExist
  #
  isEmailExist: (inEmail, onComplete)->
    @getMongooseModel().findOne({'email': inEmail}).exec (err, result)->
      isExist = result isnt null
      onComplete(isExist)







  # Logins user based on email and password
  #
  # @param  [String]      inEmail       Email address
  # @param  [String]      inPassword    Password(not encrypted)
  # @param  [callback]    onComplete    callback function that is called once save operation is completed.
  #
  login: (inEmail, inPassword, onComplete)->
    crypto    = require('crypto')
    password  = crypto.createHash('md5').update(inPassword).digest("hex")
    @getMongooseModel().findOne({'email': inEmail, 'password': password}, @_allowedFields).exec (err, result)->
      onComplete( result )


  # Finds user with given email
  #
  # @param  [String]      inEmail       Email address
  # @param  [callback]    onComplete    callback function that is called once save operation is completed. Signature:
  #                                     onComplete(err, info) - where err and info is either userData or instance of ExceptionUserMessage
  getByEmail: (inEmail, onComplete)->
    @getMongooseModel().findOne({'email': inEmail}, @_allowedFields).exec (err, user)->
      unless err
        onComplete( err, user )
      else
        exception = new ExceptionUserMessage("error", "Unable to find user with email (#{inEmail})")
        onComplete( err, exception )

  # Updates existing or adds new category for logged user
  #
  # @param userId         [ObjectId]    Mongo's ObjectId
  # @param categoryData   [hash]        Categories data to by updated. Must have index and name.
  #                                     If index is -1 then name will be added to array
  # @param onComplete     [function]    callback to be called when update is completed
  #
  saveCategory: (userId, categoryData, onComplete)->
    @isCategoryExist userId, categoryData.name, (err, isExist)=>
      if (not isExist)
        options = {}
        if parseInt(categoryData.index) is -1
          #push new
          conditions = {"_id": userId}
          category = {name: categoryData.name}
          update = {$addToSet: {linkCategories: category }}
        else
          #update existing
          conditions  = {"$and": [{"_id": userId}, {"linkCategories._id": categoryData.index}] }
          update      = {$set: {"linkCategories.$.name": categoryData.name} }
        @getMongooseModel().update conditions, update, options, (err, affected)->
          unless err
            onComplete err, affected
          else
            onComplete true, new ExceptionUserMessage("error", "Category #{categoryData.name} already exist")
      else
        onComplete true, new ExceptionUserMessage("error", "Category #{categoryData.name} already exist")


  # Removes category from user by categories ID
  #
  # @param  [String]      inUserId        Id of user (mongo's ObjectId represented as string)
  # @param  [Hash]        inCategoryData  Key-value hash that contains _id field
  # @param  [String]      onComplete      Callback to be called when operation is completed, Accepts err, linkCategories
  #
  # @todo: change inCategoryData.index to inCategoryData._id
  #
  deleteCategory: (inUserId, inCategoryData, onComplete)->
    conditions  = {"$and": [{"_id": inUserId}, {"linkCategories._id": inCategoryData.index}] }
    update      = {$pull: {linkCategories: {_id: inCategoryData.index}} }
    @getMongooseModel().update conditions, update, (err, numberAffected)=>
      @getCategoriesByUserId inUserId, onComplete


  isCategoryExist: (inUserId, inCategoryName, onComplete)->
    conditions  = {"$and": [{"_id": inUserId}, {'linkCategories.name': inCategoryName}] }
#    @getMongooseModel().findOne({'linkCategories.name': inCategoryName}, "linkCategories").exec (err, result)->
    @getMongooseModel().findOne(conditions, "linkCategories").exec (err, result)->
      isExist = (result isnt null)
      onComplete err, isExist



  # Retrives categories of specified user
  #
  # @param  [String]      inUserId        Id of user (mongo's ObjectId represented as string)
  # @param  [String]      onComplete      Callback to be called when operation is completed,
  #
  getCategoriesByUserId: (inUserId, onComplete)->
    @getMongooseModel().findOne({'_id': inUserId}, "linkCategories").exec (err, result)->
      onComplete err, result.linkCategories



  # Retrives categories of specified user
  #
  # @param  [String]      inUserId        Id of user (mongo's ObjectId represented as string)
  # @param  [String]      inCategoryName  Category name
  # @param  [String]      onComplete      Callback to be called when operation is completed,
  #
  getCategoryByUserIdAndCatName: (inUserId, inCategoryName, onComplete)->
    conditions  = {"$and": [{"_id": inUserId}, {'linkCategories.name': inCategoryName}] }
    @getMongooseModel().findOne(conditions, "linkCategories").exec (err, result)->
      for cat in result.linkCategories
        if cat.name is inCategoryName
          onComplete err, cat
          break

  saveLanguage: (inUserId, inLangId, onComplete)->
    conditions  = {"_id": inUserId}
    update      = {$set: {"languageId": inLangId} }
    options     = {}
    @getMongooseModel().update conditions, update, options, (err, affected)->
      unless err
        onComplete err, affected
      else
        onComplete true, new ExceptionUserMessage("error", "Unable to save language id")

  _saveUser: (inUserData, onComplete)->
    #add default category
    inUserData['linkCategories']      = [{name: 'Default'}]

    crypto = require('crypto');
    inUserData.password = crypto.createHash('md5').update(inUserData.password).digest("hex")
    doc = @createMongooseDocument(inUserData)

    #save the document
    doc.save (err)->
      exception = null
      if err
        exception = new ExceptionUserMessage("error", "unable to save")
      onComplete err, exception


