<cfquery name="q_update_seconds_played" datasource="mytunesbutlerlogging">
UPDATE
	playeditems
SET
	secondsplayed = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.secondsplayed#">
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
	AND
	mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
/* update the newest item */
ORDER BY
	id DESC
LIMIT
	1
;
</cfquery>