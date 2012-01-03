
###
FBRS_SPARQL_ENDPOINT="http://localhost:8890/sparql"
FBRS_VIRTUOSO_PORT=1111
FBRS_VIRTUOSO_USERNAME="dba"
FBRS_VIRTUOSO_PASSWORD="dba"
FBRS_PORT=3008
FBRS_ACCESS_TOKEN=...
FBRS_TEMP_FOLDER="/tmp/facebook-rdf-sync"
###

env = process.env

module.exports =
  SPARQL_ENDPOINT:    env.FBRS_SPARQL_ENDPOINT or 'http://localhost:8890/sparql'
  VIRTUOSO_PORT:      Number env.FBRS_VIRTUOSO_PORT or 1111
  VIRTUOSO_USERNAME:  env.FBRS_VIRTUOSO_USERNAME or 'dba'
  VIRTUOSO_PASSWORD:  env.FBRS_VIRTUOSO_PASSWORD or 'dba'
  PORT:               Number env.FBRS_PORT or 3008
  ACCESS_TOKEN:       env.FBRS_ACCESS_TOKEN
  TEMP_FOLDER:        env.FBRS_TEMP_FOLDER or '/tmp/fbrs_' + (new Date).getTime()