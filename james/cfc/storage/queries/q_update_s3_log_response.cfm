
<cfquery name="q_update_s3_log_response" datasource="mytunesbutlerlogging">
UPDATE
	s3log
SET
	response = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#a_str_response#">,
	success= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.success#">
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>