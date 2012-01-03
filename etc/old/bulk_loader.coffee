ttlp_mt_local_file = require './virtuoso/ttlp_mt_local_file'
Crawler = require './crawler/Crawler'
fbutil = require './util'
util = require 'util'

DEFAULT_STORAGE = '/tmp/divetouch/facebook/friends'
DEFAULT_GRAPH = 'urn:divetouch:graph:facebook:friends'

# cleans, fetches and reloads the facebook friends graph
# it operates via isql ( writes TTL files on disk and then loads them via ttlp_mt )

exports.reload = reload = (opts, cb) ->
  o =
    storage: DEFAULT_STORAGE
    graph: DEFAULT_GRAPH
    access_token: null
    isql_client: null
    verbose: no
  o[k] = v for own k, v of opts
  if o.verbose
    console.log 'started bulk load with options'
    console.log util.inspect o, no, 5
  isql_client = o.isql_client
  clean_everything = ( cb ) ->
    isql_client.exec "sparql clear graph <#{o.graph}> ;", cb
  fetch_and_load = ( cb ) ->
    crawler = new Crawler
      path: o.storage
      access_token: o.access_token
    num_files_fetched = 0
    num_files_loaded = 0
    num_files = undefined
    crawler.on 'start', (n) ->
      console.log "started. numfiles = #{n}" if o.verbose
      num_files = n
    crawler.on 'file', ( filename ) ->
      if o.verbose
        console.log 'fetched: ' + ++num_files_fetched
      o =
        isql_client : isql_client
        graph: o.graph
        path: filename
        base: 'http://graph.facebook.com/'
        flags: 128
      ttlp_mt_local_file o, ( err, res ) ->
        throw err if err?
        if o.verbose
          console.log 'loaded: ' + ++num_files_loaded
        if num_files_loaded is num_files
          console.log 'done!'
          cb()
  # runs some cleaning queries and materializes inference rules
  post_process: ( cb ) ->
    process.nextTick cb
    
  run = -> clean_everything -> fetch_and_load -> post_process -> cb?()
  
  fbutil.test_access_token o.access_token, ( err, is_valid ) ->
    if is_valid isnt yes
      cb 'Invalid Facebook Access Token'
    else
      run()



