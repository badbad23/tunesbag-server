<cfquery name="q_select_artist_album" datasource="#application.udf.getMBds()#">
(SELECT
	album.name,
	album.id AS album_id,
	album.artist,
	album.attributes,
	999 AS weight
FROM
	album
WHERE
	(album.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_int_possible_artist_ids#" list="true">))	
	AND
	(album.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_album#">)
LIMIT
	1
)
UNION ALL
(
SELECT
	albumcust.name,
	albumcust.id AS album_id,
	albumcust.artist,
	albumcust.attributes,
	0 AS weight
FROM
	mytunesbutlercontent.albumcust AS albumcust
WHERE
	(albumcust.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_int_possible_artist_ids#" list="true">))	
	AND
	(albumcust.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_album#">)
LIMIT
	1
)
ORDER BY
	weight DESC
;
</cfquery>