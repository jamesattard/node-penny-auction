
module.exports = (io)->
  io.sockets.on 'connection', (socket)->
#    socket.emit 'news', { hello: 'world' }
    session = socket.handshake.session
#    console.log 'SESSION', session, session.userId
    userModel = Model.instanceOf('user')

    userModel.getById(session.userId).then (user)->
      socket.emit 'tokens_updated', tokens: user.tokens
      socket.on 'do_bid', (data)->
        console.log "BID DATA: ", data
        if user
          Model.instanceOf('auction').doBid(data.id, user).then (bidResult)->
            console.log '**************', bidResult

            #reply to sender
            socket.emit 'auction_updated', auction: bidResult.auction
            socket.emit 'tokens_updated', tokens: bidResult.tokens if bidResult.tokens?

            #send the 'auction_updated' command to the rest users
            socket.broadcast.emit 'auction_updated', auction: bidResult.auction

          .fail (e)->
            socket.emit 'error_occured', message: e.getMessage()
    .fail (e)->
        socket.emit 'error_occured', message: e.getMessage()


