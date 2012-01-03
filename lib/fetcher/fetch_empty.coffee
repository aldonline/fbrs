fetcher = require './fetcher'

###
will start fetching every document whose fbrs:state is empty ( 0 )
###

module.exports = fetch_empty = ( opts, cb ) ->
  o =
    access_token: null
    isql_client: null
    sparql_client: null
  o[k] = v for own k, v of opts
  query = '''
  select
    distinct ?doc 
  from fbrs:registry
  where {
    ?doc
      a fbrs:Document ;
      fbrs:state 0
    .
    optional {
     ?doc
      fbrs:priority ?priority ;
      fbrs:etag ?etag
    }
    .
  } order by asc(?priority)
  '''
  o.sparql_client.rows query, ( err, rows ) ->
    console.log "will fetch #{rows.length} empty documents"
    process_row = ( row ) ->
      url = row.doc.value
      o =
        local_name : url.substring 'https://graph.facebook.com/'.length
        access_token: o.access_token
        isql_client: o.isql_client
      fetcher.fetch o, ( err, res ) ->
        cb? err
    process_row row for row in rows