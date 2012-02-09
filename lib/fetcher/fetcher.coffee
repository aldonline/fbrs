sparql = require 'sparql'
util = require 'util'
mkdirp = require 'mkdirp'
querystring = require 'querystring'
https = require 'https'
fs = require 'fs'
isql = require 'virtuoso-isql-wrapper'
zlib = require 'zlib'

ttlp = require '../virtuoso/ttlp_mt_local_file'
config = require '../config'

FOLDER = config.TEMP_FOLDER

# this is where we store temp TTL files
mkdirp FOLDER, 0755

exports.fetch = fetch = ( opts, cb ) ->
  console.log 'fetching ' + opts.local_name
  o =
    isql_client: null
    access_token: null
    local_name: null # 4732978439743/friends
    etag: null # TODO: if etag is passed, then we will query the remote facebook server with this etag
    delete_file: yes # TODO
  o[k] = v for own k, v of opts
  # TODO: check params
  path = FOLDER + '/' + ( new Date ).getTime() + '.ttl'
  url = 'https://graph.facebook.com/' + o.local_name
  fetch_ttl_and_write_to_file o.access_token, path, o.local_name, {}, ( err ) ->
    return cb err if err?
    console.log 'fetched ' + opts.local_name + ' --> ' + path
    o.isql_client.exec "fbrs_reload_graph('#{path}', '#{url}')", ( err, res ) ->
      # TODO: run client side inference rules
      
      console.log 'inserted ' + opts.local_name
      cb?()

fetch_ttl_and_write_to_file = ( access_token, path_to_ttl, local_name, params, cb ) ->
  p =
    access_token : access_token
  p[k] = v for own k, v of params
  options =
    host: 'graph.facebook.com'
    path: '/' + local_name + '&' + querystring.stringify p
    method: 'GET'
    headers:
      Accept: 'text/turtle'
      'Accept-Encoding': 'gzip'
  console.log options
  req = https.request options, ( res ) ->
    output_stream = fs.createWriteStream path_to_ttl
    if res.headers['content-encoding'] is 'gzip'
      res.pipe(  zlib.createGunzip() ).pipe output_stream
    else
      res.setEncoding 'utf8'
      util.pump res, output_stream
    res.on 'end', ->
      cb()
  req.on 'error', (e) -> cb e
  req.end()

