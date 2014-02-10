<!---

	select real username by Facebook UID

--->

<cfquery name="q_select_local_userkey_by_facebookuid" datasource="mytunesbutleruserdata">
SELECT
	3rdparty_ids.userkey,
	users.entrykey
FROM
	3rdparty_ids
LEFT JOIN
	users ON (users.entrykey = 3rdparty_ids.userkey)
WHERE
	(3rdparty_ids.username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FacebookUID#">)
	AND
	(3rdparty_ids.servicename = 'facebook')
	AND
	/* valid session id */
	(Length( 3rdparty_ids.sessionid ) > 0)
	AND
	/* make sure user exists */
	(Length( users.entrykey ) > 0)
ORDER BY
	3rdparty_ids.dt_created DESC
LIMIT
	1
;
</cfquery>