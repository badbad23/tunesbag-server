<!---

	select number of shares of this user (how many other users can access the data of this user?)

--->

<cfquery name="q_select_shares_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_shares
FROM
	friends
WHERE
	otheruserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
	AND
	accesslibrary = 1
;
</cfquery>