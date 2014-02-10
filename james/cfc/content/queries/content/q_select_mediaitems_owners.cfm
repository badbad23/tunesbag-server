<cfquery name="q_select_mediaitems_owners" datasource="mytunesbutleruserdata">
SELECT
	COUNT(userkey) AS count_users
FROM
	mediaitems
WHERE
	(mediaitems.artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">)
	AND
	(mediaitems.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">)
	<!--- AND NOT
	(mediaitems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">) --->
;
</cfquery>