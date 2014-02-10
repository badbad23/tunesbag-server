<cfquery name="q_select_processing_queue_items_count_user" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_items
FROM
	uploaded_items_status
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
;
</cfquery>