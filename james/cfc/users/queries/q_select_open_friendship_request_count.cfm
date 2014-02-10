<cfquery name="q_select_open_friendship_request_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS counter
FROM
	friendship_requests
WHERE
	otheruserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
;
</cfquery>