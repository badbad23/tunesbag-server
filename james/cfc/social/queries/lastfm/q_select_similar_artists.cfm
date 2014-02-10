<cfquery name="q_select_similar_artists" datasource="mytunesbutlercontent">
SELECT
	lastfm_similar_artists.ARTISTDEST_MBID,
	lastfm_similar_artists.MATCHPERCENT,
	artist.name AS similar_artist
FROM
	lastfm_similar_artists
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = lastfm_similar_artists.artistdest_mbid)
WHERE
	lastfm_similar_artists.artistsource_mbid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mbartistid#">
ORDER BY
	lastfm_similar_artists.MATCHPERCENT DESC
;
</cfquery>