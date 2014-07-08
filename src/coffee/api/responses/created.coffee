###
201 (CREATED) Response

Usage:
return res.created();
return res.created(data);
return res.created(data, view);
return res.created(data, redirectTo);
return res.created(data, true);

@param  {Object} data
@param  {Boolean|String} viewOrRedirect
[optional]
- pass string to render specified view
- pass string with leading slash or http:// or https:// to do redirect
###
module.exports = sendCreated = (data, viewOrRedirect) ->

  console.log "created!"
  # Get access to `req` & `res`

  # Serve JSON (with optional JSONP support)
  sendJSON = (data) ->
    if req.options.jsonp and not req.isSocket
      res.jsonp data # new Responses::SuccessJson data
    else
      res.json data # new Responses::SuccessJson data

  req = @req
  res = @res

  # Set status code
  res.status 201

  # Log error to console
  @req._sails.log.verbose "Sent 201 (\"Created\") response"
  @req._sails.log.verbose data  if data

  # Serve JSON (with optional JSONP support)
  return sendJSON(data)  if req.wantsJSON

  # Make data more readable for view locals
  locals = undefined
  if not data or typeof data isnt "object"
    locals = {}
  else
    locals = data

  # Serve HTML view or redirect to specified URL
  if typeof viewOrRedirect is "string"
    if viewOrRedirect.match(/^(\/|http:\/\/|https:\/\/)/)
      res.redirect viewOrRedirect
    else
      res.view viewOrRedirect, locals, viewReady = (viewErr, html) ->
        if viewErr
          sendJSON data
        else
          res.send html

  else
    res.view locals, viewReady = (viewErr, html) ->
      if viewErr
        sendJSON data
      else
        res.send html
