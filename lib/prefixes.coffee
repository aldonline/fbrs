exports.map = map =
  # the following are the default, native FB prefixes
  'rdf:'    : '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>'
  'rdfs:'   : '<http://www.w3.org/2000/01/rdf-schema#>'
  'owl:'    : '<http://www.w3.org/2002/07/owl#>'
  'xsd:'    : '<http://www.w3.org/2001/XMLSchema#>'
  'api:'    : '<tag:graph.facebook.com,2011:/>'
  'og:'     : '<http://ogp.me/ns#>'
  'fb:'     : '<http://ogp.me/ns/fb#>'
  ':'       : '<http://graph.facebook.com/schema/~/>'
  'user:'   : '<http://graph.facebook.com/schema/user#>'
  'page:'   : '<http://graph.facebook.com/schema/page#>'

  # for internal stuff ( registry, documents, etc )
  'fbrs:'     : '<http://data.divetouch.com/fbrs#>'
  # for our custom predicates
  'fbx:'     : '<http://data.divetouch.com/fbx#>'

arr = ("prefix #{pfx} #{uri}" for own pfx, uri of map)
exports.for_sparql = arr.join '\n'
exports.for_ttl = ( "@#{line} ." for line in arr ).join '\n'