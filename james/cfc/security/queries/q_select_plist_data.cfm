<cfquery name="q_select_plist_data" datasource="mytunesbutleruserdata">
SELECT
	playlist.name,
	playlist.public,
	playlist.userkey,
	user.privacy_playlists,
	friends.accesslibrary,
	COUNT(friends.id) AS are_friends
FROM
	playlists AS playlist
LEFT JOIN
	users AS user ON (user.entrykey = playlist.userkey)
LEFT JOIN
	friends ON (friends.otheruserkey = playlist.userkey AND friends.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
WHERE
	playlist.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
GROUP BY
	playlist.entrykey
;
</cfquery>