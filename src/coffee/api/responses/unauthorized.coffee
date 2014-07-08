###
403 (Forbidden) Handler

Usage:
return res.forbidden();
return res.forbidden(err);
return res.forbidden(err, view);
return res.forbidden(err, redirectTo);

e.g.:
```
return res.forbidden('Access denied.');
```
###
module.exports = unauthorized = (err, viewOrRedirect) ->

  # Get access to `req` & `res`

  # Serve JSON (with optional JSONP support)
  sendJSON = (data) ->
    if req.options.jsonp and not req.isSocket
      res.jsonp new Responses::ErrorJson data
    else
      res.json new Responses::ErrorJson data
      
#    unless data
#      res.send()
#    else
#      data = error: data  if typeof data isnt "object" or data instanceof Error
#      if req.options.jsonp and not req.isSocket
#        res.jsonp data
#      else
#        res.json data
  req = @req
  res = @res

  # Set status code
  res.status 401

  # Log error to console
  @req._sails.log.verbose "Sent 401 (\"Unauthorized\") response"
  @req._sails.log.verbose err  if err

  # If the user-agent wants JSON, always respond with JSON
  return sendJSON(err)  if req.wantsJSON

  # Make data more readable for view locals
  locals = undefined
  unless err
    locals = {}
  else if typeof err isnt "object"
    locals = error: err
  else
    readabilify = (value) ->
      if sails.util.isArray(value)
        sails.util.map value, readabilify
      else if sails.util.isPlainObject(value)
        sails.util.inspect value
      else
        value

    locals = error: readabilify(err)

  # Serve HTML view or redirect to specified URL
  if typeof viewOrRedirect is "string"
    if viewOrRedirect.match(/^(\/|http:\/\/|https:\/\/)/)
      res.redirect viewOrRedirect
    else
      res.view viewOrRedirect, locals, viewReady = (viewErr, html) ->
        if viewErr
          sendJSON err
        else
          res.send html

  else
    res.view "403", locals, viewReady = (viewErr, html) ->
      if viewErr
        sendJSON err
      else
        res.send html
