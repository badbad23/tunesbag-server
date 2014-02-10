<!--- 

	select the next hundred items ...

 --->

<cfset a_cmp_lastfm = application.beanFactory.getBean( 'LastFMComponent' ) />
<cfset a_cmp_mb = application.beanFactory.getBean( 'MusicBrainz' ) />

<cfquery name="q_select_alben" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT(mediaitems.mb_albumid),
	albuminfo.artworkchecked,
	IFNULL( albuminfo.artworkchecked, 0 ) as common_item_exists,
	albuminfo.dt_lastupdate_lastfm,
	album.name AS album,
	artist.name AS artist
FROM
	mediaitems
LEFT JOIN
	mytunesbutlercontent.common_album_information AS albuminfo ON (albuminfo.albumid = mediaitems.mb_albumid)
LEFT JOIN
	mytunesbutler_mb.album AS album ON (album.id = mediaitems.mb_albumid)
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = album.artist)
WHERE
	(
		(albuminfo.artworkchecked IS NULL)
		OR
		(albuminfo.artworkchecked = 0)
	)
	AND
	mediaitems.mb_albumid > 0
LIMIT
	50
;
</cfquery>

<cfdump var="#q_select_alben#">

<meta http-equiv="refresh" content="1" />

<cfoutput query="q_select_alben">

	<cfset a_str_artwork = '' />
	<cfset a_struct_common_info = StructNew() />
	<cfset a_struct_common_info.artworkchecked = 1 />

	<cfif NOT q_select_alben.common_item_exists>

		<!--- ok, first of all ... try to load using amazon data --->
		<cfset a_amazon = a_cmp_mb.getSimpleAlbumMetaInfoByAlbumID( albumid = q_select_alben.mb_albumid ) />
		
		<cfif a_amazon.getispersisted() AND Len( a_amazon.getcoverarturl() ) GT 0>
			<cfset a_str_artwork = a_amazon.getcoverarturl() />
		</cfif>
		
		<!--- ok, next ... check last.fm  --->
		<cfif Len( a_str_artwork ) IS 0>
		
			<cfset a_lastfm_info = a_cmp_lastfm.getAlbumInformation(mbalbumid = q_select_alben.mb_albumid,
						artist = q_select_alben.artist,
						album = q_select_alben.album ) />
			
			<!--- <cfdump var="#a_lastfm_info#"> --->
			
			<!--- ok, use this artwork ... --->
			<cfif a_lastfm_info.result>
				<cfset a_str_artwork = a_lastfm_info.artwork />
			</cfif>
		
		</cfif>
		
	</cfif>
	
	<!--- use the given artwork --->
	<cfset a_struct_common_info.artwork = a_str_artwork />
	
	#a_str_artwork#<br />
	
	<!--- store data ... --->
	<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonAlbumInfo( mbalbumid = q_select_alben.mb_albumid,
				data = a_struct_common_info ) />

</cfoutput>