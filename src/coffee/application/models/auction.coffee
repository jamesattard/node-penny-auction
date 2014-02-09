# File: src/coffee/application/models/auction.coffee

# Model that implements DB-related operations for auctions
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#
class Auction extends Model.Mongo
  # Mongoose Schema  description
  _schemaDescription =
    title:          String
    description:    String
    bidders:        [{}]
    startingPrice:  Number
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
  save: (inUserData, onComplete)->
    if inUserData.email?
      @isEmailExist inUserData.email, (isExist)=>
        if not isExist
          @_saveUser inUserData, onComplete
        #user with such email already exist
        else
          exception = new ExceptionUserMessage("error", "User with such email already exist")
          onComplete(yes, exception)


  # Creates user and returns it or finds user with email=inUserData.email and returns it
  #
  # @param  [Hash]        inUserData    User data to be saved
  # @param  [callback]    onComplete    callback function that is called once save operation is completed. Signature:
  #                                     onComplete(err, info) - where err and info is either userData or instance of ExceptionUserMessage
  #
  findByEmailOrCreate: (inUserData, onComplete)->
    @isEmailExist inUserData.email, (isExist)=>
      if isExist
        #read user data from db
        @getByEmail inUserData.email, onComplete
      else
        #add new user
        @_saveUser inUserData, (err, exception)=>
          unless err
            @getByEmail inUserData.email, onComplete
          else
            onComplete yes, exception


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


exports.User = User