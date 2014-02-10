<!--- 

	select playlists with the given item
	
	a) collect items
	
	b) select really data

 --->

<cfquery name="q_select_playlists_with_item_collect" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT( playlist_items.playlistkey )
FROM
	playlist_items
LEFT JOIN
	mediaitems ON (mediaitems.entrykey = playlist_items.mediaitemkey)
WHERE
	(1 = 1)
	
	<cfif arguments.artistid GT 0>
		AND
		(mb_artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">)
		
		<cfset a_bol_hit = true />
	</cfif>

	<cfif arguments.albumid GT 0>
		AND
		(mb_albumid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.albumid#">)
		
		<cfset a_bol_hit = true />		
	</cfif>
	
	<cfif arguments.trackid GT 0>
		AND
		(mb_trackid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.trackid#">)
		
		<cfset a_bol_hit = true />		
	</cfif>
	
	<cfif NOT a_bol_hit>
		AND
		(1 = 0)
	</cfif>
		
LIMIT
	100
;
</cfquery>

<cfquery name="q_select_playlists_with_item" datasource="mytunesbutleruserdata">
SELECT
	playlists.entrykey,
	playlists.name,
	playlists.description,
	playlists.userkey,
	playlists.dt_lastmodified,
	playlists.avgrating,
	playlists.imageset,
	playlists.tags,
	users.username,
	seo.href
FROM
	playlists
LEFT JOIN
	users ON (users.entrykey = playlists.userkey)
LEFT JOIN
	mytunesbutlercontent.seo_playlist_url_latest AS seo ON (seo.plist_entrykey = playlists.entrykey)
WHERE
	playlists.istemporary = 0
	AND
	playlists.public = 1
	AND
	dynamic = 0
	AND
	playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_playlists_with_item_collect.playlistkey )#" list="true">)
	AND
	users.privacy_profile = 0
	AND
	users.privacy_playlists = 0
ORDER BY
	avgrating DESC,
	name,
	dt_lastmodified
LIMIT
	100
;
</cfquery>