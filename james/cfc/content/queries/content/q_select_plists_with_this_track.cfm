<cfquery name="q_select_plists_with_this_track" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT( playlist_items.playlistkey )
FROM
	mediaitems
INNER JOIN
	playlist_items ON (playlist_items.mediaitemkey = mediaitems.entrykey)
WHERE
	(mediaitems.artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">)
	AND
	(mediaitems.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">)
;
</cfquery>


<cfquery name="q_select_plists_with_this_track" datasource="mytunesbutleruserdata">
SELECT
	playlists.name,
	playlists.description,
	playlists.entrykey,
	playlists.userkey,
	playlists.username,
	seo.href
FROM
	playlists
LEFT JOIN
	mytunesbutlercontent.seo_playlist_url_latest AS seo ON (seo.plist_entrykey = playlists.entrykey)
WHERE

	<!--- needed because of a railo bug ... --->
	
	<cfif Len( q_select_plists_with_this_track.playlistkey ) GT 0>
		playlists.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_plists_with_this_track.playlistkey )#" list="true">)
	<cfelse>
		(playlists.id = -1)
	</cfif>
	
	AND
	playlists.public = 1
;
</cfquery>