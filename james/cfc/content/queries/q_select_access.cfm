<cfquery name="q_select_access" datasource="mytunesbutleruserdata">
SELECT
	times,lasttime
FROM
	timesaccessed
WHERE
	mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
	AND
	timesaccessed.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
;
</cfquery>