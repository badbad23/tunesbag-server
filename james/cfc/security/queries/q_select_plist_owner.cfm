<cfquery name="q_select_plist_owner" datasource="mytunesbutleruserdata">
SELECT
	userkey,
	public
FROM
	playlists
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>