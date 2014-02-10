<!--- 

	find at least one public playlists where this track appears in order to allow access

 --->

<cfquery name="q_select_mediaitem_data" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.userkey,
	users.username,
	/* privacy mode */
	users.privacy_playlists,
	/* already published in playlists */
	COUNT( playlists.id ) AS published_in_playlists,
	playlist_items.playlistkey,
	playlists.name AS playlist_name,
	playlists.public AS playlist_public,
	/* users are friends */
	COUNT(friends.id) AS are_friends,
	/* individual access to lib items allowed */
	friends.accesslibrary
FROM
	mediaitems AS mediaitem
LEFT JOIN
	users ON (users.entrykey = mediaitem.userkey)
LEFT JOIN
	playlist_items ON (playlist_items.mediaitemkey = mediaitem.entrykey)
LEFT JOIN
	playlists ON (playlists.entrykey = playlist_items.playlistkey AND playlists.public = 1 AND playlists.istemporary = 0 AND playlists.dynamic = 0)
LEFT JOIN
	friends ON (friends.otheruserkey = mediaitem.userkey AND friends.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)	
WHERE
	mediaitem.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
GROUP BY
	mediaitem.entrykey
;
</cfquery>
