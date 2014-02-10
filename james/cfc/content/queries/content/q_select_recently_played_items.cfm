<!--- perform query ... ugly way because otherweise mysql never took the primary index of mediaitems ... --->

<!--- 

	TODO: run as one query with subqueries ...

 --->

<!--- 2 parts: a) collect entrykeys --->
<cfquery name="q_select_collect_entrykeys"  datasource="mytunesbutlerlogging" cachedwithin="#CreateTimeSpan( 0, 0, 1, 30 )#">
SELECT
	playeditems.mediaitemkey,
	/* be compatible with existing display routines ... return mediaitem key as ENTRYKEY as well */
	playeditems.mediaitemkey AS entrykey,
	playeditems.userkey AS playeditems_userkey,
	playeditems.applicationkey,
	users.username,
	'' AS artist,
	0 AS mb_artistid,
	'' AS album,
	'' AS name,
	'' AS genre,
	0 AS hit,
	0 AS img_revision
FROM
	playeditems
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = playeditems.userkey)
WHERE

	(playeditems.dt_created > Date_SUB(Now(), INTERVAL 21 DAY))
	
	<!--- only identified tracks? --->
	<cfif ListFindNoCase( arguments.options, 'Identifiedonly' )>
		AND
		(playeditems.mb_trackid > 0)
		AND
		(playeditems.mb_trackid < 100000000)
		AND
		(playeditems.mb_artistid > 0)
		AND
		(playeditems.mb_artistid < 100000000)
	</cfif>
	
	<cfif ListFindNoCase( arguments.options, 'min30sec')>
		AND
		(playeditems.secondsplayed >= 30)
	</cfif>
	
	<cfif Len( arguments.userkeys ) GT 0>
	AND
	(playeditems.userkey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkeys#" list="true">))
	</cfif>

	<cfif StructKeyExists( arguments.filter, 'dt_created_from' )>
		
		AND
		(playeditems.dt_created >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime( arguments.filter.dt_created_from )#">)
		
	</cfif>
	
	<cfif StructKeyExists( arguments.filter, 'dt_created_to' )>
		
		AND
		(playeditems.dt_created <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime( arguments.filter.dt_created_to )#">)
		
	</cfif>

ORDER BY
	playeditems.dt_created DESC
LIMIT
	#Val( arguments.maxrows )#	
;
</cfquery>

<cfquery name="q_select_recently_played_items" datasource="mytunesbutleruserdata" cachedwithin="#CreateTimeSpan( 0, 0, 1, 30 )#">
SELECT
	<cfif ListFindNoCase( arguments.options, 'Identifiedonly' )>
		artist.name AS artist,
		track.name AS name,
		album.name AS album,
	<cfelse>
		mediaitems.artist,
		mediaitems.album,
		mediaitems.name,
	</cfif>
	mediaitems.genre,
	mediaitems.entrykey,
	mediaitems.mb_artistid,
	IFNULL( artist_info.img_revision, 0 ) AS img_revision
FROM
	mediaitems
LEFT JOIN
	mytunesbutlercontent.common_artist_information AS artist_info ON (artist_info.artistid = mediaitems.mb_artistid)
<cfif ListFindNoCase( arguments.options, 'Identifiedonly' )>
	LEFT JOIN
		mytunesbutler_mb.artist AS artist ON (artist.id = mediaitems.mb_artistid)
	LEFT JOIN
		mytunesbutler_mb.track AS track ON (track.id = mediaitems.mb_trackid)	
	LEFT JOIN
		mytunesbutler_mb.album AS album ON (album.id = mediaitems.mb_albumid)
</cfif>
WHERE
	mediaitems.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="dummy,#ValueList( q_select_collect_entrykeys.mediaitemkey )#" list="true">)
;
</cfquery>

<!--- create structure --->
<cfloop query="q_select_recently_played_items">
	<cfset a_struct_mediaitems[ q_select_recently_played_items.entrykey ] = { artist = q_select_recently_played_items.artist, img_revision = q_select_recently_played_items.img_revision, mb_artistid = q_select_recently_played_items.mb_artistid, album = q_select_recently_played_items.album, genre = q_select_recently_played_items.genre, name = q_select_recently_played_items.name } />
</cfloop>

<!--- loop over data and set HIT = 1 --->
<cfloop query="q_select_collect_entrykeys">
	
	<cfif StructKeyExists( a_struct_mediaitems, q_select_collect_entrykeys.mediaitemkey )>
		
		<cfset QuerySetCell( q_select_collect_entrykeys, 'artist', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].artist, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'mb_artistid', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].mb_artistid, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'album', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].album, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'name', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].name, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'genre', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].genre, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'hit', 1, q_select_collect_entrykeys.currentrow ) />
		<cfset QuerySetCell( q_select_collect_entrykeys, 'img_revision', a_struct_mediaitems[ q_select_collect_entrykeys.mediaitemkey ].img_revision, q_select_collect_entrykeys.currentrow ) />
	
	</cfif>
	
</cfloop>

<!--- select items with a hit --->
<cfquery name="q_select_recently_played_items" dbtype="query">
SELECT
	*
FROM
	q_select_collect_entrykeys
WHERE
	hit = 1
;
</cfquery>
