<cfquery name="q_update_set_calculated_puid" datasource="mytunesbutleruserdata">
UPDATE
	mediaitems
SET
	puid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.puid#">
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
;
</cfquery>