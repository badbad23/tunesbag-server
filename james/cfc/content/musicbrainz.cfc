<!--- //

	Module:		MusicBrainz Component
	Action:		
	Description:	
	
// --->

<cfcomponent displayName="Cache" hint="do caching" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.musicbrainz" output="false">
		<cfreturn this />
	</cffunction>
	
<cffunction access="public" name="StoreCalculatedPUIDData" output="false" returntype="struct">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="puid" type="string" required="true">
	
	<cfset var q_update_set_calculated_puid = 0 />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'mediaitems.mediaitem', arguments.mediaitemkey ) />
	<cfset var a_sec_context = 0 />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<!--- wrong puid (elvis ...) --->
	<cfif arguments.puid IS '6d45902a-f494-d496-1dbc-945b66b0ee40'>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfinclude template="queries/mb/q_update_set_calculated_puid.cfm">
	
	<!--- check if we can auto-correct this item  --->
	<cfif a_item.getIsPersisted()>
		
		<cfset a_sec_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( a_item.getuserkey() ) />

		<!--- try to autofix data --->		
		<cfset stReturn.autofix = AutoFixMetaInformationByPUIDMatch( securitycontext = a_sec_context, mediaitemkey = arguments.mediaitemkey ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	<cfelse>	
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />	
	</cfif>
	
</cffunction>

<cffunction access="public" name="getCloseTrackMatchesByPUID" returntype="struct" hint="use puid and return possible tracks">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="mb_identifier" type="string" required="false" default=""
		hint="only return a certain hit (search by it's identifier (hash(artist.id, album.id, track.id))')">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_puid_possible_tracks = 0 />
	<cfset var q_select_further_possible_tracks = 0 />
	<cfset var q_select_puid_all_possible_tracks = 0 />
	<cfset var oTransfer = application.beanFactory.getBean('ContentTransfer').getTransfer() />
	<cfset var a_source_puid = oTransfer.get( 'mediaitems.mediaitem', arguments.mediaitemkey ).getPUID() />

	<cfset stReturn.source_puid = a_source_puid />

	<cfif Len( arguments.mediaitemkey ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfinclude template="queries/mb/q_select_puid_possible_tracks.cfm">
	
	<!--- <cfset stReturn.q_select_puid_possible_tracks = q_select_puid_possible_tracks /> --->
	<cfset stReturn.q_select_further_possible_tracks = q_select_further_possible_tracks />
		
	<!--- perform real query --->
	<cfinclude template="queries/mb/q_select_puid_all_possible_tracks.cfm">
	
	<cfset stReturn.q_select_puid_all_possible_tracks= q_select_puid_all_possible_tracks />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="AutoFixMetaInformationByPUIDMatch" returntype="struct" output="false"
		hint="Automatically fix information if possible for a certain item">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="mediaitemkey" type="string" required="true"
		hint="list of media item keys">
	<cfargument name="mb_identifier" type="string" required="false" default=""
		hint="musicbrainz identifier of hit to apply to this track ... in case if empty will try to automatically match 100% result">
	<cfargument name="options" type="string" required="false" default=""
		hint="options ... AUTOFIX_FULL_STRING_HIT will fix even in case we've just a string hit and no perfect hit">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_possible_data = getCloseTrackMatchesByPUID( securitycontext = arguments.securitycontext,
					mediaitemkey = arguments.mediaitemkey,
					mb_identifier = arguments.mb_identifier ) />
	<cfset var q_select_possible_hits = 0 />
	<cfset var a_struct_update = {} />
	<cfset var a_update_result = 0 />
	<cfset var oTransfer = application.beanFactory.getBean('ContentTransfer').getTransfer() />
	<cfset var a_mediaitem = oTransfer.get( 'mediaitems.mediaitem', arguments.mediaitemkey ) />
	
	<cfif NOT a_struct_possible_data.result>
		<cfreturn a_struct_possible_data />
	</cfif>
	
	<cfset q_select_possible_hits = a_struct_possible_data.q_select_puid_all_possible_tracks />
	
	<!--- return possible data struct --->
	<cfset stReturn.a_struct_possible_data = a_struct_possible_data />
	
	<!--- no hit? --->
	<cfif q_select_possible_hits.recordcount IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- we've an ID we should use OR we've a full hit OR a string hit is enough OR we've a partial hit PLUS an currently custom track! --->
	<cfif Len( arguments.mb_identifier ) GT 0 OR
		  q_select_possible_hits.full_hit IS 1 OR
		  (q_select_possible_hits.full_string_hit IS 1 AND ListFindNoCase(arguments.options, 'AUTOFIX_FULL_STRING_HIT') GT 0) OR
		  (q_select_possible_hits.STRING_HIT_ARTIST_TRACK IS 1 AND ListFindNoCase(arguments.options, 'AUTOFIX_ARTIST_TRACK_HIT') GT 0) OR
		  	
		  		(
		  			(q_select_possible_hits.string_hit_artist_start_track IS 1)
		  			AND
		  			(ListFindNoCase( arguments.options, 'EXTREME_AUTOFIX_ARTIST_STARTTRACK_HIT') GT 0)
		  			AND
		  			(a_mediaitem.getmb_trackid() GT 100000000)
		  		)>
		
		<!--- artist --->
		<cfif Len( q_select_possible_hits.mb_artist ) GT 0>
			<cfset a_struct_update.artist = q_select_possible_hits.mb_artist />
		</cfif>
		
		<cfset a_struct_update.mb_artistid = q_select_possible_hits.puid_artistid>
		
		<!--- album --->
		<cfif Len( q_select_possible_hits.mb_album ) GT 0>
			<cfset a_struct_update.album = q_select_possible_hits.mb_album />
		</cfif>
		
		<cfset a_struct_update.mb_albumid = q_select_possible_hits.puid_albumid />
		
		<!--- track --->
		<cfif Len( q_select_possible_hits.mb_name ) GT 0>
			<cfset a_struct_update.name = q_select_possible_hits.mb_name />
		</cfif>
		
		<cfif Val( q_select_possible_hits.puid_trackid ) GT 0>
			<cfset a_struct_update.mb_trackid = q_select_possible_hits.puid_trackid />
		</cfif>
		
		<!--- sequence --->
		<cfset a_struct_update.trackno = q_select_possible_hits.mb_sequence />
		
		<!--- year --->
		<cfif Len( q_select_possible_hits.mb_year ) GT 0>
			<cfset a_struct_update.year = q_select_possible_hits.mb_year />
		</cfif>
		
		<!--- puid checked? yes! --->
		<cfset a_struct_update.puid_analyzed = 1 />
		
		<cfset stReturn.a_struct_update = a_struct_update />
		
		<cfset a_update_result = application.beanFactory.getBean( 'MediaItemsComponent' ).SaveMediaItemInformation( securitycontext = arguments.securitycontext,
											entrykey = arguments.mediaitemkey,
											newvalues = a_struct_update,
											source = 'autoupdate_analysis') />
			
		<cfset stReturn.a_update_result = a_update_result />
			
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cfif>
	
	<!--- no hit, sorry --->
	<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />

</cffunction>

<cffunction access="public" name="AnalyzeDBTrackMetaInfo" output="false" returntype="struct"
		hint="Analyze - FIRST STEP ... Analyze the given track - try to identify & match with musicbrainz DB">
	<cfargument name="entrykey" type="string" required="true">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'mediaitems.mediaitem', arguments.entrykey ) />
	<cfset var a_artist = trim(a_item.getArtist()) />
	<cfset var a_album = trim(a_item.getAlbum()) />
	<cfset var a_title = trim(a_item.getName()) />	
	<!--- the simple versions --->	
	<cfset var a_simple_artist = CleanMediaItemName( input = a_artist, type = 'artist' ) />
	<cfset var a_simple_album = CleanMediaItemName( input = a_album, type = 'album' ) />	
	<cfset var a_simple_title = CleanMediaItemName( input = a_title, type = 'title' ) />
	<cfset var a_totaltime = a_item.getTotalTime() />
	<cfset var a_bol_hit = false />
	<cfset var a_call = 0 />
	<cfset var q_select_artist_exists = 0 />
	<cfset var q_select_album_exists = 0 />
	<cfset var a_int_match_level = 0 />
	<cfset var a_int_wildcard_search_mode = 0 />
	<cfset var a_str_search_title = '' />
	<cfset var a_first_lookup_artist_mbid = 0 />
	<!--- the musicbrainz IDs to store in the end --->
	<cfset var a_mb_artist_id = 1 />
	<cfset var a_mb_album_id = 0 />
	<cfset var a_mb_track_id = 0 />
	<cfset var a_int_possible_artist_ids = 0 />
	<cfset var a_int_possible_album_ids = 0 />
	<cfset var a_struct_search_artist = 0 />
	<cfset var q_select_simple_artist_track = 0 />
	
	<cfset stReturn.data = { artist = a_artist, album = a_album, title = a_title, totaltime = a_totaltime } />
	
	<!--- item exists? --->
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1002 ) />
	</cfif>
	
	<!--- empty artist --->
	<cfif Len( a_artist ) IS 0>
		<!--- 		
			artist = various artist!		
			no album, no track information
		 --->
		<cfset a_mediaitems.SetAnalyzeMBDataForTrack( item = a_item, transfer = oTransfer, mbArtistID = 1, mbAlbumID = 0, mbTrackID = 0 ) />
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1002 ) />
	</cfif>
	
	<!--- artist name given? --->
	<cfif Len( a_artist ) GT 0>
		<!--- search for the artist --->
		<cfset a_struct_search_artist = SearchForArtists( artist = a_artist, searchmode = 0, maxrows = 10, gettags = false ) />
	
		<cfset q_select_artist_exists = a_struct_search_artist.q_select_search_artists />
		
		<cfset stReturn.q_select_artist_exists = q_select_artist_exists />
		
		<!--- the possible IDs for this artist --->
		<cfset a_int_possible_artist_ids = ValueList( q_select_artist_exists.id ) />
		
		<!--- return possible IDs --->
		<cfset stReturn.a_int_possible_artist_ids = a_int_possible_artist_ids />
	
		<!--- no artist found? --->
		<cfif stReturn.q_select_artist_exists.recordcount IS 0>
		
			<cfset stReturn.ADDARTISTNOTEXISTING = true />
		
			<!--- artist does not exist ... we've to create our own artist / album / track information --->
			<cfset a_call = AddUnknownArtist( artist = a_artist )/>
			
			<cfset stReturn.addartist = a_call />
			
			<!--- general error? --->
			<cfif NOT a_call.result>
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1002 ) />
			</cfif>
			
			<!--- use the new created artist ID --->
			<cfset a_int_possible_artist_ids = a_call.id />
		</cfif>
		
		
		<cfset stReturn.a_int_possible_artist_ids_after_add = a_int_possible_artist_ids />
	</cfif>
	
	<!--- continue with album! ... in case we've got the artist PLUS the album name given --->
	<cfif Len( a_artist ) GT 0 AND Len( a_album ) GT 0>
	
		<!--- try to find albums of this artist --->
		<cfset a_call = SearchForAlbums( artists = a_int_possible_artist_ids, album = a_album ) />
		
		<cfset stReturn.AlbumSearch = a_call />
		
		<cfif a_call.result>
			<cfset q_select_album_exists = a_call.q_select_search_albums />
			
			<cfif q_select_album_exists.recordcount GT 0>
				
				<cfset a_int_possible_album_ids = ValueList( q_select_album_exists.id ) />
			
			<cfelse>
			
				<!--- no album exists - might be a compilation ... --->
				<cfset a_call = GetCompilationbyArtistAlbum( artistid = 1, album = a_album ) />
				
				<cfset stReturn.compilation = a_call />
				
				<cfif a_call.recordcount GT 0>
					<cfset a_int_possible_album_ids = ValueList( a_call.id ) />
				</cfif>
			
			</cfif>
		</cfif>

		<!--- set return data --->		
		<cfset stReturn.a_int_possible_album_ids = a_int_possible_album_ids />
		
		<!--- no hit yet, create this album! --->
		<cfif Val( a_int_possible_album_ids ) IS 0>
		
			<!--- call create and use the new ID --->
			<cfset a_call = AddUnknownAlbum( artistid = ListFirst( a_int_possible_artist_ids ), name = a_album )/>
			
			<cfset stReturn.addalbumEx = a_call />
			
			<!--- ok, take the album id --->
			<cfif a_call.result>
				
				<!--- we're creating a new new album! --->
				<cfset a_mb_album_id = a_call.id />
				<cfset a_int_possible_album_ids = a_call.id />
			</cfif>
			
		</cfif>
		
	</cfif>
	
	<!--- last step ... try to find a combination --->
	
	<cfif Len( a_artist ) GT 0 AND Len( a_title ) GT 0>
	
		<!--- case A: we have a single artist, use it! --->
		<cfif ListLen( a_int_possible_artist_ids ) IS 1>
			<cfset a_mb_artist_id = a_int_possible_artist_ids />
		</cfif>
		
		<cfset stReturn.a_int_possible_artist_ids_3_before_track = a_int_possible_artist_ids />
		
		<!--- simple search for track ... does this track exist with this artist at all? --->
		<cfinclude template="queries/analyze/q_select_simple_artist_track.cfm">
		
		<cfset stReturn.q_select_simple_artist_track = q_select_simple_artist_track />
		
		<!--- no album title yet, use the one from the first result and set it! --->
		
	
		<!--- this track does not exist, create it! --->
		<cfif q_select_simple_artist_track.recordcount IS 0>
		
			<cfset a_call = AddUnknownTrack( artistid = ListFirst( a_int_possible_artist_ids ),
								albumid = a_mb_album_id,
								name = a_item.getName(),
								tracklen = a_item.gettotaltime(),
								sequence = Val( a_item.getTrackNumber() ) )/>
								
			<cfset stReturn.addTrack = a_call />
			
			<cfif a_call.result>
				<cfset a_mb_track_id = a_call.id />
			</cfif>
		
		<cfelse>
		
			<!--- take the first one (track) --->
			<cfset a_mb_track_id = q_select_simple_artist_track.track_id />
			
			<!--- take the first one (ARTIST) ... in case it's still the default value of "1" (= various artists) --->
			<cfif (a_mb_Artist_id IS 1)>
				<cfset a_mb_Artist_id = q_select_simple_artist_track.artist />
			</cfif>
			
			<!--- set album in case we've a HIT and still no album --->
			<cfif ((Val( a_mb_album_id ) IS 0) OR (a_mb_album_id GT 100000000)) AND Val( q_select_simple_artist_track.album ) GT 0>
				<cfset a_mb_album_id = q_select_simple_artist_track.album />
			</cfif>
			
			<!--- take the first hit in case we've no result but we've found an album for god sake --->
			<cfif (val( a_mb_album_id ) IS 0 ) AND ListLen( a_int_possible_album_ids) GT 0>
				<cfset a_mb_album_id = ListFirst( a_int_possible_album_ids ) />
			</cfif>
		
		</cfif>
		
	
					
		<!--- define the match level --->
		<cfif ((q_select_simple_artist_track.name IS a_title) AND
			  (q_select_artist_exists.name IS a_artist) AND
			  (a_mb_artist_id LT 100000000) AND
			  (a_mb_track_id LT 100000000 ) AND
			  (a_mb_album_id LT 100000000) AND
			  (q_select_simple_artist_track.lendifference LT 10))>
			  
			<cfset a_int_match_level = 100 />
			
		<cfelseif ((q_select_simple_artist_track.name IS a_title) AND
			  (a_mb_artist_id LT 100000000) AND
			  (a_mb_track_id LT 100000000) AND
			  (q_select_simple_artist_track.lendifference LT 10))>
			
			<cfset a_int_match_level = 80 />
			
		<cfelseif ((q_select_simple_artist_track.name IS a_title) AND
				  (a_mb_track_id LT 100000000) AND
				  (q_select_simple_artist_track.lendifference LT 30))>
				  
			<cfset a_int_match_level = 70 />	
			
		<cfelse>
			<cfset a_int_match_level = 10 />
		</cfif>
	
	<cfelse>
		
		<!--- no track name given, use the album / artist id now --->

		<!--- we've found an artist --->
		<cfif ListLen( a_int_possible_artist_ids ) GT 0>
			<cfset a_mb_artist_id = ListFirst( a_int_possible_artist_ids ) />
		</cfif>
		
		<cfif ListLen( a_int_possible_album_ids ) GT 0>
			<cfset a_mb_album_id = ListFirst( a_int_possible_album_ids ) />
		</cfif>
	
	</cfif>
	
	<cfset stReturn.data.mb_match_level = a_int_match_level />
	<cfset stReturn.data.mb_artist = a_mb_Artist_id />
	<cfset stReturn.data.mb_album_id = a_mb_album_id />
	<cfset stReturn.data.mb_track_id = a_mb_track_id />		
	
	<!--- store data --->
	<cfset a_mediaitems.SetAnalyzeMBDataForTrack( item = a_item, transfer = oTransfer,
						mbMatchlevel = a_int_match_level,
						mbArtistID = Val(a_mb_artist_id),
						mbAlbumID = Val(a_mb_album_id),
						mbTrackID = Val(a_mb_track_id) ) />
	
	<!--- return result --->
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>
	
<cffunction access="public" name="getTrackInformation" output="false" returntype="query" hint="return track information">
	<cfargument name="trackid" type="numeric" required="true">
	
	<cfset var q_select_track = 0 />
	<cfset var q_select_basic_track_information = 0 />
	
	<cfinclude template="queries/mb/q_select_track.cfm">
	
	<cfreturn q_select_track />	
</cffunction>

<cffunction access="public" name="qSelectSimpleTrackArtistRelation" output="false" returntype="struct">
	<cfargument name="iTrackID" type="numeric" required="true" />

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var qSelectSimpleTrackArtistRelation = 0 />
	
	<cfinclude template="queries/mb/q_select_track_artist_rel.cfm">
	
	<cfset stReturn.qSelectSimpleTrackArtistRelation = qSelectSimpleTrackArtistRelation />
	
	<cfif NOT qSelectSimpleTrackArtistRelation.recordcount IS 1>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404) />
	<cfelse>
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />	
	</cfif>
	
</cffunction>

<cffunction access="public" name="GetCompilationbyArtistAlbum" output="false" returntype="query" hint="check if a compilation exists">
	<cfargument name="artistid" type="numeric" required="false">
	<cfargument name="album" type="string" required="true"
		hint="name of the album">
		
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	<cfset var a_map = { artist = arguments.artistid, name = arguments.album } />
	
	<cfreturn oTransfer.listByPropertyMap( 'alben.album', a_map ) /> />	

</cffunction>

<cffunction access="public" name="GetCompilationItemsOfArtist" output="false" returntype="query"
		hint="return compilations with the tracks of this artist">
	<cfargument name="artistid" type="numeric" required="true">
	
	<cfset var q_select_compilations_of_artist = 0 />
	<cfinclude template="queries/mb/q_select_compilations_of_artist.cfm">

	<cfreturn q_select_compilations_of_artist />
	
</cffunction>

<cffunction access="public" name="getSimpleAlbumMetaInfoByAlbumID" output="false" returntype="any" hint="return album meta info by it's ID">
	<cfargument name="albumid" type="numeric" required="true">
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	
	<cfreturn oTransfer.get( 'alben.albummeta', arguments.albumid ) />
	
</cffunction>
	
<cffunction access="public" name="GetAlbumsOfArtist" output="false" returntype="query">
	<cfargument name="artistid" type="numeric" required="true">
	<cfargument name="mbdataonly" type="boolean" default="true">
	
	<cfset var q_select_artist_alben = 0 />
	<cfset var local = {} />
	<cfinclude template="queries/mb/q_select_artist_alben.cfm">
	
	<cfreturn q_select_artist_alben />
</cffunction>
	
<cffunction access="public" name="ReturnAlbumTracks" output="false" returntype="query" hint="return all tracks of an album">
	<cfargument name="mbAlbumID" type="numeric" required="true">
	
	<cfset var q_select_album_tracks = 0 />	
	
	<!--- valid? --->
	<cfif Val( arguments.mbAlbumID ) IS 0>
		<cfset arguments.mbAlbumID = -1 />
	</cfif>
	
	<cfinclude template="queries/mb/q_select_album_tracks.cfm">
	
	<cfreturn q_select_album_tracks />

</cffunction>
	
<cffunction access="public" name="GetAlbumsByID" output="false" returntype="struct" hint="search for albums">
	<cfargument name="albumids" type="numeric" required="true">
	<cfargument name="bIgnoreCustomAlbums" type="boolean" default="false"
		hint="ignore the custom added albums" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_albums_by_ids = 0 />
	
	<cfinclude template="queries/mb/q_select_albums_by_ids.cfm">
	
	<cfset stReturn.q_select_albums_by_ids = q_select_albums_by_ids />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="SearchForAlbums" output="false" returntype="struct" hint="search for albums of a certain artists">
	<cfargument name="artists" type="string" required="true"
		hint="IDs of artists">
	<cfargument name="album" type="string" required="true"
		hint="album search string">
	<cfargument name="searchmode" type="numeric" default="0" required="true"
		hint="which search mode? 0 = exactly, 1 = LIKE artist%">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_search_albums = 0 />

	<cfinclude template="queries/mb/q_select_search_albums.cfm">
	
	<cfset stReturn.q_select_search_albums = q_select_search_albums />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
</cffunction>
	
<cffunction access="public" name="SearchForArtists" output="false" returntype="struct" hint="search for artists">
	<cfargument name="artist" type="string" required="true"
		hint="artist search string">
	<cfargument name="mbids" type="numeric" default="-1" required="false"
		hint="get the artists by it's MBIDs ... if not -1, then use this value">
	<cfargument name="mbgids" type="string" required="false" default=""
		hint="get artists by it's MBGIDs (string) ... use if not empty">
	<cfargument name="searchmode" type="numeric" default="0" required="true"
		hint="which search mode? 0 = exactly, 1 = LIKE artist%" />
	<cfargument name="bLoadBio" type="boolean" default="false" required="false"
		hint="Load english biography?" />
	<cfargument name="gettags" type="boolean" default="false" required="false"
		hint="load tag list as well">
	<cfargument name="maxrows" type="numeric" default="20" required="false"
		hint="max number of records to return">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_search_artists = 0 />
	<cfset var a_search_simple_string = CleanMediaItemName( input = arguments.artist, type = 'artist' ) />
	<cfset var a_sql_op = '=' />
	<cfset var a_search_string = arguments.artist />
	<cfset var q_select_possible_alias_items = 0 />
	<cfset var q_select_test_exact_match = 0 />
	<cfset var a_bol_exact_match = false />
	
	<!--- create dummy search string if empty string provided to return zero results? --->
	<cfif Len( a_search_string ) IS 0 AND arguments.mbids IS -1>
		<cfset a_search_string = 'dummystringdoesnotexist' />
	</cfif>
	
	<cfif Len( a_search_simple_string ) IS 0>
		<cfset a_search_simple_string = 'dummystringdoesnotexist' />
	</cfif>
	
	<!--- soft search, not exactly the term is needed --->
	<cfif arguments.searchmode IS 1>
		<cfset a_search_string = a_search_string & '%' />
		<cfset a_search_simple_string = a_search_simple_string & '%' />
		<cfset a_sql_op = 'LIKE' />
	<cfelse>
	
		<!--- test for exact hit in out core db --->
		<cfif Len( a_search_string ) GT 0>
			
			<cfinclude template="queries/mb/q_select_test_exact_match.cfm">
			
			<cfset stReturn.q_select_test_exact_match = q_select_test_exact_match />
			
			<!--- exact hit? --->
			<cfset a_bol_exact_match = (q_select_test_exact_match.recordcount IS 1) />
			
		</cfif>
	
	</cfif>
	
	<cfinclude template="queries/mb/q_select_search_artists.cfm">
	
	<cfset stReturn.q_select_search_artists = q_select_search_artists />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="SearchForTracks" output="false" returntype="struct" hint="search for tracks">
	<cfargument name="name" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_search_tracks = 0 />
	
	<cfinclude template="queries/content/q_select_search_tracks.cfm">
	
	<cfset stReturn.q_select_search_tracks = q_select_search_tracks />
	
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
</cffunction>

<cffunction name="getArtistNameByID" access="public" returntype="string" hint="return artist name by it's ID">
	<cfargument name="mbid" type="numeric" required="true">
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	
	<cfreturn oTransfer.get( 'artists.artist', arguments.mbid ).getName() />
	
</cffunction>

<cffunction name="GetArtistInformation" access="public" output="false" returntype="struct" hint="Return a certain artist item">
	<cfargument name="artist" type="string" required="true">
	<cfargument name="musicbrainzid" type="string" required="false"
		default="" hint="optional ... the mbid">
	<cfargument name="loadalbums" type="boolean" required="false" default="false"
		hint="Return list of albums as well?">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />	
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	
	<cfset var q_select_artist = 0 />
	<cfset var a_artist_id = 0 />
	
	<!--- query --->
	<cfset q_select_artist = oTransfer.listByProperty( 'artists.artist', 'name', arguments.artist ) />
	
	<!--- get first id --->
	<cfset a_artist_id = Val( q_select_artist.id ) />
	
	<cfif a_artist_id IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfset stReturn.q_select_artist = q_select_artist />
	
	<!--- load albums? --->
	<cfif arguments.loadalbums IS 1>
		<cfset stReturn.q_select_albums = oTransfer.listByProperty( 'alben.album', 'artist', a_artist_id ) />
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>


<cffunction access="public" name="AddUnknownTrack" output="false" returntype="struct" hint="Add information about an unknown track">
	<cfargument name="artistid" type="numeric" required="true"
		hint="id of artist">
	<cfargument name="albumid" type="numeric" required="true"
		hint="albumid">
	<cfargument name="name" type="string" required="true"
		hint="name of track">
	<cfargument name="tracklen" type="numeric" required="true"
		hint="length of track">
	<cfargument name="sequence" type="numeric" required="false" default="0"
		hint="seq">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	<cfset var a_existing = { artist = arguments.artistid, name = arguments.name, length = arguments.tracklen } />
	<cfset var a_id = 0 />
	<cfset var a_id_albumjoin = 0 />
	<cfset var a_gid = lcase( createUUID() ) />
	<cfset var oTransferExtContent = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
	<cfset var q_select_existing_tracks = oTransferExtContent.listByPropertyMap( 'mbcustom.trackcust', a_existing ) />
	<cfset var q_insert_new_track = 0 />
	<cfset var q_select_new_track_min_id = 0 />
	<cfset var q_select_max_albumjoin = 0 />
	<cfset var q_insert_albumjoin = 0 />
	
	<cfif q_select_existing_tracks.recordcount GT 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfinclude template="queries/mb/q_select_new_track_max_id.cfm">
	
	<cfset a_id = Val( q_select_new_track_max_id.max_id ) + 1 />
	
	<cfif a_id LT 100000001>
		<cfset a_id = 100000001 />
	</cfif>
	
	<!--- insert into track table --->
	<cfinclude template="queries/mb/q_insert_new_track.cfm">
	
	<!--- insert into albumjoin table --->
	<cfinclude template="queries/mb/q_insert_albumjoin.cfm">
	
	<cfset stReturn.id = a_id />
	<cfset stReturn.gid = a_gid />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>


<cffunction access="public" name="AddUnknownAlbum" output="false" returntype="struct" hint="add information about an unknown album">
	<cfargument name="artistid" type="numeric" required="true"
		hint="id of the artist">
	<cfargument name="name" type="string" required="true"
		hint="name of album">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	<cfset var a_existing = { artist = arguments.artistid, name = arguments.name } />
	<cfset var q_select_existing_albums = oTransfer.listByPropertyMap( 'alben.album', a_existing ) />
	<cfset var oTransferUserdata = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
	<cfset var q_select_existing_albums_cust = oTransferUserdata.listByPropertyMap( 'mbcustom.albumcust', a_existing ) />
	<cfset var a_id = 0 />
	<cfset var q_insert_new_album = 0 />
	<cfset var q_insert_new_release = 0 />
	<cfset var a_gid = lcase(CreateUUID()) />
	<cfset var q_select_new_album_max = 0 />
	
	<cfset arguments.name = Trim( arguments.name ) />
	
	<cfif Len( arguments.name ) IS 0 OR arguments.artistid IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- already exists? --->
	<cfif q_select_existing_albums.recordcount GT 0 OR q_select_existing_albums_cust.recordcount GT 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfinclude template="queries/mb/q_select_new_album_max.cfm">
	
	<cfset a_id = Val( q_select_new_album_max.max_id ) + 1 />
	
	<!--- make sure it's negative --->
	<cfif a_id LT 100000001>
		<cfset a_id = 100000001 />
	</cfif>
	
	<cfinclude template="queries/mb/q_insert_new_album.cfm">
	
	<cfset stReturn.gid = a_gid />
	<cfset stReturn.id = a_id />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>
	
<cffunction access="public" name="AddUnknownArtist" output="false" returntype="struct" hint="add information about an unknown artist">
	<cfargument name="artist" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
	<cfset var oTransferContent = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
	<!--- try to search for artist first --->
	<cfset var q_select = 0 />
	<cfset var a_item = 0 />
	<cfset var a_id = 0 />
	<cfset var a_gid = lcase(CreateUUID()) />
	<cfset var a_name_simple = '' />
	<cfset var a_sortname = '' />
	<cfset var q_select_new_artist_max_id = 0 />
	<cfset var a_insert_new_artist = 0 />
	
	<cfset arguments.artist = Trim( arguments.artist ) />
	
	<cfif Len( arguments.artist ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfset oTransfer.discardAll() />
	<cfset q_select = oTransferContent.listByProperty( 'mbcustom.artistcust', 'name', arguments.artist ) />
	
	<!--- artists already exists --->
	<cfif q_select.recordcount GT 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>

	<!--- ok, now generate various important data ... --->
	
	<!--- insert with a positive ID higher than 1mio (=temporary) --->

	<!--- bug created for this: https://tunesbagdev.fogbugz.com/default.asp?444 (feature request) --->
	<cflock name="lckInsertNewArtist" timeout="15" type="exclusive">
		<cfinclude template="queries/mb/q_select_new_artist_max_id.cfm">
		
		<!--- the new ID --->
		<cfset a_id = Val(q_select_new_artist_max_id.max_id) + 1 />
		
		<!--- make sure we have a negative value --->
		<cfif a_id LT 100000001>
			<cfset a_id = 100000001 />
		</cfif>
		
		<cfinclude template="queries/mb/q_insert_new_artist.cfm">
	</cflock>
	
	<cfset stReturn.gid = a_gid />
	<cfset stReturn.id = a_id />

	<!--- log this --->	
	<cflog application="false" file="tb_mb_cust" text="Added Artist #arguments.artist# with ID #a_id#" type="information" />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>


<cffunction access="private" name="CleanMediaItemName" returntype="string" output="false" hint="check and clean the name">
	<cfargument name="input" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="artist,album,title">
	
	<cfset var s = Trim( arguments.input ) />
	
	<!--- Hot Summer  (Radio Edit) --->
	<cfset s = ReplaceNoCase(s, '  ', ' ', 'ALL' ) />
	
	<cfif Len( s ) IS 0>
		<cfreturn s />
	</cfif>
	
	<!--- [Aromabar feat. Klangwirkstoff] ... braket right at the beginning--->
	<cfif Left( s, 1 ) IS '['>
		<cfset s = Mid( s, 2, Len( s )) />
	</cfif>
	
	<cfif Len( s ) IS 0>
		<cfreturn s />
	</cfif>
	
	<cfif Right( s, 1 ) IS ']'>
		<cfset s = Mid( s, 1, Len( s ) - 1) />
	</cfif>	
	
	
	<cfif arguments.type IS 'artist'>
		
		<!--- Alice Russell feat Natureboy --->
		
		<cfset s = ReReplaceNoCase( s, ' feat [a-z,0-9, ,-,_,\.,&]*', '' ) />
		<cfset s = ReReplaceNoCase( s, ' feat. [a-z,0-9,_, ,-,\.,&]*', '' ) />
		<cfset s = ReReplaceNoCase( s, ' ft. [a-z,0-9, ,-,_,\.,&]*', '' ) />
		<cfset s = ReReplaceNoCase( s, ' ft [a-z,0-9, ,-,_,\.,&]*', '' ) />
		
		<!--- Alice Russell [feat Natureboy] --->
		<cfset s = ReReplaceNoCase( s, '\[[^\]]*\]', '',  'ALL') />
		
		<!--- people's choice NOT ACTIVE, too much noise --->
		<!--- <cfset s = ReplaceNoCase( s, '''', '',  'ALL') /> --->
		
		<!--- LAST STEP FINALLY - Just return 0-9, A-Z --->
		<cfset s = ReReplaceNoCase( s, '[^a-z,0-9]*', '', 'ALL') />
		
	</cfif>
	
	<cfif arguments.type IS 'title'>
		<!--- special treatment --->
		
		<!--- 03 - Lovebox --->
		<cfset s = Trim( ReReplaceNoCase( s, '^[0-9]* -', '', 'ONE' )) />
		
		<!--- 16 Again --->
		<cfset s = Trim( ReReplaceNoCase( s, '^[0-9]* ', '', 'ONE' )) />
		
		<!--- Clandestino - 01   --->
		<cfset s = Trim( ReReplaceNoCase( s, '- [0-9]*$', '', 'ONE' )) />
		
		<!--- Lovebox.mp3 --->
		<cfset s = ReplaceNoCase( s, '.mp3', '' ) />	
		
		<!--- [ft. etc] --->
		<cfset s = ReReplaceNoCase( s, '\[[^\]]*\]', '',  'ALL') />
		
		<!--- (ft. etc) --->
		<cfset s = ReReplaceNoCase( s, '\([^\)]*\)', '',  'ALL') />
		
		<!--- I Feel It All (Britt from Spoo ... just beginning bracket but no end one --->
		<cfif FindNoCase( '(', s ) GT 3 AND FindNoCase( ')', s ) IS 0>
			<cfset s = Left( s, FindNoCase( '(', s ) - 1 ) />
		</cfif>
		
		<!--- Indigo Blues With Nicole Graham --->
		<cfset s = ReReplaceNoCase( s, ' with [a-z, ]*', '', 'ALL') />
		
		<!--- One More Time / Aerodynamic /  --->
		<cfset s = ReReplaceNoCase( s, '/$', '' ) />
				
		<!--- LAST, FINAL STEP - clean out ., space etc --->
		<cfset s = ReReplaceNoCase( s, '[ ,\.,\?,'',-]*', '', 'ALL' ) />
		
	</cfif>
	
	<cfreturn Trim( s ) />
</cffunction>

</cfcomponent>