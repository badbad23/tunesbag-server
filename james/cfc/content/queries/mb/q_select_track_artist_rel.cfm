<cfquery name="qSelectSimpleTrackArtistRelation" datasource="#application.udf.getMBds()#">
SELECT
	track.name,
	track.id AS track_id,
	track.artist AS artist_id,
	artist.name AS artist
FROM
	track
LEFT JOIN
	artist ON (artist.id = track.artist)
WHERE
	track.id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.iTrackID#">
</cfquery>