<cfquery name="qSelectRecentlyPlayedPlists" datasource="mytunesbutleruserdata">
SELECT
	playlists.name,
	playlists.entrykey,
	playlists.userkey,
	playlists.description,
	playlists.tags,
	playlists.public,
	playlists.itemscount,
	playlists.username,
	playlists.avgrating,
	playlists.totaltime,
	playlists.dt_created,
	playlists.imageset,
	playlists.img_revision,
	lasttime
FROM
(SELECT
	timesaccessed.lasttime,
	timesaccessed.mediaitemkey
	<!--- playlists.* --->
FROM
	timesaccessed
<!--- LEFT JOIN
	playlists ON (playlists.entrykey = timesaccessed.mediaitemkey) --->
WHERE
	timesaccessed.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
	AND
	timesaccessed.itemtype = 1
	AND
	timesaccessed.lasttime > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -arguments.maxage, Now() )#">
) AS t1
LEFT JOIN
	playlists ON (playlists.entrykey = mediaitemkey)
WHERE
	/* no temporary plists */
	(playlists.istemporary = 0)
	
	/* check rights */	
	<cfif arguments.securitycontext.rights.playlist.radio IS 0>
		AND
		(playlists.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
	</cfif>

ORDER BY
	lasttime DESC
LIMIT
	25
;
</cfquery>