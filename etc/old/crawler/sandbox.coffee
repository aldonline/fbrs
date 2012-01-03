Crawler = require './Crawler'

config = require '../config'

o =
  path: '/tmp/friendsbatch'
  access_token: config.ACCESS_TOKEN
  user_id: '/me'

f = new Crawler o
f.on 'start', ( count ) -> console.log ['start', count]
f.on 'file', ( file ) -> console.log ['file', file]
f.on 'end', -> console.log ['end']
f.on 'error', (e) -> throw e