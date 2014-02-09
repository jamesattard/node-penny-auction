#
# GET users listing.
#

class UserController extends  CoreController

  login: (req, res, next)=>
    app = @get('app')
    app.get('passport').authenticate("local", (err, isAuthenticated, info) ->
      console.log isAuthenticated, info
      if isAuthenticated
        req.session.user = info
        Helper.json.setIsUserAuthed true
        Helper.json.addMessage "success", "Logged in"
      else
        Helper.json.setSuccess false
        Helper.json.setIsUserAuthed false
        Helper.json.addMessage "error", info
      res.json( Helper.json.render() )

    ) req, res, next

  logout: (req, res, next)=>
    delete req.session.user
    Helper.json.setSuccess true
    Helper.json.setIsUserAuthed false
    res.json( Helper.json.render() )

  register: (req, res)->
    Model.instanceOf('user').save req.body, (isError, exception)->
      console.log isError, exception, exception?.toJson()

      if isError
        Helper.json.setSuccess false
        Helper.json.addMessage exception.toJson()
      else
        Helper.json.addMessage "success", "You have been registered"

      response = Helper.json.render()
      res.json(response)

  # Updates existing or adds new category for logged user
  #
  saveCategory: (req, res)->
    # @todo: handle req.session.user existence

    loggedUserId = req.session.user._id
    Model.instanceOf('user').saveCategory loggedUserId, req.body, (err, exception)->
      unless err
        Model.instanceOf('user').getById loggedUserId, (err, result)->
          unless err
            Helper.json.addData 'categories', result.linkCategories
            Helper.json.addMessage "success", "Saved!"
          else
            Helper.json.setSuccess(no)
            Helper.json.addMessage "error", "Unable to get user"
          jsonResponse = Helper.json.render()
          console.log jsonResponse
          res.json( jsonResponse )
      else
        Helper.json.setSuccess(no)
        Helper.json.addMessage  exception.toJson()
        res.json( Helper.json.render() )

  deleteCategory: (req, res)->
    loggedUserId  = req.session.user._id
    categoryData  = req.body
    Model.instanceOf('link').countByCategoryId loggedUserId, categoryData.index, (err, cnt)->
      unless err
        if parseInt(cnt) is 0
          Model.instanceOf('user').deleteCategory loggedUserId, categoryData, (err, result)->
            console.log 'err is null', (err is null), err, result
            if err is null
              Helper.json.addData 'categories', result
              Helper.json.addMessage "success", "Deleted!"
            else
              Helper.json.setSuccess(no)
              Helper.json.addMessage  "error", "Unable to delete category"
            res.json( Helper.json.render() )
        else
          Helper.json.setSuccess(no)
            .addMessage("error", "Unable to delete this categoty because there are links which are reffered to it")
          res.json( Helper.json.render() )
      else
        Helper.json.setSuccess(no)
          .addMessage("error", "Unexpected error [45]")
        res.json( Helper.json.render() )



  getLogged: (req, res)->
    if req.session.user
      Model.instanceOf('user').getById req.session.user._id, (err, result)->
        unless err
          user = result
        else
          user = null
        Helper.json.addData 'user', user
        res.json( Helper.json.render() )
    else
      user = null
      Helper.json.addData 'user', user
      res.json( Helper.json.render() )


  # login with social networks
  #
  # @limitation: Redirects to Facebook login page so it is'nt supposed to be requested over AJAX
  #
#  socialLogin: (req, res)=>
#    app = @get('app')
#    app.get('passport').authenticate('facebook')

  facebookCallback: (req, res, next)=>
    app = @get('app')
    app.get('passport').authenticate('facebook', (err, user) ->
      console.log user._json.first_name, user._json.last_name, user._json.email
      userDataToBeSaved =
        firstName:            user._json.first_name
        lastName:             user._json.last_name
        email:                user._json.email
        password:             ''
        provider:             'facebook'
        socialData:           user._json

      Model.instanceOf('user').findByEmailOrCreate userDataToBeSaved, (isError, info)->
        isAuthed = no
        if isError
          Helper.json.setSuccess false
          Helper.json.setIsUserAuthed false
          Helper.json.addMessage info.toJson()
        else
          Helper.json.setIsUserAuthed true
          Helper.json.addMessage "success", "You have been logged in"
          Helper.json.addData 'info', info
          req.session.user = info
          isAuthed = yes

#        response = Helper.json.render()
#        res.json(response)
        res.render 'user/facebook-callback',
          isAuthed: isAuthed
    )(req, res, next)


  changeLanguage: (req, res, next)->
    Model.instanceOf('user').saveLanguage req.session.user._id, req.body.langId, (err, details)->
      unless err
        #
      else
        Helper.json.setSuccess(false)
        Helper.json.addMessage details.toJson()
      res.json( Helper.json.render() )

exports.userController = new UserController





# @todo: remove all the code below

exports.list = (req, res)->
  res.send "respond with a resource"

exports.register = (req, res)->
#  console.log req.param('email')
    Model.instanceOf('user').save req.body, (isError, exception)->
      console.log isError, exception, exception?.toJson()

      if isError
        Helper.json.setSuccess false
        Helper.json.addMessage exception.toJson()
      else
        Helper.json.addMessage "success", "You have been registered"

      response = Helper.json.render()
      res.json(response)


exports.login  = (req, res)->
  email     = req.param('email')
  password  = req.param('password')
  Model.instanceOf('user').login email, password, (user)->
    console.log 'user', user
    if user
      req.session.user = user
      Helper.json.addMessage "success", "Logged in"
    else
      Helper.json.setSuccess false
      Helper.json.addMessage 'error', 'Incorrect login or password'

    res.json( Helper.json.render() )


# Updates existing or adds new category for logged user
#
exports.saveCategory = (req, res)->
  # @todo: handle req.session.user existence

  loggedUserId = req.session.user._id
  Model.instanceOf('user').saveCategory loggedUserId, req.body, (err, objectsAffected)->
    unless err
      Model.instanceOf('user').getById loggedUserId, (err, result)->
        unless err
          Helper.json.addData 'categories', result.linkCategories
          Helper.json.addMessage "success", "Saved!"
        else
          Helper.json.setSuccess(no)
          Helper.json.addMessage "error", "Unable to get user"
        jsonResponse = Helper.json.render()
        console.log jsonResponse
        res.json( jsonResponse )
    else
      Helper.json.setSuccess(no)
      Helper.json.addMessage  "error", "Unable to save category"
      res.json( Helper.json.render() )



exports.deleteCategory = (req, res)->
  loggedUserId = req.session.user._id
  Model.instanceOf('user').deleteCategory loggedUserId, req.body, (err, result)->
    console.log err, result
    unless err
      Helper.json.addData 'categories', result
      Helper.json.addMessage "success", "Deleted!"
    else
      Helper.json.setSuccess(no)
      Helper.json.addMessage  "error", "Unable to delete category"
    res.json( Helper.json.render() )

exports.getLogged = (req, res)->
  if req.session.user
    Model.instanceOf('user').getById req.session.user._id, (err, result)->
      unless err
        user = result
      else
        user = null
      Helper.json.addData 'user', user
      res.json( Helper.json.render() )
  else
    user = null
    Helper.json.addData 'user', user
    res.json( Helper.json.render() )