<cfquery name="q_select_identities_by_identifier" datasource="mytunesbutleruserdata">
SELECT
	users_externalidentifiers.userkey,
	users_externalidentifiers.dt_created,
	users.username,
	users_externalidentifiers.provider,
	users_externalidentifiers.identifier,
	users_externalidentifiers.entrykey
FROM
	users_externalidentifiers
LEFT JOIN
	users ON (users.entrykey = users_externalidentifiers.userkey)
WHERE
	users_externalidentifiers.identifier = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.identifier#">
	AND
	users_externalidentifiers.provider = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.provider#">
	AND NOT
	/* non-existing users */
	ISNULL(users.username)
;
</cfquery>