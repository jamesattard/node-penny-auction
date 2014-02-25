# File: src/coffee/application/models/auction.coffee

Q         = require('q')
Model     = require('../../core/models').Model
mongoose  = require('mongoose')

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
    @_hiddenFields = ['bidders']

    #call parent class' constuctor
    super(_schemaDescription)


  # Saves auctions data do DB
  #
  # @param  [Hash]        inData    Auctions data
  #
  # @return [Object]      Q.defer.promise
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


  # Reads all auctions from DB
  #
  # @return [Object]      Q.defer.promise
  findAll: ->
    defer = Q.defer()
    @getMongooseModel().find().exec (err, result)->
      if err
        defer.reject new ExceptionUserMessage("error", "An error has occured while reading auctions")
      else
        defer.resolve result

    defer.promise


  # Bids on auction and decreases user's tokens
  #
  # @param  [ObjectId]        inAuctionId    MongoDB's ObjectId of auction
  # @param  [Hash]            inUser         User obtained from MongoDB
  #
  # @return [Object]      Q.defer.promise
  #
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



  # Updates auction document with new bid in DB, decreases user's tokens and re-reads auction and tokens from DB
  #
  # @param  [ObjectId]        inAuctionId    MongoDB's ObjectId of auction
  # @param  [Hash]            inUser         User obtained from MongoDB
  #
  # @return [Object]          Q.defer.promise
  #
  _doBid: (inAuctionId, inUser)->
    defer = Q.defer()

    options     = {}
    conditions  = {"_id": inAuctionId}
    bidder      =
      userId    : inUser._id
      username  : inUser.username

    #update auction's info with new bid
    update =
      $addToSet:
        bidders: bidder
      lastBidder: bidder
      $inc:
        currentPrice: 0.01
    @getMongooseModel().update conditions, update, options, (err, affected)->
      if err
        defer.reject new ExceptionUserMessage("error", "DB error")
      else
        defer.resolve affected

    #decrement users tokens and re-read neccesary data
    defer.promise.then =>
      Model.instanceOf('user').decrementTokens(inUser._id).then (tokens)=>
        @getById(inAuctionId).then (auction)=>
          defer1 = Q.defer()
          data =
            auction : auction
            tokens  : tokens
          defer1.resolve data

          defer1.promise
