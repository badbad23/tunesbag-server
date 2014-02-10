<cfquery name="q_select_fans_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT( id ) AS count_fans
FROM
	ratings
WHERE
	mediaitemtype = 2
	AND
	displayname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">
;
</cfquery>