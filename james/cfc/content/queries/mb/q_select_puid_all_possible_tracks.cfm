<cfquery name="q_select_puid_all_possible_tracks"  datasource="#application.udf.getMBds()#">
/* select the original plus the musicbrainz data ... Important: The PUID might exist, but no mapping to a track! */
SELECT *,
	/* the perfect hit */
	(puid_artistid = orig_artistid AND puid_albumid = orig_albumid AND puid_trackid = orig_trackid) AS full_hit,
	/* ok, all strings are the same */
	(UPPER(orig_artist) = UPPER(mb_artist) AND UPPER(orig_album) = UPPER(mb_album) AND UPPER(orig_name) = UPPER(mb_name)) AS full_string_hit,

	/* artist ID is the same AND string title match AND Lendifference < 5 seconds */
	(	
		
		puid_artistid = orig_artistid
		AND
		UPPER(orig_artist) = UPPER(mb_artist)
		AND
		UPPER(orig_name) = UPPER(mb_name)
		AND
		compare_lendifference < 5
		
	) AS string_hit_artist_track,
	
	/* artist ID is the same AND HALF of string title matches AND Lendifference < 5 seconds */
	(	
		
		puid_artistid = orig_artistid
		AND
		UPPER(orig_artist) = UPPER(mb_artist)
		AND
		UPPER(orig_name_start) = UPPER(mb_name_start)
		AND
		compare_lendifference < 5
		
	) AS string_hit_artist_start_track,	

	/* compilation */
	IF ((puid_artistid = album_artist) = 0, 1, 0) AS is_compilation,
	(LEFT( mb_album_soundex, LENGTH(orig_album_soundex))  = orig_album_soundex ) AS is_same_album_soundex
FROM (

SELECT
	mediaitems.entrykey,
	/* original data */
	mediaitems.artist AS orig_artist,
	mediaitems.name AS orig_name,
	/* take half of the track name */
	TRIM(LEFT( mediaitems.name, 9 )) AS orig_name_start,
	mediaitems.album AS orig_album,
	SOUNDEX( mediaitems.album ) AS orig_album_soundex,
	mediaitems.totaltime AS orig_length,
	mediaitems.TrackNumber AS orig_sequence,
	mediaitems.year AS orig_year,
	/* results of the DB analysis */
	mediaitems.mb_artistid AS orig_artistid,
	mediaitems.mb_albumid AS orig_albumid,
	mediaitems.mb_trackid AS orig_trackid,
	/* puid data */
	track.id AS puid_trackid,
	album.id AS puid_albumid,
	album.attributes,
	track.artist AS puid_artistid,
	album.artist AS album_artist,
	puid.puid,
	track.name AS mb_name,
	TRIM(LEFT( track.name, 9 )) AS mb_name_start,
	ROUND(CONVERT(track.length / 1000, DECIMAL)) AS mb_length,
	artist.name AS mb_artist,
	albumjoin.sequence AS mb_sequence,
	album.name AS mb_album,
	SOUNDEX( album.name ) AS mb_album_soundex,
	ABS((CONVERT(track.length / 1000, DECIMAL) - mediaitems.totaltime)) AS compare_lendifference,
	LEFT( albummeta.firstreleasedate, 4) AS mb_year,
	albummeta.firstreleasedate,
	/* generate an unique identifier for this hit */
	MD5(CONCAT( artist.id, album.id, track.id )) AS mb_identifier,
	CONCAT( artist.name, album.name, track.name ) AS mb_concat_name
FROM
	track
LEFT JOIN
	mytunesbutleruserdata.mediaitems AS mediaitems ON
		(mediaitems.entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">)
LEFT JOIN
	puidjoin ON (puidjoin.track = track.id)
LEFT JOIN
	puid ON (puid.id = puidjoin.puid)
LEFT JOIN
	artist ON (artist.id = track.artist)
LEFT JOIN
	albumjoin ON (albumjoin.track = track.id)
LEFT JOIN
	album ON (album.id = albumjoin.album)
LEFT JOIN
	albummeta ON (albummeta.id = albumjoin.album)
WHERE
	track.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( q_select_further_possible_tracks.id )#,0" list="true">)
	
	<!--- only a certain hit? --->
	<cfif Len( arguments.mb_identifier ) GT 0>
		AND
		MD5(CONCAT( artist.id, album.id, track.id )) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mb_identifier#">
	</cfif>
	
	AND NOT
	ISNULL(artist.id)
)
AS
	source
GROUP BY
	mb_concat_name
ORDER BY
	/* full hit first */
	full_hit DESC,
	/* next: string hit */
	full_string_hit DESC,
	/* next: partial string hit */
	string_hit_artist_track DESC,
	/* album names sounds similar (original + musicbrainz) */
	is_same_album_soundex DESC,
	/* len diff */
	COMPARE_LENDIFFERENCE
;
</cfquery>