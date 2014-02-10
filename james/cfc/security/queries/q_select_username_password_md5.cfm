<!---

	select username / password_md5

--->

<cfquery name="q_select_username_password_md5" datasource="mytunesbutleruserdata">
SELECT
	entrykey, MD5( pwd ) AS pwd_md5
FROM
	users
WHERE
	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
;
</cfquery>