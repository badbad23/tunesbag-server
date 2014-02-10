<!--- select basic information ... --->
<cfquery name="q_select_simple_artist_track" datasource="#application.udf.getMBds()#">
/* find out if we've a real artist / album or just a dummy entry */
(SELECT
	0 AS source,
	track.id AS track_id,
	track.name,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#"> AS given_title,
	/* always positive numbers, so that we can sort in the right order */
	ABS(STRCMP( track.name, <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#">)) AS compare_title,
	ABS((CONVERT( track.length / 1000, DECIMAL) - <cfqueryparam cfsqltype="cf_sql_integer" value="#a_item.gettotaltime()#">)) AS lendifference,	
	track.artist,
	albumjoin.album,
	album.name AS album_name,
	album.artist AS album_artist,
	album.attributes AS album_attributes,
	IF(album.artist = track.artist, 0, 1 ) AS is_compilation,
	/* compare the name of the album ... use absolute numbers */
	IFNULL( ABS(STRCMP( album.name, <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_album#">)), 999) AS COMPARE_ALBUM,
	STRCMP( SOUNDEX( track.name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#"> )) AS SOUNDEX_COMPARE,
	ABS( LENGTH(track.name) - LENGTH(<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#">)) AS len_diff_title
FROM
	track
LEFT JOIN
	albumjoin ON (albumjoin.track = track.id)
LEFT JOIN
	album ON (album.id = albumjoin.album)
WHERE
	track.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_int_possible_artist_ids#" list="true">)
	AND
	(
			(
			/* like bla bla bla */
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( track.name, ' ', ''), '.', '' ), '?', ''), '''', '' ), ')', ''), '(', ''),'-','')  LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_simple_title#%">
			)
		OR
			(
			/* Direct hit .. sounds like xy */
			STRCMP( SOUNDEX( track.name ), SOUNDEX( <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#"> )) = 0
			)	
	)
/*GROUP BY
	track.id*/
LIMIT
	300
)
UNION ALL
(
SELECT
	-1 AS source,
	trackcust.id AS track_id,
	trackcust.name,
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#"> AS given_title,
	/* always absolute value so that we can sort in the right order */
	ABS(STRCMP( trackcust.name, <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#">)) AS compare_title,
	ABS((CONVERT(trackcust.length / 1000, DECIMAL) - <cfqueryparam cfsqltype="cf_sql_integer" value="#a_item.gettotaltime()#">)) AS lendifference,	
	trackcust.artist,
	albumjoincust.album,
	'' As album_name,
	0 AS album_artist,
	0 AS album_attributes,
	0 AS is_compilation,
	-99 AS COMPARE_ALBUM,
	0 AS SOUNDEX_COMPARE,
	ABS( LENGTH(trackcust.name) - LENGTH(<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_title#">)) AS len_diff_title
FROM
	mytunesbutlercontent.trackcust
LEFT JOIN
	mytunesbutlercontent.albumjoincust AS albumjoincust ON (albumjoincust.track = trackcust.id)
WHERE
	trackcust.artist IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#a_int_possible_artist_ids#" list="true">)
	AND
	(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( trackcust.name, ' ', ''), '.', '' ), '?', ''), '''', '' ), ')', ''), '(', ''),'-','')  LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#a_simple_title#%">)
LIMIT
30
)

ORDER BY
	/* prefer results of musicbrainz DB */
	source DESC,
	/* prefer results with exact match */
	compare_title,
	/* next: sound match */
	(soundex_compare = 0) DESC,
	/* check exact album match */
	compare_album,
	/* prefer real albums to compilations */
	is_compilation,
	/* lower rank of live */
	album_attributes,
	/* order by length difference */
	lendifference,
	/* by track id, simply the earler database item */
	track_id
;
</cfquery>