<cfquery name="q_set_plist_avg_rating" datasource="mytunesbutleruserdata">
UPDATE
	playlists
SET
	avgrating = (SELECT AVG(rating) FROM ratings WHERE mediaitemtype = 3 AND mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">)
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
;
</cfquery>