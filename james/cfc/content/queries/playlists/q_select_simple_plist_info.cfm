<cfquery name="q_select_simple_plist_info" datasource="mytunesbutleruserdata">
SELECT
	playlists.id,
	playlists.entrykey,
	playlists.name,
	playlists.description,
	playlists.userkey,
	playlists.public,
	playlists.tags,
	playlists.itemscount,
	playlists.items,
	playlists.dynamic,
	playlists.imageset,
	playlists.dt_created,
	playlists.dt_lastmodified,
	seo.href AS seohref,
	librarykey,
	users.privacy_playlists,
	playlists.licence_type_image,
	playlists.licence_image_link
FROM
	playlists
LEFT JOIN
	/* join seo URL */
	mytunesbutlercontent.seo_playlist_url_latest AS seo ON (seo.plist_id = playlists.id)
LEFT JOIN
	/* join user privacy settings */
	users ON (users.entrykey = playlists.userkey)
WHERE
	playlists.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
;
</cfquery>