<cfquery name="q_select_explore_users" datasource="mytunesbutleruserdata">
SELECT
	entrykey,
	username,
	pic,
	firstname
FROM
	users
WHERE
	public_profile = 1
	AND
	UPPER(username) LIKE (<cfqueryparam cfsqltype="cf_sql_varchar" value="%#Trim(UCase( arguments.username ))#%">)
LIMIT
	10
;
</cfquery>