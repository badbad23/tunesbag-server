<cfquery name="q_select_shared_items_list" datasource="mytunesbutleruserdata">
SELECT
	entrykey
FROM
	shareditems
WHERE
	identifier = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
	AND
	recipients LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%user:#arguments.securitycontext.username#%">
;
</cfquery>

<cfquery name="q_update_set_rec_read" datasource="mytunesbutleruserdata">
UPDATE
	shareditems_autoplist
SET
	`read` = 1
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
	AND
	sharekey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_shared_items_list.entrykey )#" list="true">)
;
</cfquery>