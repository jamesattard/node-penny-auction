
FrontendController = require('./base/frontend').FrontendController
Model = require('../../core/models').Model

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


  doLogin: (req, res)=>
#    newUser =
#      firstName: "Peter"
#      lastName:  "Gering"
#      username:  "peter"
#      email:     "peter@example.com"
#      password:  "12345678"
#      tokens:    "12345678"
#    Model.instanceOf('user').save newUser, (e, r)-> console.log e, r
#    #get view name here since the _getViewName uses function-caller's name to build view name
    Model.instanceOf('user').login(req.body.email, req.body.password).then( (user)=>
      req.session.userId = user._id

      @get('json').setIsUserAuthed true
      response = @get('json').render()
      res.json response
    )
    .fail (e)->
      console.log e.toJson()
      @get('json').setSuccess false
      @get('json').setIsUserAuthed false
      @get('json').addMessage e.toJson()
      response = @get('json').render()
      res.json response


  doLogout: (req, res)=>
    delete req.session.userId
    @get('json').setSuccess true
    @get('json').setIsUserAuthed false
    res.json( @get('json').render() )





