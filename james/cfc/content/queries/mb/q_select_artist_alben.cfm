<cfquery name="q_select_artist_alben" datasource="#application.udf.getMBds()#">
SELECT
	album.id,
	album.id AS sortid,
	album.artist,
	artist.name AS artist_name,
	artist.gid AS artist_gid,
	album.name,
	album.attributes,
	'' AS releasedate,
	albuminfo.img_revision,
	album_amazon_asin.coverarturl
FROM
	album
LEFT JOIN
	artist ON (artist.id = album.artist)
LEFT JOIN
	mytunesbutlercontent.common_album_information AS albuminfo ON (albuminfo.albumid = album.id)
LEFT JOIN
	album_amazon_asin ON (album_amazon_asin.album = album.id)
WHERE
 	album.artist = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">

	<!--- don't perform this actions for various artists, simply too much hits --->
	<cfif arguments.artistid GT 1>
		AND
			album.attributes IN (1100,3100)
		GROUP BY
			album.name
		ORDER BY
			/* use the special sort id */
			album.id DESC
	</cfif>

LIMIT
	50
;
</cfquery>