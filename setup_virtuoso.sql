grant all privileges to "SPARQL";

xml_set_ns_decl('user', 'http://graph.facebook.com/schema/user#', 2);
xml_set_ns_decl('page', 'http://graph.facebook.com/schema/page#', 2);
xml_set_ns_decl('fbrs', 'http://data.divetouch.com/fbrs#', 2);
xml_set_ns_decl('fbx', 'http://data.divetouch.com/fbx#', 2);
xml_set_ns_decl('api', 'tag:graph.facebook.com,2011:/', 2);

create procedure fbrs_reload_graph( in path_to_ttl varchar, in graph_uri varchar ) returns void
{
  -- clear previous graph
  sparql_eval( 'clear graph <' || graph_uri || '>', null, 10 );
  
  -- load new ttl file into storage
  ttlp_mt_local_file( path_to_ttl, 'https://graph.facebook.com/', graph_uri );
  
  -- clean dirty IDs
  declare uri varchar ;
  uri := 'https://graph.facebook.com/#' ;
  declare q varchar;
  q := 'delete from <' || graph_uri || '> { ?s ?p ?o } where { graph <' || graph_uri ||  '> { ?s ?p ?o . filter ( ?s = <' || uri || '> || ?o = <' || uri || '> ) } }';
  sparql_eval( q, null, 10 );
  
  -- add missing relation ( when dealing with relation documents )
  fbrs_add_missing_relation( graph_uri );
  -- inference ( run rules on this graph only )
  -- fbrs_inferr( graph_uri );
  
  -- update the state of this document in the registry
  q := 'modify fbrs:registry delete { <' || graph_uri || '> fbrs:state 0 } insert { <' || graph_uri || '> fbrs:state 2 }';
  sparql_eval( q, null, 10 );
};


create procedure fbrs_add_missing_relation( in graph_uri varchar ) returns varchar {
  declare rel_name varchar;
  declare user_id varchar;
  declare re varchar;
  re := 'https://graph.facebook.com/([0-9]+)/(.*)';
  rel_name := regexp_substr( re, graph_uri, 2 );
  if ( rel_name is not null ){
    user_id := regexp_substr( re, graph_uri, 1 );
    sparql_eval( 'modify <' || graph_uri || '> delete {} insert { <https://graph.facebook.com/' || user_id || '#> fbx:' || rel_name || ' ?bnode } where { ?bnode api:has ?item } limit 1 ', null, 10 );
  };
};


create procedure fbrs_queue_document( in local_name varchar ) returns void
{
  -- see if local name has a slash
  -- if it does, then it is a relation document
  -- otherwise it is an object document
  -- we add the fbrs:ObjectDocument or fbrs:RelationDocument markers
  -- they are used by some inference rules and batch post processing
  declare class_name varchar;
  if ( strstr( local_name, '/' ) ){
    class_name := 'RelationDocument';
  } else {
    class_name := 'ObjectDocument';
  };
  sparql_eval( 'insert data into fbrs:registry { <https://graph.facebook.com/' || local_name || '> a fbrs:Document, fbrs:'|| class_name  ||'; fbrs:state 0; fbrs:priority 5 ; fbrs:id "'|| local_name || '" .  }', null, 10 );
};


create procedure fbrs_queue_all_ids( ) returns void
{
  sparql
  insert into fbrs:registry
  {
      `iri( bif:concat( "https://graph.facebook.com/", ?id) )` a fbrs:Document, fbrs:ObjectDocument ;
        fbrs:id ?id ;
        fbrs:state 0 ;
        fbrs:priority 5
        .
  }
  where {
    {
      select
        distinct
          ?id
      where {
        ?x ?p ?id
        { ?s page:id ?id } union { ?s user:id ?id }
        filter not exists { [] fbrs:id ?id }
      }
    }
  };
};

-- fbrs_queue_all_ids();
-- fbrs_queue_document( '545415493/friends' );
-- sparql select * from fbrs:registry where { ?s ?p ?o };
-- sparql select * from <https://graph.facebook.com/544760365> where { ?s ?p ?o };
-- sparql select distinct ?name where { ?s user:name ?name } ;


