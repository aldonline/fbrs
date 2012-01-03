https = require 'https'
querystring = require 'querystring'

# http://developers.facebook.com/docs/reference/api/batch/
# http://stackoverflow.com/questions/6158933/http-post-request-in-node-js

exports.batch_graph_request = ( access_token, batch, cb ) ->
  body =
    access_token: access_token
    batch: JSON.stringify batch
  body_str = querystring.stringify body
  options =
    host: 'graph.facebook.com'
    path: '/'
    method: 'POST'
    headers:
      'Content-Type' : 'application/x-www-form-urlencoded'
      'Content-Length': body_str.length
  req = https.request options, ( res ) ->
    # console.log "statusCode: ", res.statusCode
    # console.log "headers: ", res.headers
    res.setEncoding 'utf8'
    data = ''
    res.on 'data', (d) -> data += d
    res.on 'end', -> cb null, JSON.parse data
  req.on 'error', (e) ->
    # TODO: bubble error
    console.error e
  req.write body_str
  req.end()

# performs a simple Graph API call to see if token is valid
# callback = ( err, is_valid ) -> ...
# if there is an http error, then err won't be null
exports.test_access_token = ( access_token, cb ) ->
  # cheap checks first
  unless access_token?
    process.nextTick ( -> cb null, no )
    return
  options =
    host: 'graph.facebook.com'
    path: '/me&access_token=' + access_token
    method: 'GET'
  req = https.request options, ( res ) ->
    data = ''
    res.setEncoding 'utf8'
    res.on 'data', (chunk) -> data += chunk
    res.on 'end', ->
      data = JSON.parse data
      if data.error?
        cb null, no
      else
        cb null, yes
  req.on 'error', (http_error) -> cb http_error
  req.end()


exports.split_array = ( arr, size = 10 ) ->
  len = arr.length
  res = []
  curr = null
  for i in [0...len]
    if i % size is 0
      res.push curr = []
    curr.push arr[i]
  res