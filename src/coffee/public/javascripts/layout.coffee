class Layout
  constructor: ->
    @init()

  init: ->
    @_findElements()
    @_attachEvents()

  _findElements: ->
    @_$logoutBtn = $('#logout')

  _attachEvents: ->
    @_attachLogoutBtnClick()

  _attachLogoutBtnClick: ->
    @_$logoutBtn.click (event)->
      helpers.ajax.post
        url: 'session/logout'
        cbSuccess: (response)->
          location.reload()

$(document).ready ->
  new Layout