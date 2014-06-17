###
404 (Not Found) Handler

Usage:
return res.notFound();
return res.notFound(err);
return res.notFound(err, view);
return res.notFound(err, redirectTo);

e.g.:
```
return res.notFound();
```

NOTE:
If a request doesn't match any explicit routes (i.e. `config/routes.js`)
or route blueprints (i.e. "shadow routes", Sails will call `res.notFound()`
automatically.
###
module.exports = notFound = (err, viewOrRedirect) ->

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
  res.status 404

  # Log error to console
  @req._sails.log.verbose "Sent 404 (\"Not Found\") response"
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
    res.view "404", locals, viewReady = (viewErr, html) ->
      if viewErr
        sendJSON err
      else
        res.send html
