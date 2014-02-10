<!---
	select basic information ...
--->

<cfquery name="q_select_basic_track_information" datasource="#application.udf.getMBds()#">
/* find out if we've a real artist / album or just a dummy entry */
SELECT
	track.artist
FROM
	track
WHERE
	track.id = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.trackid#" />
;
</cfquery>

<!--- 
	no hit? try custom funky data
 --->
<cfif q_select_basic_track_information.recordcount IS 0>
	
	<cfquery name="q_select_basic_track_information" datasource="#application.udf.getMBds()#">
	SELECT
		trackcust.artist,
		albumjoincust.album
	FROM
		mytunesbutlercontent.trackcust
	LEFT JOIN
		mytunesbutlercontent.albumjoincust AS albumjoincust ON (albumjoincust.track = trackcust.id)
	WHERE
		trackcust.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.trackid#" />	
	</cfquery>
	
</cfif>

<cfquery name="q_select_track" datasource="#application.udf.getMBds()#">
SELECT
	track.name AS track_name,
	track.artist AS mb_artistid,
	track.id AS mb_trackid,
	CEILING(track.length / 1000) AS length,
	
	/* the artist of the track */
	artist.name AS artist_name,
	artist.id AS artist_id,
	artist.gid AS artist_gid,
	
	/* the album artist */
	album.artist AS mb_artistid_album,
	
	/* the album artist name */
	<cfif arguments.trackid GT 100000000>
		artist.name AS artist_album,
	<cfelse>
		artist_album.name AS artist_album,
	</cfif>
	
	/* album information */
	album.name AS album_name,
	album.id AS mb_albumid,
	album.language AS album_language,
	albumjoin.sequence,
	
	/* further meta info */
	<cfif arguments.trackid GT 100000000>
		'' AS release_year,
		'' AS tags_artist,
		'' AS tags_release,
		'' AS album_names,
	<cfelse>
		LEFT( rel.releasedate, 4) AS release_year,		
		REPLACE( GROUP_CONCAT( DISTINCT tag_info_artist.name SEPARATOR ', '), 'and', '') AS tags_artist,
		REPLACE( GROUP_CONCAT( DISTINCT tag_info_release.name SEPARATOR ', '), 'and', '') AS tags_release,
		GROUP_CONCAT( DISTINCT album.name SEPARATOR '| ') AS album_names,		
	</cfif>
	
	<cfif arguments.trackid GT 100000000>
		-1 AS strip_img_revision,
		0 AS strip_img_height,
		0 AS strip_img_width,
		'' AS strips_copyrighthints,
	<cfelse>
		IFNULL( strips.img_revision, -1 ) AS strip_img_revision,
		strips.imgheight AS strip_img_height,
		strips.imgwidth AS strip_img_width,
		strips.copyrighthints AS strips_copyrighthints,
	</cfif>
	
	/* common identifier */
	LCASE(MD5(CONCAT( lcase( artist.name ), lcase( track.name ) ))) AS artist_track_id
	
FROM
	<cfif arguments.trackid GT 100000000>
		mytunesbutlercontent.trackcust
	<cfelse>
		track
	</cfif>
	
	 AS track
	
LEFT JOIN
	
	<!--- join track artist --->
	<cfif q_select_basic_track_information.artist GT 100000000>
		artistcust
	<cfelse>
		artist
	</cfif>
	
	AS artist ON (artist.id = track.artist)
	
LEFT JOIN

	<!--- join album --->
	<cfif arguments.trackid GT 100000000>
		albumjoincust
	<cfelse>
		albumjoin
	</cfif>

	AS albumjoin ON (albumjoin.track = track.id)
	
LEFT JOIN
	<cfif arguments.trackid GT 100000000>
		mytunesbutlercontent.albumcust AS albumcust
	<cfelse>
		album
	</cfif>
	
	AS album ON (album.id = albumjoin.album)
	
<!--- album artist --->
<cfif arguments.trackid LT 100000000>
	LEFT JOIN
		artist AS artist_album ON (artist_album.id = album.artist)
</cfif>

<!--- tag information (only for known artists) --->
<cfif q_select_basic_track_information.artist LT 100000000>
LEFT JOIN
	`release` AS rel ON (rel.album = album.id)
LEFT JOIN
	release_tag ON (release_tag.release = album.id)
LEFT JOIN
	tag AS tag_info_release ON (tag_info_release.id = release_tag.tag)
LEFT JOIN
	artist_tag ON (artist_tag.artist = artist.id)
LEFT JOIN
	tag AS tag_info_artist ON (tag_info_artist.id = artist_tag.tag)
</cfif>

LEFT JOIN
	/* join default strip image */
	mytunesbutlercontent.image_strips AS strips ON (strips.mbtype = 2 AND strips.mbid = track.artist AND strips.img_type = #application.const.I_IMG_STRIP_TYPE_DEFAULT#)

WHERE
	track.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.trackid#">
GROUP BY
	artist_track_id
;
</cfquery>