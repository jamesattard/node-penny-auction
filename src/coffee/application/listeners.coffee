
module.exports = (io)->
  io.sockets.on 'connection', (socket)->
#    socket.emit 'news', { hello: 'world' }
    session = socket.handshake.session
#    console.log 'SESSION', session, session.userId
    Model.instanceOf('user').getById(session.userId).then (user)->
      socket.on 'do_bid', (data)->
        console.log "BID DATA: ", data
        if user
          Model.instanceOf('auction').doBid(data.id, user).then (auction)->
            #reply to sender
            socket.emit 'auction_updated', auction: auction
            #send the 'auction_updated' command to the rest users
            socket.broadcast.emit 'auction_updated', auction: auction
    .fail (e)->
        socket.emit 'auction_updated', messages: e.toJson()
