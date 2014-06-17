###
500 (Server Error) Response

Usage:
return res.serverError();
return res.serverError(err);
return res.serverError(err, view);
return res.serverError(err, redirectTo);

NOTE:
If something throws in a policy or controller, or an internal
error is encountered, Sails will call `res.serverError()`
automatically.
###
module.exports = serverError = (err, viewOrRedirect) ->

  # Get access to `req` & `res`

  # Serve JSON (with optional JSONP support)
  sendJSON = (data) ->
    unless data
      res.send()
    else
      data = error: data  if typeof data isnt "object" or data instanceof Error
      if req.options.jsonp and not req.isSocket
        res.jsonp data
      else
        res.json data
  req = @req
  res = @res

  # Set status code
  res.status 500

  # Log error to console
  @req._sails.log.error "Sent 500 (\"Server Error\") response"
  @req._sails.log.error err  if err

  # Only include errors in response if application environment
  # is not set to 'production'.  In production, we shouldn't
  # send back any identifying information about errors.
  err = `undefined`  if @req._sails.config.environment is "production"

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
    res.view "500", locals, viewReady = (viewErr, html) ->
      if viewErr
        sendJSON err
      else
        res.send html
