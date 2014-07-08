module.exports =
  modelMessages:
    "Auction": require('./Auction.js').messages

  get: (inModelName, inMessage)->
    if @modelMessages[inModelName][inMessage]?
      @modelMessages[inModelName][inMessage]
    else
      inMessage
