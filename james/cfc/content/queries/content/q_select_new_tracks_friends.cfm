<cfquery name="qNewTracksFriends" datasource="mytunesbutleruserdata">
SELECT * FROM
	(
	SELECT
		mediaitems.id,
		mediaitems.album,
		mediaitems.artist,
		mediaitems.genre,
		mediaitems.mb_albumid,
		mediaitems.mb_artistid
	FROM
		mediaitems
	WHERE
		mediaitems.dt_created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -14, Now() )#">
		AND
		mediaitems.userkey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#sFriendKeys#" list="true">)
	) AS source
</cfquery>

<cfquery name="qNewTracksFriends_artists" dbtype="query">
SELECT
	COUNT(id) AS counter,
	artist,
	mb_artistid
FROM
	qNewTracksFriends
GROUP BY
	artist,mb_artistid
ORDER BY
	counter DESC
</cfquery>


<cfquery name="qNewTracksFriends_genres" dbtype="query" maxrows="7">
SELECT
	COUNT(id) AS counter,
	genre
FROM
	qNewTracksFriends
WHERE
	LENGTH( genre ) > 2
GROUP BY
	genre
ORDER BY
	counter DESC
</cfquery>


<cfquery name="qNewTracksFriends_albums" dbtype="query" maxrows="7">
SELECT
	COUNT(id) AS counter,
	album,
	artist,
	mb_albumid,
	mb_artistid
FROM
	qNewTracksFriends
GROUP BY
	album,artist,mb_albumid,mb_artistid
ORDER BY
	counter DESC
</cfquery>