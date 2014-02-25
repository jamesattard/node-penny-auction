// Generated by CoffeeScript 1.7.1
module.exports = function(io) {
  return io.sockets.on('connection', function(socket) {
    var session, userModel;
    session = socket.handshake.session;
    userModel = Model.instanceOf('user');
    return userModel.getById(session.userId).then(function(user) {
      socket.emit('tokens_updated', {
        tokens: user.tokens
      });
      return socket.on('do_bid', function(data) {
        console.log("BID DATA: ", data);
        if (user) {
          return Model.instanceOf('auction').doBid(data.id, user).then(function(bidResult) {
            console.log('**************', bidResult);
            socket.emit('auction_updated', {
              auction: bidResult.auction
            });
            if (bidResult.tokens != null) {
              socket.emit('tokens_updated', {
                tokens: bidResult.tokens
              });
            }
            return socket.broadcast.emit('auction_updated', {
              auction: bidResult.auction
            });
          }).fail(function(e) {
            return socket.emit('error_occured', {
              message: e.getMessage()
            });
          });
        }
      });
    }).fail(function(e) {
      return socket.emit('error_occured', {
        message: e.getMessage()
      });
    });
  });
};