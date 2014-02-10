<cfquery name="q_delete_clean_playlist_items" datasource="mytunesbutleruserdata">
DELETE FROM
	playlist_items
WHERE
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
;
</cfquery>