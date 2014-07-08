module.exports =
  modelMessages:
    "Auction": require('./Auction.js').messages

  get: (inModelName, inMessage)->
    console.log "@modelMessages",@modelMessages
    @modelMessages[inModelName][inMessage]
