http = require 'http'
https = require 'https'
events = require 'events'

module.exports = class AllegroRepoConnection
  
  constructor: ( opts ) ->
    @o = 
      host: 'localhost'
      port: 10035
      relative_url: 'repositories/foo'
      username: 'dba'
      password: 'dba'
    @o[k] = v for own k, v of opts
    # TODO: check params
    @_common_headers =
      Authorization: 'Basic ' + new Buffer(@o.username + ':' + @o.password).toString 'base64'
      Host: @o.host + ':' + @o.port
  
  get_size : ( cb ) ->
    client = http.createClient @o.port, @o.host
    request = client.request 'GET', "/#{@o.relative_url}/size", @_common_headers
    request.end()
    request.on 'response', (response) ->
      if response.statusCode isnt 200
        cb 'error', null
      response.setEncoding 'utf8'
      response.on 'data', (chunk) ->
        cb null, Number chunk
  
  # http://www.franz.com/agraph/allegrograph/doc/http-protocol.html#header2-329
  
  test_load : ->
    # POST /repositories/scratch/statements?url=[URL]&context=%22B%22
    client = http.createClient @o.port, @o.host
    headers =
      'Content-Type': 'text/turtle'
    headers[k] = v for own k, v of @_common_headers
    console.log headers
    request = client.request 'POST', "/#{@o.relative_url}/statements", headers
    request.write ttl
    #request.write '<http://foo.com/aldo> <http://foo.com/name> "Aldo" .'
    request.end()
    request.on 'response', (response) ->
      console.log response
      response.setEncoding 'utf8'
      response.on 'data', (chunk) ->
        console.log chunk

test = ->
  repo = new AllegroRepoConnection
  repo.test_load()
  # repo.get_size ( err, size ) -> console.log [err, size]



test()




###
curl -H "Accept: text/turtle" -X GET "https://graph.facebook.com/110245245672332?metadata=1&access_token=AAAAAAITEghMBAFpSJ9zgjZBmF0ZCTZCjyF0ohvMIIY0qeGZCFSQF6zvUU9iy3RAdsbZBN9FsG68F7H6A4o0NraMbKvJj1JwgrShzvs0uT2gZDZD"
###
