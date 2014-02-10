<!--- search for albums --->
<cfquery name="q_select_search_albums" datasource="#application.udf.getMBds()#">
/* search for albums */
(
SELECT
	album.id,
	album.artist,
	album.name,
	album.attributes,
	rel.releasedate,
	artist.name AS artist_name,
	999 AS weight,
	/* string compare ... */
	ABS(STRCMP( album.name, <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#"> )) AS compare_albumname
FROM
	album
LEFT JOIN
	artist ON (artist.id = album.artist)
LEFT JOIN
	`release` AS rel ON (rel.album = album.id)
WHERE
	album.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artists#" list="true">)
	AND
	(
		/* is exactly or LIKE name */
		album.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#">
		OR
		album.name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#%">
	)
GROUP BY
	album.id
ORDER BY
	/* always use the first hit of the database */
	album.id DESC
LIMIT
	10
)
UNION ALL
(
SELECT
	albumcust.id,
	albumcust.artist,
	albumcust.name,
	albumcust.attributes,
	'' AS releasedate,
	artistcust.name AS artist_name,
	0 AS weight,
	/* compare album name */
	ABS(STRCMP( artistcust.name, <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#">)) AS compare_albumname
FROM
	mytunesbutlercontent.albumcust AS albumcust
LEFT JOIN
	mytunesbutlercontent.artistcust ON (artistcust.id = albumcust.artist)
WHERE
	albumcust.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artists#" list="true">)
	AND
	(
		/* is exactly or LIKE name */
		albumcust.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#">
		OR
		albumcust.name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.album#%">
	)
LIMIT
	5
)
ORDER BY
	weight DESC,
	COMPARE_ALBUMNAME,
	releasedate DESC
;
</cfquery>