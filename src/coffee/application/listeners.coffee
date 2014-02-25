# File: src/coffee/application/listeners.coffee

#
# Defines listeners for Socket.io. Accepts initialized and connected Socket.io object
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#

#export listeners
module.exports = (io)->

  #Init all listeners on client's connection
  io.sockets.on 'connection', (socket)->

    session   = socket.handshake.session
    userModel = Model.instanceOf('user')

    #init listeners after user is read from DB based on userId from session
    userModel.getById(session.userId).then (user)->

      #send tokens available
      socket.emit 'tokens_updated', tokens: user.tokens

      #attach 'do bid' listener
      socket.on 'do_bid', (data)->
        console.log "BID DATA: ", data
        #Bid only if user is available
        if user
          Model.instanceOf('auction').doBid(data.id, user).then (bidResult)->

            #reply to sender
            socket.emit 'auction_updated', auction: bidResult.auction
            socket.emit 'tokens_updated', tokens: bidResult.tokens if bidResult.tokens?

            #send the 'auction_updated' command to the rest users
            socket.broadcast.emit 'auction_updated', auction: bidResult.auction

          .fail (e)->
            socket.emit 'error_occured', message: e.getMessage()
    .fail (e)->
        socket.emit 'error_occured', message: e.getMessage()


