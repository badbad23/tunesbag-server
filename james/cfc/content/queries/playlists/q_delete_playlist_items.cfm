<cfquery name="q_delete_playlist_item" datasource="mytunesbutleruserdata">
DELETE FROM
	playlist_items
WHERE
	/*userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
	AND*/
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
	AND
	entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykeys#" list="true">)
;
</cfquery>