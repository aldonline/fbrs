isql = require 'virtuoso-isql-wrapper'

# http://docs.openlinksw.com/virtuoso/fn_ttlp_mt_local_file.html

# wrapper for TTLP_MT_LOCAL_FILE
module.exports = load_ttl = ( options, cb ) ->
  o =
    isql_client : null
    path: null # path to ttl file
    graph: null # destination graph ( plain URI )
    base: '' # base
    flags: 0
    log_mode: 2
    threads: 1
    clear_graph: no # whether to clear graph before loading
  o[k] = v for own k, v of options
  proc = 'DB.DBA.TTLP_MT_LOCAL_FILE'
  args = []
  args.push "'#{o.path}'"
  args.push if o.base? then "'#{o.base}'" else 'NULL'
  args.push if o.graph? then "'#{o.graph}'" else ''
  args.push if o.flags? then o.flags else 'NULL'
  args.push if o.log_mode? then o.log_mode else 'NULL'
  args.push if o.threads? then o.threads else 'NULL'  
  sql = proc + '( ' + args.join(' , ') + ' );'
  o.isql_client.exec sql, cb

exports.test = test = ->
  client = new isql.Client
    port: 1111
    # verbose: yes
  o =
    isql_client: client
    path: '/tmp/friendsbatch/index.ttl'
    graph: 'urn:friendsbatch:index'
    base: 'http://graph.facebook.com/'
    clear_graph: yes
  load_ttl o, ( err, res) ->
    if err?
      throw err.error
    else
      console.log 'Loaded OK'

###
sparql select * from <urn:friendsbatch:index> where { ?s ?p ?o };
sparql clear graph <urn:friendsbatch:index> ;
###