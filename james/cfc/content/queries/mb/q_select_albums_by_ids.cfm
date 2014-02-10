
<cfquery name="q_select_albums_by_ids" datasource="#application.udf.getMBds()#">
<!--- <cfif NOT arguments.bIgnoreCustomAlbums>
	(
</cfif> --->

SELECT
	album.id,
	album.artist,
	album.name,
	album.attributes,
	rel.releasedate,
	artist.name AS artist_name,
	artist.gid AS artist_gid,
	IFNULL( strips.img_revision, -1 ) AS strip_img_revision,
	strips.imgheight AS strip_img_height,
	strips.imgwidth AS strip_img_width,
	strips.copyrighthints AS strips_copyrighthints
FROM
	album
LEFT JOIN
	artist ON (artist.id = album.artist)
LEFT JOIN
	`release` AS rel ON (rel.album = album.id)
LEFT JOIN
	/* join default strip image */
	mytunesbutlercontent.image_strips AS strips ON (strips.mbtype = 2 AND strips.mbid = artist.id AND strips.img_type = #application.const.I_IMG_STRIP_TYPE_DEFAULT#)
WHERE
	album.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.albumids#" list="true">)
GROUP BY
	album.id
<!--- 
<cfif NOT arguments.bIgnoreCustomAlbums>
	)
	UNION ALL
	(
	SELECT
		albumcust.id,
		albumcust.artist,
		albumcust.name,
		albumcust.attributes,
		'' AS releasedate,
		artistcust.name AS artist_name,
		artistcust.gid AS artist_gid,		
		-1 AS strip_img_revision,
		0 AS strip_img_height,
		0 AS strip_img_width,
		'' AS strips_copyrighthints
	FROM
		mytunesbutlercontent.albumcust AS albumcust
	LEFT JOIN
		mytunesbutlercontent.artistcust AS artistcust ON (artistcust.id = albumcust.artist)
	WHERE
		albumcust.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.albumids#" list="true">)
	)
	;
</cfif> --->
</cfquery>