<!---

	Delete a playlist

--->

<cfquery name="q_delete_playlist" datasource="mytunesbutleruserdata">
DELETE FROM
	playlists
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
	AND
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>

<cfquery name="q_delete_playlist_items" datasource="mytunesbutleruserdata">
DELETE FROM
	playlist_items
WHERE
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>

<!--- delete SEO item --->
<cfquery name="q_delete_playlist_items" datasource="mytunesbutlercontent">
DELETE FROM
	seo_playlist_url_latest
WHERE
	plist_entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>