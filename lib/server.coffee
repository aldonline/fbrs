express = require 'express'
markdown = require 'markdown'
sparql = require 'sparql'
isql = require 'virtuoso-isql-wrapper'
util = require 'util'

prefixes = require './prefixes'
fetch_empty = require './arcaya/fetch_empty'
config = require './config'

server = express.createServer()

isql_client = new isql.Client
  port: config.VIRTUOSO_PORT
  usr: config.VIRTUOSO_USERNAME
  pwd: config.VIRTUOSO_PASSWORD

sparql_client = new sparql.Client config.SPARQL_ENDPOINT

md = ( str ) -> markdown.markdown.toHTML str

get_home_html = ( cb ) ->
  get_registry_table ( reg_table ) ->
    home_md = """
# Facebook RDF Sync

This is a Node application that keeps an RDF store in sync
with a Subgraph from the Facebook Graph API.

## Parameters

The following configuration is being used:

* REST API Port: #{config.PORT}
* Callback interface ( for real time updates ): #{config.CALLBACK_PORT}
* Graph Store Type: Virtuoso
* SPARQL endpoint: #{config.SPARQL_ENDPOINT}
* 

## Links

## Registry
    """
    cb? md(home_md) + reg_table


get_registry_table = ( cb ) ->
  query = """
  select distinct
    ?id
    ?state
  from fbrs:registry
  where {
    ?doc
      a fbrs:Document ;
      fbrs:id ?id ;
      fbrs:state ?state
  } order by asc(?state)
  """
  sparql_client.rows query, ( err, rows ) ->
    cells = []
    for row in rows
      cells.push [row.id.value, row.state.value]
    
    html = ['<table>']
    for cell in cells
      html.push '<tr><td>' + cell.join('</td><td>') + '</td></tr>'
    html.push '</table>'
    cb? html.join '\n'

server.get '/', ( req, res ) ->
  get_home_html ( html ) ->
    res.send html

server.get '/add_to_queue', ( req, res ) ->
  id = req.query.id
  unless id?
    res.send 'You must pass a document ID as query string parameter--> ?id=4324324'
  else
    isql_client.exec "fbrs_queue_document('#{id}')", (err2, res2) ->
      res.send util.inspect [err2, res2], no, 5

server.get '/fetch_empty', ( req, res ) ->
  o =
    auth_token: config.ACCESS_TOKEN
    isql_client: isql_client
    sparql_client: sparql_client
  fetch_empty o, ( err ) ->
    console.log 'ready'
    res.send 'ready'


# TODO: create public server ( callback url for facebook real time updates )
# TODO: pick port from node env variable
server.listen config.PORT
console.log 'private REST API interface listening on port ' + config.PORT