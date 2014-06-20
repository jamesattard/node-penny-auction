###
200 (OK) Response

Usage:
return res.ok();
return res.ok(data);
return res.ok(data, view);
return res.ok(data, redirectTo);
return res.ok(data, true);

@param  {Object} data
@param  {Boolean|String} viewOrRedirect
[optional]
- pass string to render specified view
- pass string with leading slash or http:// or https:// to do redirect
###
module.exports = sendOK = (data, viewOrRedirect) ->

  # Get access to `req` & `res`

  # Serve JSON (with optional JSONP support)
  sendJSON = (data) ->
#    unless data
#      res.send()
#    else
#      return res.send(data)  if typeof data isnt "object"
#      if req.options.jsonp and not req.isSocket
#        res.jsonp data
#      else
#        res.json data

    if req.options.jsonp and not req.isSocket
      res.jsonp data # new Responses::SuccessJson data
    else
      res.json data # new Responses::SuccessJson data

  req = @req
  res = @res

  # Set status code
  res.status 200

  # Log error to console
  @req._sails.log.verbose "Sent 200 (\"OK\") response"
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
