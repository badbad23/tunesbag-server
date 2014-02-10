
<cfquery name="q_select_users_with_tracks_of_this_artist" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT( mediaitems.userkey ),
	users.username,
	users.pic
FROM
	mediaitems
LEFT JOIN
	users ON (users.entrykey = mediaitems.userkey)
WHERE
	(mediaitems.artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">)
ORDER BY
	RAND()
LIMIT
	10
;
</cfquery>