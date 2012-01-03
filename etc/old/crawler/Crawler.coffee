fs = require 'fs'
util = require 'util'
https = require 'https'
mkdirp = require 'mkdirp'
events = require 'events'
zlib = require 'zlib'

fb_util = require '../util'

###
downloads all friend TTLs in bulk and in parallel
and stores the resulting TTL files on the specified path
###

module.exports = class Crawler extends events.EventEmitter
  constructor: ( options ) ->
    self = @
    o =
      path: null # path where to store files
      access_token: null
      user_id: '/me' # defaults to /me
      clean_dir: no
      batch_size: 45 # amount of ids to fetch at the same time
    o[k] = v for own k, v of options
    unless o.path?
      throw 'options.path is required. this is where we store the resulting TTL files'
    unless o.access_token?
      throw 'options.access_token is required'
    mkdirp o.path, 0755
    # TODO:
    # if o.clean_dir
    get_friends_array o.access_token, o.user_id, (err, friends) ->
      throw err if err?
      ids = ( friend.id for friend in friends )
      num_files = Math.ceil ids.length / o.batch_size
      num_files += 1 # index is also considered
      self.emit 'start', num_files
      # create first TTL in which we will mark all these IDs
      # as our friends
      ttl = '@prefix x: <http://divetouch.com/ns/x/> . '
      ttl += '</me#> x:friend '
      ttl += ( '</'+id+'#>' for id in ids ).join ' , '
      ttl += ' . '
      filename = o.path + '/index.ttl'
      fs.writeFile filename, ttl, 'utf8', (err) ->
        self.emit 'file', filename
        # create batches of IDs
        batches = fb_util.split_array ids, o.batch_size
        # NOTE: during dev reduce this array to two elements
        # batches = batches.splice 0, 2
        pending = len = batches.length
        for i in [0...len]
          (( i ) ->
            f = o.path + "/friends_#{i}.ttl"
            fetch_ttl_for_ids_and_write_to_file o.access_token, f, batches[i], (err) ->
              self.emit 'file', f
              self.emit 'end' if --pending is 0
          ) i

fetch_ttl_for_ids_and_write_to_file = ( access_token, path, ids, cb ) ->
  options =
    host: 'graph.facebook.com'
    path: '/?ids=' + ids.join(',') + '&access_token=' + access_token
    method: 'GET'
    headers:
      Accept: 'text/turtle'
      'Accept-Encoding': 'gzip'
  req = https.request options, ( res ) ->
    output_stream = fs.createWriteStream path
    if res.headers['content-encoding'] is 'gzip'
      res.pipe(  zlib.createGunzip() ).pipe output_stream
    else
      res.setEncoding 'utf8'
      util.pump res, output_stream
    res.on 'end', ->
      cb()
  req.on 'error', (e) -> cb e
  req.end()

###
{ 'access-control-allow-origin': '*',
     'cache-control': 'private, no-cache, no-store, must-revalidate',
     'content-type': 'text/turtle;charset=utf-8',
     etag: '"d0ad7fac814c459537f8b7acfbee5bf7b7750ed7"',
     expires: 'Sat, 01 Jan 2000 00:00:00 GMT',
     'last-modified': '2011-12-12T14:22:45+0000',
     pragma: 'no-cache',
     'x-fb-rev': '489759',
     'x-fb-server': '10.36.55.122',
     'x-cnection': 'close',
     date: 'Mon, 26 Dec 2011 19:59:19 GMT',
     'content-length': '59504' },
  
     'content-encoding': 'gzip'
###


get_friends_array = ( access_token, user_id, cb ) ->
  unless typeof user_id is 'string' and user_id isnt ''
    throw "You must pass a user_id!"
  q = method: 'GET', relative_url: "#{user_id}/friends"
  fb_util.batch_graph_request access_token, [q], ( err, result ) ->
    return cb err if err?
    result = JSON.parse result[0].body
    cb null, result.data

###
get_all_friends_batch = ->
  batch = []
  batch.push
    method: 'GET'
    name: 'get-friends'
    relative_url: "me/friends?limit=100"
    #headers:
    #  Accept: 'text/turtle'
  batch.push
    method: 'GET'
    # name: 'get-friends'
    relative_url: "?ids={result=get-friends:$.data.*.id}"
    #relative_url: "me/friends?limit=4"
    headers:
      Accept: 'text/turtle'
  fb_util.batch_graph_request access_token, batch, ( err, result ) ->
    console.log result

test1 = ->
  ids = [204987, 207660, 207923]
  options =
    host: 'graph.facebook.com'
    path: '/?ids=' + ids + '&access_token=' + TOKEN
    method: 'GET'
    headers:
      Accept: 'text/turtle'
  req = https.request options, ( res ) ->
    #console.log "statusCode: ", res.statusCode
    console.log "headers: ", res.headers
    res.setEncoding 'utf8'
    res.on 'data', (d) ->
      console.log d
    ws = fs.createWriteStream '/tmp/sample.ttl'
    util.pump res, ws
  req.on 'error', (e) ->
    console.error e
  req.end()
###

