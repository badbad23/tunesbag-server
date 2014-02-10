<cfquery name="q_select_puid_analyzed_unchecked_items" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_items
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
	AND
	puid_generated = 1
	AND
	puid_analyzed = 0
;
</cfquery>