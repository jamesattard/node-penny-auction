#sails = require('sails')
#
#describe "", ->
#  sails = null
#  before (done)->
#
#    # Lift Sails and start the server
#    Sails.lift
#        log:
#          level: 'error'
#    , (err, liftedSails)->
#      sails = liftedSails
#      done(err, liftedSails)
#
#  after (done)->
#    sails.lower(done)
#
