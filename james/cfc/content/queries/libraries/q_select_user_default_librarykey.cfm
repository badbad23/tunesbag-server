<cfquery name="q_select_user_default_librarykey" datasource="mytunesbutleruserdata">
SELECT
	entrykey
FROM
	libraries
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
;
</cfquery>