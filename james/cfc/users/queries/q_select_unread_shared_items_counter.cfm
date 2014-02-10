<cfquery name="q_select_unread_shared_items_counter" datasource="mytunesbutleruserdata">
SELECT
	COUNT(shareditems_autoplist.id) AS counter
FROM
	shareditems_autoplist
WHERE
	shareditems_autoplist.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
;
</cfquery>