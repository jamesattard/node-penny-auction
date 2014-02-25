# File: src/coffee/application/controllers/session.coffee

FrontendController  = require('./base/frontend').FrontendController
Model               = require('../../core/models').Model

# Controller to handle session
#
# @author   Alexey Pedyashev <alexey.pedyashev@gmail.com>
#
class exports.SessionController extends FrontendController
  constructor: ->
    super

  ##
  # Function to process HTTP request.
  #
  # Overrides FrontendController.preprocessRequest
  #
  ##
  @preprocessRequest: (req, res, next)->
    super


  # Performs user login. Replies with JSON in format of Core::Helpers::json
  #
  doLogin: (req, res)=>
    Model.instanceOf('user').login(req.body.email, req.body.password).then( (user)=>
      req.session.userId = user._id

      @get('json').setIsUserAuthed true
      response = @get('json').render()
      res.json response
    )
    .fail (e)=>
      @get('json').setSuccess false
      @get('json').setIsUserAuthed false
      @get('json').addMessage e.toJson()
      response = @get('json').render()
      res.json response


  # Performs user logout. Replies with JSON in format of Core::Helpers::json
  #
  doLogout: (req, res)=>
    delete req.session.userId
    @get('json').setSuccess true
    @get('json').setIsUserAuthed false
    res.json( @get('json').render() )


#  createTestUser: ->
#    newUser =
#      firstName: "Peter"
#      lastName:  "Gering"
#      username:  "peter"
#      email:     "peter@example.com"
#      password:  "12345678"
#      tokens:    "12345678"
#    Model.instanceOf('user').save newUser, (e, r)-> console.log e, r




