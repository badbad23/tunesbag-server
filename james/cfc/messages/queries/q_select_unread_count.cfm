<!---

	Keywords

--->

<cfquery name="q_select_unread_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_id
FROM
	messages
WHERE
	status_read = 0
	AND
	userkey_to = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
;
</cfquery>