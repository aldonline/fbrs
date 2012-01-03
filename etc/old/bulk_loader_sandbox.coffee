isql = require 'virtuoso-isql-wrapper'
sparql = require 'sparql'

bl = require './bulk_loader'
config = require './config'

isql_client = new isql.Client
  port: config.VIRTUOSO_PORT
  usr: config.VIRTUOSO_USERNAME
  pwd: config.VIRTUOSO_PASSWORD

sparql_client = new sparql.Client config.SPARQL_ENDPOINT

bl.reload
  access_token: config.ACCESS_TOKEN
  isql_client: isql_client
  verbose: yes