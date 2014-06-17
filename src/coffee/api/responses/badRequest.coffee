###
400 (Bad Request) Handler

Usage:
return res.badRequest();
return res.badRequest(err);
return res.badRequest(err, view);
return res.badRequest(err, redirectTo);

e.g.:
```
return res.badRequest(
'Please choose a valid `password` (6-12 characters)',
'/trial/signup'
);
```
###
module.exports = badRequest = (err, viewOrRedirect) ->

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
  res.status 400

  # Log error to console
  @req._sails.log.verbose "Sent 400 (\"Bad Request\") response"
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
    res.view "400", locals, viewReady = (viewErr, html) ->
      if viewErr
        sendJSON err
      else
        res.send html
