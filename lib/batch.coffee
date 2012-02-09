FBRS = require './FBRS'
config = require './config'
util = require 'util'

USER_ID = 545415493

console.log 'running in batch mode'
console.log 'with the following config'
console.log util.inspect config, no, 3

fbrs = new FBRS
  access_token:       'AAAAAAITEghMBABbvOcY9UAwXu1qX0TH2JoNBPOcZCZBgC9KwZAvcZAGsJs1FybOyZBaQGNEPpTYvB11EZBiyEo399RBnqNdKryIsUKt3nWqgZDZD'
  virtuoso_port:      config.VIRTUOSO_PORT
  virtuoso_username:  config.VIRTUOSO_USERNAME
  virtuoso_password:  config.VIRTUOSO_PASSWORD
  sparql_endpoint:    config.SPARQL_ENDPOINT

###
This is a simple script that loads the immediate neighborhood of a user.
###

fbrs.get_connection ( err, conn ) ->
  throw err if err?
  conn.initialize_triple_store ->
    conn.queue_document USER_ID + '/friends', ->
      conn.dequeue ->
        conn.queue_all_ids ->
          conn.dequeue ->
            console.log 'done!'
