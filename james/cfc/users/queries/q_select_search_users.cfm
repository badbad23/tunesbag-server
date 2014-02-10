<cfquery name="q_select_search_users" datasource="mytunesbutleruserdata">
SELECT
	username,countryisocode
FROM
	users
WHERE
	username LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.search#%">
	AND
	privacy_profile = 0
ORDER BY
	username
LIMIT
	7
;
</cfquery>