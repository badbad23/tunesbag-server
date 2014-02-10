
<cfquery name="q_select_hashvalues_exist" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.originalfilehashvalue
FROM
	mediaitems
WHERE
	mediaitems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
	AND
	mediaitems.originalfilehashvalue IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( arguments.query.hashvalue )#" list="true">)
;
</cfquery>