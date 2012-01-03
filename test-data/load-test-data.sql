sparql clear graph <https://graph.facebook.com/123> ;
sparql clear graph <https://graph.facebook.com/1234> ;
sparql clear graph <http://data.divetouch.com/fbrs#registry> ;

ttlp_mt_local_file('/code/rdfsync/facebook-rdf-sync/test-data/123.ttl', 'https://graph.facebook.com/', 'https://graph.facebook.com/123');
ttlp_mt_local_file('/code/rdfsync/facebook-rdf-sync/test-data/1234.ttl', 'https://graph.facebook.com/', 'https://graph.facebook.com/1234');
ttlp_mt_local_file('/code/rdfsync/facebook-rdf-sync/test-data/registry.ttl', 'https://graph.facebook.com/', 'http://data.divetouch.com/fbrs#registry');
