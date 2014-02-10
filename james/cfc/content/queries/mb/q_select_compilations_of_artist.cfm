
<!--- <cfquery name="q_select_compilations_of_artist" datasource="#application.udf.getMBds()#">
SELECT
	albumjoin.album
FROM
	track
LEFT JOIN
	albumjoin ON (albumjoin.track = track.id)	
WHERE
	track.artist = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">
	<!--- AND
	album.id > 0 --->
;
</cfquery> --->


<!--- compilations can stay with the basic musicbrainz DB --->
<cfquery name="q_select_compilations_of_artist" datasource="#application.udf.getMBds()#">
SELECT
	t.*,
	commoninfo.img_revision,
	'' releasedate
FROM
	(
SELECT
	<!--- track.name AS track_name,
	track.id AS track_id, --->
	album.name AS album_name,
	album.id AS album_id
FROM
	track
LEFT JOIN
	albumjoin ON (albumjoin.track = track.id)	
LEFT JOIN
	album ON (album.id = albumjoin.album AND NOT album.artist = track.artist)
WHERE
	track.artist = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">
	AND
	album.id > 0
LIMIT
	25
) AS t
LEFT JOIN
	mytunesbutlercontent.common_album_information AS commoninfo ON (commoninfo.albumid = t.album_id)
;
</cfquery>
