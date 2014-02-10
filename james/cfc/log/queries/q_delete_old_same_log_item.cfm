<cfquery name="q_delete_old_same_log_item" datasource="mytunesbutlerlogging">
DELETE FROM
	logbook
WHERE
	createdbyuserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
	AND
	action = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.action#">
	AND
	linked_objectkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linked_objectkey#">
	AND
	objecttitle = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objecttitle#">
ORDER BY
	dt_created DESC
LIMIT 1
;
</cfquery>