<!---

	consumed shares

--->

<cfquery name="q_select_consumed_shares_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_shares
FROM
	friends
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
	AND
	accesslibrary = 1
;
</cfquery>