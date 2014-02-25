class UserSession
  constructor: ->
    @init()

  init: ->
    @_findElements()
    @_attachFormValidation()

    $(".js-login").fancybox
      maxWidth	: 400,
      maxHeight	: 300,
      fitToView	: false,
      width		: '70%',
      height		: '110px',
      autoSize	: false,
      closeClick	: false,
      openEffect	: 'none',
      closeEffect	: 'none'


  _findElements: ->
    @_$loginForm = $('form#login-form')

  _attachFormValidation: ->
    @_$loginForm.validate
      rules:
        email:
          required: yes
          email: yes
        password:
          required: yes

      highlight: (label)->
        $(label).closest('.row').addClass('error').find('.js-error-placement').hide()
      unhighlight: (label)->
        $(label).closest('.row').removeClass('error').find('.js-error-placement').hide()

      errorPlacement: (error, element)->
        $(element).closest('.row').find('.js-error-placement').show().attr 'title', $(error).text()

      submitHandler: =>
        helpers.ajax.post
          url:  'session/login'
          data:     @_$loginForm.serialize()
          targetEl: @_$loginForm
          cbSuccess: (response)->
            console.log response, response.success
            if response.success
              location.reload()
            else
              alert response.messages.error


$(document).ready ->
  new UserSession