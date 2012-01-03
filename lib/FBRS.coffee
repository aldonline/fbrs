isql = require 'virtuoso-isql-wrapper'
sparql = require 'sparql'
util = require 'util'
path = require 'path'

config = require './config'
fetch_empty = require './fetcher/fetch_empty'
fbutil = require './util'


class FBRSConnection
  constructor: ( @parent ) ->
  
  # installs stored procedures and server side components
  initialize_triple_store: ( cb ) ->
    sql_file_path = path.join __dirname, '..', 'setup_virtuoso.sql'
    @parent.isql.load sql_file_path, ( err, res ) ->
      throw util.inspect(err) if err?
      cb err, res
  
  # adds document to the queue
  # example: queue_document '849320483/friends'
  queue_document : ( local_name, cb ) ->
    @parent.isql.exec "fbrs_queue_document( '#{local_name}' )", ( err, res ) ->
      throw err if err?
      cb?()
  
  # queues all occuring IDs
  queue_all_ids : ( cb ) ->
    @parent.isql.exec 'fbrs_queue_all_ids()', ( err, res ) ->
      cb?()
  
  # starts dequeueing ( fetching ) each document on the queue
  dequeue : ( cb ) ->
    o =
      access_token:   @parent.o.access_token
      isql_client:    @parent.isql
      sparql_client:  @parent.sparql
    fetch_empty o, ( err ) ->
      throw err if err?
      cb?()


module.exports = class FBRS
  
  constructor: ( opts ) ->
    @o =
      access_token:       null
      virtuoso_port:      1111
      virtuoso_username:  'dba'
      virtuoso_password:  'dba'
      sparql_endpoint:    'http://localhost:8890/sparql'
    
    @o[k] = v for own k, v of opts
    
    # TODO: param checking
    
    # create clients
    @sparql = new sparql.Client @o.sparql_endpoint
    @isql = new isql.Client
      usr:    @o.virtuoso_username
      psd:    @o.virtuoso_password
      port:   @o.virtuoso_port
  
  # checks to see whether provided access token is valid
  test_access_token: ( cb ) ->
    fbutil.test_access_token @o.access_token, cb
  
  # tests all connections: Facebook + triple store ( SPARQL ) + triple store ( native )
  test_remote_access : ( cb ) ->
    # TODO

  # : ( err, connection )
  # this may fail if the connection to the triple store or to facebook is broken
  get_connection: ( skip_remote_access_test, cb ) ->
    self = @
    if typeof skip_remote_access_test is 'function'
      cb = skip_remote_access_test
      skip_remote_access_test = no
    send_result = -> cb null, new FBRSConnection self
    if skip_remote_access_test
      process.nextTick send_result
    else
      @test_access_token ( err, is_valid ) ->
        if is_valid
          send_result()
        else
          cb 'token is not valid'

