<cfquery name="q_select_total_size" datasource="mytunesbutleruserdata">
SELECT
	SUM(size) AS totalsize
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
;
</cfquery>