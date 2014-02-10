<cfquery name="q_select_album_coverart" datasource="#application.udf.getMBds()#">
SELECT
	album_amazon_asin.coverarturl AS amazon_url_img,
	album.id AS album_ID
FROM
	album
LEFT JOIN
	album_amazon_asin ON (album_amazon_asin.album = album.id)
WHERE
	(album.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#event.getArg( 'mbAlbumID' )#">)
	AND
	(LENGTH( album_amazon_asin.coverarturl ) > 0)
LIMIT
	1
;
</cfquery>

<!--- check for further possibilities ... e.g. the album is released by Various Artists (VA) and therefore no strict connection exists --->
<cfif q_select_album_coverart.recordcount IS 0>
	<cfquery name="q_select_album_coverart" datasource="#application.udf.getMBds()#">
	SELECT
		album_amazon_asin.coverarturl AS amazon_url_img,
		album.id AS album_ID
	FROM
		album
	LEFT JOIN
		album_amazon_asin ON (album_amazon_asin.album = album.id)
	WHERE
		(album.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#event.getArg( 'mbAlbumID' )#">)
		AND
		(LENGTH( album_amazon_asin.coverarturl ) > 0)
		AND
		(LENGTH( album.name ) > 0)
	LIMIT
		1
	;
	</cfquery>
</cfif>