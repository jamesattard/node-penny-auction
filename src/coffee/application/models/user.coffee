# File: src/coffee/application/models/user.coffee

Q     = require('q')
Model = require('../../core/models').Model

# Model that implements DB-related operations for users
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#
class User extends Model.Mongo
  # Mongoose Schema  description
  _schemaDescription =
    firstName:  String
    lastName:   String
    email:      String
    username:   String
    password:   String
    tokens:     Number

  constructor: ->
    #fields which shouldn't be read from DB
    @_hiddenFields = ['password']

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
  #
  login: (inEmail, inPassword)->
    defer = Q.defer()

    crypto    = require('crypto')
    password  = crypto.createHash('md5').update(inPassword).digest("hex")
    @getMongooseModel().findOne({'email': inEmail, 'password': password}, @_allowedFields).exec (err, result)->
      if err
        defer.reject new ExceptionUserMessage("error", "DB error")
      else
        if result
          defer.resolve(result)
        else
          defer.reject new ExceptionUserMessage("error", "Email or password is incorect")

    defer.promise


  getTokens: (inUserId)->
    defer = Q.defer()

    conditions  = {"_id": inUserId}
    @getMongooseModel().findOne(conditions, "tokens").exec (err, result)->
      if err
        defer.reject new ExceptionUserMessage("error", "DB error")
      else
        if result
          defer.resolve(result.tokens)
        else
          defer.reject new ExceptionUserMessage("error", "No user found")

    defer.promise


  decrementTokens: (inUserId)->
    defer = Q.defer()

    conditions  = {"_id": inUserId}
    update =
      $inc: {tokens: -1 }
    options     = {}
    @getMongooseModel().update conditions, update, options, (err, affected)->
      if err
        defer.reject new ExceptionUserMessage("error", "DB error")
      else
        defer.resolve affected

    defer.promise.then =>
      @getTokens(inUserId)


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