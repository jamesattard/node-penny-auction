ChaiJS = require('chai')
SinonJS = require('sinon')
Sails   = require('sails')

GLOBAL.should = ChaiJS.should
GLOBAL.expect = ChaiJS.expect
GLOBAL.assert = ChaiJS.assert
GLOBAL.sinon  = SinonJS


GLOBAL.app         = null


before (done)->
  Sails.lift
    log:
      level: 'error'
  , (err, liftedSails)->
    console.log "Sails lifted with error", err if err
    app = liftedSails
    GLOBAL.app = app
    done(err, liftedSails)

after (done)->
  app.lower done