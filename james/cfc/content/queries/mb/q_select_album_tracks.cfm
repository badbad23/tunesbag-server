
<cfquery name="q_select_album_tracks" datasource="#application.udf.getMBds()#">
(SELECT
	albumjoin.album AS mb_albumid,
	albumjoin.track,
	albumjoin.sequence,
	track.name AS track_name,
	CEILING(track.length / 1000) AS tracklen,
	artist.name AS artist_name,
	artist.id AS artist_id
FROM
	albumjoin
LEFT JOIN
	track ON (track.id = albumjoin.track)
LEFT JOIN
	artist ON (artist.id = track.artist)
WHERE
	albumjoin.album = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbAlbumID#">
ORDER BY
	albumjoin.sequence
LIMIT
	100
)

<!--- join custom albums? --->
<cfif arguments.mbAlbumID GT 100000000>
	UNION ALL
	(
	SELECT
		albumjoincust.album AS mb_albumid,
		albumjoincust.track,
		albumjoincust.sequence,
		trackcust.name AS track_name,
		CEILING(trackcust.length / 1000) AS tracklen,
		artistcust.name AS artist_name,
		artistcust.id AS artist_id
	FROM
		mytunesbutlercontent.albumjoincust AS albumjoincust
	LEFT JOIN
		mytunesbutlercontent.trackcust ON (trackcust.id = albumjoincust.track)
	LEFT JOIN
		mytunesbutlercontent.artistcust AS artistcust ON (artistcust.id = trackcust.artist)
	WHERE
		albumjoincust.album = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbAlbumID#">
	ORDER BY
		albumjoincust.sequence
	LIMIT
		100
	)
</cfif>
</cfquery>