<!---

	the main query

--->

<!--- TODO: cache unique items table --->

<cfif a_bol_create_uniquetable>
	
	<cfquery name="q_select_distinct_genres" datasource="mytunesbutleruserdata">
	SELECT
		DISTINCT( mediaitems.genre ),
		0 AS idx
	FROM
		mediaitems
	WHERE
		(mediaitems.librarykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">))
	;
	</cfquery>
	
	<!--- set index ... reduce by ONE because we perform a find_in_set later and mySQL is zero based --->
	<cfloop query="q_select_distinct_genres">
		<cfset querySetCell( q_select_distinct_genres, 'idx', (q_select_distinct_genres.currentrow - 1), q_select_distinct_genres.currentrow ) />
	</cfloop>
	
	<!--- return this unique structure holder --->
	<cfset a_struct_unique_table.genres = q_select_distinct_genres />
	
	<!--- list for lookups in the mySQL query --->
	<cfset a_str_unique_genres_list = ValueList( q_select_distinct_genres.genre ) />
	
	<!--- unique librarykeys ... build list from given list of valid librarykeys --->
	<cfset q_select_distinct_librarykeys = queryNew( 'librarykey,idx', 'varchar,integer' ) />
	
	<!--- loop over all given librarykeys --->
	<cfloop list="#arguments.librarykeys#" index="a_str_data">
		<cfset queryAddRow( q_select_distinct_librarykeys, 1 ) />
		
		<!--- the current lib query of the loop --->
		<cfset QuerySetCell( q_select_distinct_librarykeys, 'librarykey', a_str_data, q_select_distinct_librarykeys.recordcount ) />
		
		<!--- set the index ... mySQL is zero based, to subtract one --->
		<cfset QuerySetCell( q_select_distinct_librarykeys, 'idx', ListFindNoCase( arguments.librarykeys, a_str_data ) - 1, q_select_distinct_librarykeys.recordcount ) />		
	</cfloop>
	
	<cfset a_struct_unique_table.libraries = q_select_distinct_librarykeys />
	
	<!--- make sure we're requesting the source columns for the index calculation
	
		in case the user did not request them we'll remove them later again
	
	 --->
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'mb_artistid' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'mb_artistid' ) />
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'mb_artistid' ) />				
	</cfif>
	
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'album' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'album' ) />		
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'album' ) />				
	</cfif>	
	
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'artist' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'artist' ) />
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'artist' ) />				
	</cfif>		
	
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'mb_albumid' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'mb_albumid' ) />
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'mb_albumid' ) />				
	</cfif>	
	
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'librarykey' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'librarykey' ) />
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'librarykey' ) />				
	</cfif>		
	
	<cfif a_bol_field_filter_active AND ListFindNoCase( a_str_fields_to_return, 'genre' ) IS 0>
		<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'genre' ) />
		<cfset a_str_temp_cols_remove_later = ListAppend( a_str_temp_cols_remove_later, 'genre' ) />				
	</cfif>		

</cfif>

<!--- select library IDs --->
<cfquery name="qSelectLibIDs" datasource="mytunesbutleruserdata" cachedwithin="#CreateTimeSpan( 0, 0, 1, 0 )#">
SELECT
	libraries.id
FROM
	libraries
WHERE
	libraries.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">)
;
</cfquery>

<cfquery name="local.qSet" datasource="mytunesbutleruserdata">
SET #sSQLVarOwnTracks#=0;
</cfquery>

<!--- <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#"> --->
<cfquery name="q_select_mediaitems" datasource="mytunesbutleruserdata">
SELECT
	/* always select this field */
	mediaitem.entrykey
	
	/* counter ... own track? */
	,IF( (mediaitem.userid = #arguments.securitycontext.userid#), #sSQLVarOwnTracks#:=#sSQLVarOwnTracks#+1, #sSQLVarOwnTracks#:=#sSQLVarOwnTracks# ) AS ownershipcheck
	
	<!--- id of the item --->
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'id' ) GT 0>
		,mediaitem.id AS mediaitem_id
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'userkey' ) GT 0>
		,mediaitem.userkey
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'dt_created' ) GT 0>
		,mediaitem.dt_created
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'album' ) GT 0>
		,IF( (LENGTH(TRIM(mediaitem.album)) > 0), mediaitem.album, 'Unknown album') AS album
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'artist' ) GT 0>
		,IF( (LENGTH(TRIM(mediaitem.artist)) > 0), mediaitem.artist, 'Unknown artist') AS artist
	</cfif>
	
	<!--- special request ... combine artist + album in a field --->
	<cfif ListFindNoCase( a_str_fields_to_return, 'combine_artist_album_hash' ) GT 0>
		,MD5(CONCAT( mediaitem.artist, mediaitem.album )) AS combine_artist_album_hash,
		0 AS combine_artist_album_hash_exists 
	</cfif>
			
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'genre' ) GT 0>
		,mediaitem.genre
	</cfif>
	
	<!--- genre index --->
	<cfif a_bol_create_uniquetable AND NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'genreindex' ) GT 0>
		,(FIND_IN_SET(mediaitem.genre,'#a_str_unique_genres_list#') - 1) AS genreindex
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'size' ) GT 0>
		,mediaitem.size
	</cfif>
		
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'source' ) GT 0>
		,mediaitem.source
	</cfif>
		
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'name' ) GT 0>
		,mediaitem.name
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'yr' ) GT 0>
		,mediaitem.year AS yr
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'librarykey' ) GT 0>
		,mediaitem.librarykey
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'librarykeyindex' ) GT 0>
		,(FIND_IN_SET(mediaitem.librarykey,'#arguments.librarykeys#') - 1) AS librarykeyindex
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'mb_albumid' ) GT 0>
		,mediaitem.mb_albumid
	</cfif>

	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'mb_artistid' ) GT 0>
		,mediaitem.mb_artistid
	</cfif>
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'mb_trackid' ) GT 0>
		,mediaitem.mb_trackid
	</cfif>	
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'totaltime' ) GT 0>
		,mediaitem.totaltime
	</cfif>		
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'lasttime' ) GT 0>
		,timesaccessed.lasttime
	</cfif>	
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'times' ) GT 0>
		,timesaccessed.times
	</cfif>		
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'customartwork' ) GT 0>
		,mediaitem.customartwork
	</cfif>			
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'rating' ) GT 0>
		,IFNULL( rating.rating, 0) AS rating
	</cfif>			
	
	<cfif NOT a_bol_field_filter_active OR ListFindNoCase( a_str_fields_to_return, 'tracknumber' ) GT 0>
		/* return simple number */
		,ABS( mediaitem.tracknumber ) AS tracknumber
	</cfif>		
		
	/* especially for API requests ... do not return these fields on default requests */
	<cfif a_bol_field_filter_active>
		
		<cfif ListFindNoCase( a_str_fields_to_return, 'hashvalue' ) GT 0>
			,mediaitem.hashvalue
		</cfif>
		
		<cfif ListFindNoCase( a_str_fields_to_return, 'originalfilehashvalue' ) GT 0>
			,mediaitem.originalfilehashvalue
		</cfif>		
		
	</cfif>
	
	/* create information about item linking */
	<cfif a_bol_create_link_tables>
		,0 AS idxgenre
		,0 AS idxartist
		,0 AS idxalbum
	</cfif>
	
	<!--- special playlist ORder --->
	<cfif a_bol_plist_request>
		
		/* the entrykey of the connection in the playlist */
		,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.info_playlistkey#"> AS playlistitem_entrykey
	</cfif>
	
<cfswitch expression="#a_str_info_plistkey#">
	<cfcase value="followstream">

		<!--- select who has played this item the last time --->
		,users.username AS otherusername
		,timesaccessed.lasttime AS othertime
	
		FROM
			timesaccessed
		
		/* join media item key */
		LEFT JOIN
			mediaitems AS mediaitem ON (mediaitem.entrykey = timesaccessed.mediaitemkey)
			
		LEFT JOIN
			rel_library_mediaitem AS rel ON (rel.mediaitem_id = mediaitem.id)
			
		/* rating */
		LEFT JOIN
			ratings AS rating
			/* important: only select data of current user */
				ON (rating.mbid = mediaitem.mb_trackid AND rating.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#"> AND rating.mediaitemtype = 0)
		
		/* username */
		LEFT JOIN
			users ON (users.id = timesaccessed.userid)
				
	</cfcase>
	<cfcase value="recommendations">
		
		<!--- special handling for recommendations --->
		,users.username AS otherusername
		,DATE_FORMAT( shareditems.dt_created, '%m/%d/%y') AS othertime
		
		FROM
			mediaitems AS mediaitem
			
		LEFT JOIN
			rel_library_mediaitem AS rel ON (rel.mediaitem_id = mediaitem.id)
			
		/* inner = must exist */
		INNER JOIN
			shareditems_autoplist ON (shareditems_autoplist.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
		INNER JOIN
			shareditems ON ((shareditems.entrykey = shareditems_autoplist.sharekey) AND (mediaitem.entrykey = shareditems.identifier))
		
		/* rating */
		LEFT JOIN
			ratings AS rating
			/* important: only select data of current user */
				ON (rating.mediaitemkey = shareditems.identifier AND rating.userkey = shareditems_autoplist.userkey)
		
		LEFT JOIN
			timesaccessed AS timesaccessed
				ON (timesaccessed.mediaitemkey = shareditems.identifier AND timesaccessed.userkey = shareditems_autoplist.userkey)			
		
	
		/* username */
		LEFT JOIN
			users ON (users.entrykey = shareditems.createdbyuserkey)
	
	</cfcase>
	<cfdefaultcase>
		<!--- default case ... library --->	
		FROM
			rel_library_mediaitem AS rel
		LEFT JOIN
			/* join mediaitems */
			mediaitems AS mediaitem ON (mediaitem.id = rel.mediaitem_id)
		LEFT JOIN
			ratings AS rating
			/* important: only select data of current user */
				ON (rating.mbid = mediaitem.mb_trackid AND rating.mediaitemtype = 0 AND /* #arguments.securitycontext.userid# */ rating.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
				
		<!--- include last time access? --->
		<cfif NOT a_bol_field_filter_active OR
				(ListFindNoCase( a_str_fields_to_return, 'lasttime' ) GT 0) OR
				(ListFindNoCase( a_str_fields_to_return, 'times' ) GT 0) OR
				(a_str_info_plistkey IS 'toprated')>
			LEFT JOIN
				timesaccessed AS timesaccessed
					ON (timesaccessed.mediaitemkey = mediaitem.entrykey AND timesaccessed.userid = mediaitem.userid)
		</cfif>
		
	</cfdefaultcase>
</cfswitch>

WHERE

	/* ignore invalid items */
	<!--- (LENGTH( mediaitem.entrykey ) > 0) --->
	(IFNULL( mediaitem.id, 0) > 0)
		AND
	
	<!--- filter by IDs --->
	<cfif bFilterMediaitemIDs>
		(rel.mediaitem_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="0,#arguments.filter.ids#" list="true">))
		AND
	</cfif>
		
	<!--- filter by entrykeys --->
	<cfif a_bol_filter_entrykeys>
		(mediaitem.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.entrykeys#" list="true">))
		AND
	</cfif>
	
	<!--- not the current userkey! --->
	<cfif a_str_info_plistkey IS 'followstream'>
		NOT
		(timesaccessed.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">)
		AND
		<!--- /* select only items of friends */ --->
		(timesaccessed.userid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="0,#GetAllPossibleUseridsForLibraryAccess( arguments.securitycontext )#" list="true">))
		
	
	<cfelse>
		/* use after rel.mediaitem_id because this is the PRIMARY KEY */
		
		<cfif qSelectLibIDs.recordcount IS 1>
			rel.library_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qSelectLibIDs.id#">
			/* #qSelectLibIDs.id# */
		<cfelse>
			rel.library_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="0,#ValueList( qSelectLibIDs.id )#" list="true">)
		</cfif>
	
	</cfif>
	
	
	


<cfswitch expression="#arguments.orderby#">
	<cfcase value="FOLLOWSTREAM">
		ORDER BY
		timesaccessed.lasttime DESC
	</cfcase>
	<cfcase value="RECOMMENDATIONS">
		ORDER BY
		shareditems.dt_created DESC
	</cfcase>
	<cfcase value="ORDERBYPLAYLISTORDER">
		/* order by plistorder */
		ORDER BY
		<cfloop list="#arguments.filter.ids#" index="sOrder">
			NOT (rel.mediaitem_id = #Val( sOrder )#),
		</cfloop>
			(0 = 1)

	</cfcase>
	<cfcase value="RECENTLYPLAYED">
		ORDER BY
		timesaccessed.lasttime DESC
	</cfcase>
	<cfcase value="CREATED">
		ORDER BY
		mediaitem.dt_created DESC
	</cfcase>
	<cfcase value="RATING">
		ORDER BY
		rating.rating DESC,
		timesaccessed.times DESC
	</cfcase>
	<cfcase value="RANDOMIZE">
		ORDER BY
		RAND()
	</cfcase>
	<cfcase value="ARTIST">
		ORDER BY
		mediaitem.artist
	</cfcase>
	<cfcase value="ALBUM">
		ORDER BY
		mediaitem.album
	</cfcase>
	<cfcase value="NAME">
		ORDER BY
		mediaitem.name
	</cfcase>
	<cfcase value="TrackNumber">
		ORDER BY
		mediaitem.TrackNumber
	</cfcase>
	<cfdefaultcase>
		<!--- nothing --->
	</cfdefaultcase>
</cfswitch>
	
<!--- limit to a certain number? --->
<cfif Val( arguments.maxrows ) GT 0>
	LIMIT #Val( arguments.maxrows )#
</cfif>
;
</cfquery>

<cfquery name="local.qSelectNumberOwnTracks" datasource="mytunesbutleruserdata">
SELECT #sSQLVarOwnTracks# AS iOwnTracksCount;
</cfquery>

<!--- create unique table with index --->
<cfif a_bol_create_uniquetable>
	
	<!--- find out unique artists --->
	<cfquery name="q_select_distinct_artists" dbtype="query">
	SELECT
		artist,
		mb_artistid
	FROM
		q_select_mediaitems
	GROUP BY
		mb_artistid,artist
	;
	</cfquery>	
	
	<!--- return artists --->
	<cfset a_struct_unique_table.artists = q_select_distinct_artists />
	
	<!--- unique albums --->
	<cfquery name="q_select_distinct_albums" dbtype="query">
	SELECT
		album,
		mb_albumid
	FROM
		q_select_mediaitems
	GROUP BY
		mb_albumid,album
	;
	</cfquery>	
	
	<!--- return albums --->
	<cfset a_struct_unique_table.albums = q_select_distinct_albums />
	
	<cfset a_str_col_list = q_select_mediaitems.columnlist />
	
	<!--- if the list contains items which are not requested and which have been added temporarely, remove them again --->
	<cfif ListFindNoCase( a_str_temp_cols_remove_later, 'librarykey')>
		<cfset a_str_col_list = ListDeleteAt( a_str_col_list, ListFindNoCase( a_str_col_list, 'librarykey')) />
	</cfif>
	
	<cfif ListFindNoCase( a_str_temp_cols_remove_later, 'genre')>
		<cfset a_str_col_list = ListDeleteAt( a_str_col_list, ListFindNoCase( a_str_col_list, 'genre')) />	
	</cfif>
	
	<cfif ListFindNoCase( a_str_temp_cols_remove_later, 'artist')>
		<cfset a_str_col_list = ListDeleteAt( a_str_col_list, ListFindNoCase( a_str_col_list, 'artist')) />		
	</cfif>
	
	<cfif ListFindNoCase( a_str_temp_cols_remove_later, 'album')>
		<cfset a_str_col_list = ListDeleteAt( a_str_col_list, ListFindNoCase( a_str_col_list, 'album')) />		
	</cfif>
		
	<!--- remove columns from original query --->
	<cfif Len( a_str_temp_cols_remove_later ) GT 0>
		
		<cfquery name="q_select_mediaitems" dbtype="query">
		SELECT
			#a_str_col_list#
		FROM
			q_select_mediaitems
		;
		</cfquery>
		
	</cfif>

</cfif>

<!--- create information about linked items --->
<cfif a_bol_create_link_tables>
	
	<!--- distinct genres --->
	<cfquery name="q_select_distinct_genres" dbtype="query">
	SELECT
		DISTINCT( genre )
	FROM
		q_select_mediaitems
	;
	</cfquery>
	
	<!--- set index for genre --->
	<cfloop query="q_select_distinct_genres">
		<cfset a_struct_genres[ q_select_distinct_genres.genre ] = q_select_distinct_genres.currentrow />
	</cfloop>
	
	<!--- distinct artists --->
	<cfquery name="q_select_distinct_artists" dbtype="query">
	SELECT
		DISTINCT( artist ),
		0 AS idx
	FROM
		q_select_mediaitems
	;
	</cfquery>
	
	<!--- generate unique struct --->
	<cfloop query="q_select_distinct_artists">
		<cfset a_struct_artists[ q_select_distinct_artists.artist ] = q_select_distinct_artists.currentrow />
		
		<!--- index = row --->
		<cfset querySetCell( q_select_distinct_artists, 'idx', q_select_distinct_artists.currentrow, q_select_distinct_artists.currentrow  ) />
	</cfloop>
	
	<cfquery name="q_select_distinct_albums" dbtype="query">
	SELECT
		DISTINCT( album ),
		0 AS idx
	FROM
		q_select_mediaitems
	;
	</cfquery>
	
	<cfloop query="q_select_distinct_albums">
		<cfset a_struct_albums[ q_select_distinct_albums.album ] = q_select_distinct_albums.currentrow />
		<!--- current row = idx --->
		<cfset querySetCell( q_select_distinct_albums, 'idx', q_select_distinct_albums.currentrow, q_select_distinct_albums.currentrow  ) />
	</cfloop>
	
	<!--- loop over mediaitems and set data --->
	<cfloop query="q_select_mediaitems">
		
		<cfset querySetCell( q_select_mediaitems, 'idxgenre', a_struct_genres[ q_select_mediaitems.genre ], q_select_mediaitems.currentrow ) />
		
		<cfif StructKeyExists( a_struct_artists, q_select_mediaitems.artist)>
			<cfset querySetCell( q_select_mediaitems, 'idxartist', a_struct_artists[ q_select_mediaitems.artist ], q_select_mediaitems.currentrow ) />
		<cfelse>
			<!--- not found, must be invalid ... set to zero --->
			<cfset querySetCell( q_select_mediaitems, 'idxartist', 0, q_select_mediaitems.currentrow ) />
		</cfif>
		
		<cfset querySetCell( q_select_mediaitems, 'idxalbum', a_struct_albums[ q_select_mediaitems.album ], q_select_mediaitems.currentrow ) />
	
	</cfloop>
	
	
</cfif>