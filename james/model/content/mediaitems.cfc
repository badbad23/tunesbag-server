<!--- //

	Module:		Handle media items of user
	Description:Mach-II frontend CFC
	
// --->

<cfcomponent name="mediaitmes" displayname="Media items component"output="false" extends="MachII.framework.Listener" hint="Handle media items">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction name="FindSimilarArtists" access="public" output="false" returntype="void" hint="Store log information in database">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 

</cffunction>

<cffunction access="public" name="PerformGlobalSearch" output="false" returntype="void" hint="perform a public search">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_search = trim( event.getArg( 'search' )) />
	<cfset var a_search_artists =  0 />
	<cfset var a_search_albums = 0 />
	<cfset var a_search_tracks = 0 />
	
	<cfif Len( a_search ) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- search for artists --->
	<cfset a_search_artists = getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).SearchForArtists( artist = a_search, searchmode = 1 ) />
	<cfset event.setArg( 'search_artists', a_search_artists ) />
	
	<!--- search for tracks --->
	<cfset a_search_tracks = getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).SearchForTracks( name = a_search ) />
	<cfset event.setArg( 'search_tracks', a_search_tracks ) />
	
	
	<!--- search for users --->
	<cfset event.setArg( 'search_users', getProperty( 'beanFactory' ).getBean( 'UserComponent' ).SearchForUsers( search = a_search )) />
	
	<!--- search for albums --->
	
	<!--- search for playlists --->
	<cfif application.udf.GetCurrentSecurityContext().rights.playlist.radio IS 1>
		<cfset event.setArg( 'search_playlists', getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).SearchForPlaylists(
					securitycontext = application.udf.GetCurrentSecurityContext(),
					artist_ids = ValueList( a_search_artists.q_select_search_artists.id ),
					track_ids = ValueList( a_search_tracks.q_select_search_tracks.id ),
					search = a_search )) />
	</cfif>
	<!--- search for tracks --->

</cffunction>

<cffunction name="LookupItem" access="public" output="false" returntype="void" hint="Perform a look for a certain item (search)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_artist = event.getArg( 'artist' ) />
	<cfset var a_str_name = event.getArg( 'name' ) />	
	<cfset var a_search_result = 0 />
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	<cfset var a_str_search_criteria = 'ARTIST?VALUE=' & a_str_artist & '|' &  'NAME?VALUE=' & a_str_name & '' />
		
	<!--- search through the own library --->
	<cfset a_search_result = a_cmp_mediaitems.GetUserContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
					search_criteria = a_str_search_criteria,
					librarykeys =  a_cmp_mediaitems.GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) ) />
								
	<cfset event.setArg( 'a_search_result', a_search_result) />
	
	<!--- search on youtube ... --->
	
	
</cffunction>

<cffunction name="DoCreateSmartPlaylist" access="public" output="false" returntype="void"
		hint="Collect data and return custom station">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_criteria = '' />
	<cfset var bCriteriaMBArtistid = event.getArg( 'mbArtistIDs' ) NEQ '' />
	<cfset var a_bol_criteria_genres_exist = event.getArg( 'genres', '') NEQ '' />
	<cfset var a_bol_criteria_surprise_exist = event.getArg( 'surprise', '') NEQ '' />
	<cfset var a_bol_critiera_librarykeys_exist = event.getArg( 'librarykeys', '') NEQ '' />
	<cfset var a_bol_criteria_tags_exist = event.getArg( 'tags', '') NEQ '' />
	<cfset var a_bol_criteria_moods_exist = event.getArg( 'moods', '') NEQ '' />
	<cfset var a_struct_dynamic_playlist = StructNew() />
	<cfset var a_struct_result_create_plist = StructNew() />
	<cfset var a_str_new_plist_key = '' />
	<cfset var a_cmp_media = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
	<!--- max age of track --->
	<cfset var bMaxAgeDays = Val( event.getArg( 'maxagedays') ) NEQ 0 />
	
	<!--- add criteria --->
	<cfif a_bol_criteria_genres_exist>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'GENRES?VALUE=' & htmleditformat( event.getArg( 'genres') ), '|' ) />
	</cfif>
	
	<cfif a_bol_criteria_surprise_exist>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'SURPRISE?VALUE=' & htmleditformat( event.getArg( 'surprise') ), '|' ) />
	</cfif>
	
	<cfif a_bol_critiera_librarykeys_exist>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'LIBRARYKEYS?VALUE=' & htmleditformat( event.getArg( 'librarykeys') ), '|' ) />
	</cfif>	
	
	<cfif a_bol_criteria_tags_exist>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'TAGS?VALUE=' & htmleditformat( event.getArg( 'tags') ), '|' ) />
	</cfif>	
	
	<cfif a_bol_criteria_moods_exist>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'MOODS?VALUE=' & htmleditformat( event.getArg( 'moods') ), '|' ) />
	</cfif>			
	
	<!--- certain artists ... --->
	<cfif bCriteriaMBArtistid>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'MBARTISTIDS?VALUE=' & htmleditformat( event.getArg( 'mbArtistIDs') ), '|' ) />
	</cfif>
	
	<cfif bMaxAgeDays>
		<cfset a_str_criteria = ListAppend( a_str_criteria, 'MAXAGEDAYS?VALUE=' & htmleditformat( event.getArg( 'maxagedays') ), '|' ) />
	</cfif>
		
	<!--- store this new playlist --->
	<cfset a_struct_result_create_plist = a_cmp_media.CreateEditPlaylist(securitycontext = application.udf.GetCurrentSecurityContext(),
										librarykey = '',
										name = CreateUUID(),
										description = CreateUUID(),
										temporary = 1,
										dynamic = 1,
										dynamic_criteria = a_str_criteria) />
	
	<cfset a_str_new_plist_key = a_struct_result_create_plist.entrykey />
	
	<cfset event.setArg( 'newplaylistkey', a_str_new_plist_key) />

</cffunction>

<cffunction name="ReturnPlaylistItems" access="public" output="false" returntype="void" hint="Return a certain playlist (query)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var oPlists = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
	<cfset var sOptions = event.getArg( 'options', 'logaccess' ) />
	<cfset var bPreview = event.getArg( 'preview', false ) />
	<cfset var stPlist = oPlists.ReturnPlaylistItems( securitycontext = application.udf.GetCurrentSecurityContext(),
											playlistkey = event.getArg( 'playlistkey' ),
											options = sOptions,
											preview = bPreview ) />
											
	<cfif NOT stPlist.result>
		<cfreturn />
	</cfif>
	
	<!--- set args --->
	<cfset event.setArg( 'a_struct_playlist' , stPlist.plist_info) />
	
	<cfif StructKeyExists(stPlist, 'q_select_items' )>
		<cfset event.setArg( 'q_select_items' , stPlist.q_select_items) />
	</cfif>
	
	<cfif StructKeyExists(stPlist, 'stLicencePermissions' )>
		<cfset event.setArg( 'stLicencePermissions', stPlist.stLicencePermissions) />
	</cfif>	
	
</cffunction>

<cffunction access="public" name="GetPlaylistComments" output="false" returntype="void" hint="Return playlist comments">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_cmp_comments = getProperty( 'beanFactory' ).getBean( 'CommentsComponent' ) />
	<cfset var a_struct_comments = a_cmp_comments.GetComments( itemtype = 1,
										mediaitemkey = arguments.event.getArg( 'playlistkey' ) ) />
	
	<cfset arguments.event.setArg( 'a_struct_comments', a_struct_comments ) />
	
</cffunction>

<cffunction access="public" name="GetAllPlayablePlaylistForUser" output="false" returntype="void" hint="return all playlists a user can access">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'a_struct_all_plists', getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).GetAllPlayablePlaylistForUser( application.udf.GetCurrentSecurityContext() )) />
	

</cffunction>

<cffunction name="GetUserContentData" access="public" output="false" returntype="void" hint="Return a certain library / playlist database (query)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<!--- lib key --->
	<cfset var a_str_librarykey = arguments.event.getArg( 'librarykey', '' ) />
	<!--- KEYS provided? TOdo: Fix this double args --->
	<cfset var a_str_librarkeys = arguments.event.getArg( 'librarykeys' ) />
	<!--- userkey --->
	<cfset var a_str_userkey = arguments.event.getArg( 'userkey', '' ) />
	<!--- last known lib key (maybe need no data @ all because of no changes ) --->
	<cfset var a_str_lastkey = arguments.event.getArg( 'lastkey', '' ) />
	<!--- library or playlist? --->
	<cfset var a_str_type = arguments.event.getArg( 'type', 'library' ) />
	<!--- calculate the items data (e.g. playlist items)? ... FALSE by default --->
	<cfset var a_bol_calc_item_data = arguments.event.getArg( 'calculateitems', false ) />
	<!--- cmp --->
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	<!--- get data --->
	<cfset var a_struct_get_data = 0 />
	<!--- do we have a valid type? --->
	<cfset var a_bol_valid_types = ListFindNoCase( 'playlists,mediaitems', a_str_type) GT 0 />
	<!--- filter --->
	<cfset var a_filter = {} />
	<!--- options --->
	<cfset var a_str_options = 'generatelinktables' />
	
	<cfif NOT a_bol_valid_types>
		<cfreturn />
	</cfif>
	
	<!--- multiple data provided?! --->
	<cfif Len( a_str_librarkeys ) GT 0>
		<cfset a_str_librarykey = a_str_librarkeys />
	</cfif>
	
	<!---  "special" librarykey? --->
	<cfif a_str_librarykey IS '_all'>
		<cfset a_str_librarykey = a_cmp_mediaitems.GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) />
	</cfif>
	
	<!--- define fields to load --->
	<cfif a_str_type IS 'mediaitems'>
		<!--- lasttime / times removed in order to push performance --->
		<cfset a_filter.fields = 'entrykey,userkey,album,artist,genre,name,yr,librarykey,totaltime,rating,tracknumber,mb_albumid,mb_artistid,customartwork,source' />
	</cfif>
	
	<!--- TODO: IMPROVE SUTFF WITH  generatelinktables --->
	<cfset a_struct_get_data = a_cmp_mediaitems.GetUserContentData(securitycontext = application.udf.GetCurrentSecurityContext(),
										librarykeys = a_str_librarykey,
										lastkey = a_str_lastkey,
										calculateitems = a_bol_calc_item_data,
										type = a_str_type,
										filter = a_filter,
										options = 'generatelinktables' ) />
	<!--- set the items ... --->
	<cfif a_struct_get_data.result>
		
		<cfset event.setArg( 'arSimpleData', BuildJSONOptimzedOutput( sType = a_str_type, qData = a_struct_get_data.q_select_items )) />
		
		<cfset event.setArg('q_select_items', a_struct_get_data.q_select_items) />
		
		<!--- generate list of unique genres? --->
		<cfif (a_str_type IS 'mediaitems')>
			<cfset event.setArg( 'a_struct_unique_genres', a_struct_get_data.a_struct_unique_genres ) />
		</cfif>
		
	</cfif>
	
</cffunction>

<cffunction access="private" name="BuildJSONOptimzedOutput" output="false" returntype="array" hint="produce an output array optimized for the later use with JSON (very small)">
	<cfargument name="sType" type="string" required="true" hint="playlists or mediaitems or friends" />
	<cfargument name="qData" type="query" required="true" />
	
	<cfset var arReturn = ArrayNew( 1 ) />
	
	<cfif arguments.qData.recordcount IS 0>
		<cfreturn arReturn />
	</cfif>
	
	<cfset ArraySet( arReturn, 1, arguments.qData.recordcount, 0 ) />
	
	<cfswitch expression="#arguments.sType#">
		<cfcase value="playlists">
		
		</cfcase>
		<cfcase value="mediaitems">
			
			<cfloop query="qData">
				<cfset arReturn[ qData.currentrow ] = [ qData.entrykey, qData.userkey, qData.album, qData.artist, qData.genre, qData.name, qData.yr, qData.librarykey, qData.totaltime, qData.rating, qData.tracknumber, qData.mb_albumid, qData.mb_artistid, qData.customartwork ] />
			</cfloop>
			
		</cfcase>
	</cfswitch>
	
	<cfreturn arReturn />
</cffunction>

<cffunction access="public" name="SearchUserContentData" output="false" returntype="void"
		hint="search in library">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<!--- lib key --->
	<cfset var a_str_librarykey = arguments.event.getArg( 'librarykey', '' ) />
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	<!--- what to search --->
	<cfset var a_str_search = arguments.event.getArg( 'search', '' ) />
	<!--- area ... when empty, look everywhere, otherwise e.g. ARTIST ALBUM GENRE or such stuff --->
	<cfset var a_str_area = arguments.event.getArg( 'area', 'name' ) />
	
	<cfset var a_str_librarykeys = a_cmp_mediaitems.GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) />
	
	<cfset var a_struct_search = StructNew() />
	<cfset var a_str_criteria = '' />
	
	<!--- build search criteria string --->
	<cfswitch expression="#a_str_area#">
		<cfcase value="name">
			<cfset a_str_criteria = 'NAME' />
		</cfcase>
		<cfcase value="artist">
			<cfset a_str_criteria = 'ARTIST' />
		</cfcase>
		<cfcase value="album">
			<cfset a_str_criteria = 'ALBUM' />
		</cfcase>
		<cfcase value="tag">
			<cfset a_str_criteria = 'TAG' />
		</cfcase>
		<cfcase value="_all">
			<!--- make a common search --->
			<cfset a_str_criteria = 'COMMON_SEARCH' />
		</cfcase>
	</cfswitch>
	
	<cfset a_str_criteria = a_str_criteria & '?VALUE=%' & htmleditformat( a_str_search ) & '%' />
	
	<cfset a_struct_search = a_cmp_mediaitems.GetUserContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
									librarykeys = a_str_librarykeys,
									search_criteria = a_str_criteria ) />
									
	<!--- set the items ... --->
	<cfif a_struct_search.result>
		<cfset event.setArg( 'q_select_items', a_struct_search.q_select_items) />
	</cfif>
	
	<!--- force to use a special, unique ID, not the typical library schema --->
	<cfset event.setArg( 'force_custom_recset_return_id', true ) />	

</cffunction>

<cffunction name="GetUserLibraries" access="public" output="false" returntype="void" hint="Set a list of known libraries">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
</cffunction>

<cffunction access="public" name="SaveMediaItemInfo" output="false" returntype="void" hint="Save information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_bol_stored = event.getArg( 'stored', false ) />
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	<cfset var a_struct_return_edit = StructNew() />
	<cfset var a_struct_new_values = StructNew() />
	
	<cfif a_bol_stored>
		<cfset a_struct_new_values.artist = event.getArg( 'artist' ) />
		<cfset a_struct_new_values.album = event.getArg( 'album' ) />
		<cfset a_struct_new_values.name = event.getArg( 'name' ) />
		<cfset a_struct_new_values.genre = event.getArg( 'genre' ) />
		<cfset a_struct_new_values.year = event.getArg( 'year',  '' ) />
		<cfset a_struct_new_values.comments = event.getArg( 'comments' ) />
		<cfset a_struct_new_values.trackno = event.getArg( 'trackno' ) />
		<cfset a_struct_new_values.rating = event.getArg( 'rating', 0 ) />
		
		<cfset a_struct_return_edit = a_cmp_mediaitems.SaveMediaItemInformation( securitycontext = application.udf.GetCurrentSecurityContext(),
											entrykey = event.getArg( 'entrykey' ),
											newvalues = a_struct_new_values ) />
											
		<cfset event.setArg( 'success', a_struct_return_edit.result) />
	</cfif>

</cffunction>

<cffunction access="public" name="getMediaItemsByEntrykeys" output="false" returntype="void"
		hint="return several items by entrykeys">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var local = {} />
	
	<cfset local.sEntrykeys = event.getArg( 'entrykeys' ) />
	
	<cfif Len( local.sEntrykeys ) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- query only items of user --->
	<cfset local.stData = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
			librarykeys = application.udf.GetCurrentSecurityContext().defaultlibrarykey,
			filter = { entrykeys = local.sEntrykeys } ) />
			
	<cfif local.stData.result>
		<cfset event.setArg( 'qItems', local.stData.q_select_items ) />
	</cfif>
	
</cffunction>

<cffunction name="GetMediaItem" access="public" output="false" returntype="void" hint="Return a certain item">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- entrykey --->
	<cfset var a_str_entrykey = event.getArg('entrykey') />
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />
	<!--- what for do we read this item? READ or EDIT --->
	<cfset var a_str_operation_reason = event.getArg( 'GetMediaItemReason', 'read' ) />
	<!--- are we delivering already? --->
	<cfset var a_bol_deliver_mode = event.getArg( 'deliver_mode' , false ) />
	<!--- source? yt = youtube (when temporarly), tb = tunesbag, stream = stream and so on ... --->
	<cfset var a_source = event.getArg( 'source', 'tb' ) />
	<!--- type? 0 = music, 1 = video --->
	<cfset var a_type = event.getArg( 'type', 0) />
	<!--- target bitrate? --->
	<cfset var a_int_targetbitrate = event.getArg( 'targetbitrate', 0 ) />
	<cfset var a_struct_check_access = 0 />
	<!--- is a preview version requested --->
	<cfset var a_bol_preview = event.getArg( 'preview', false ) />
	<!--- current playlist? --->
	<cfset var a_plistkey = event.getArg( 'playlistkey', '' ) />
	<!--- context --->
	<cfset var a_int_context = Val( event.getArg( 'context' ) ) />
	
	<!--- check the access and get information --->
	<cfset a_struct_check_access = a_cmp_mediaitems.GetMediaItem(securitycontext = application.udf.GetCurrentSecurityContext(),
						entrykey = a_str_entrykey,
						source = a_source,
						type = a_type,
						operation_reason = a_str_operation_reason,
						deliver_mode = a_bol_deliver_mode,
						targetbitrate = a_int_targetbitrate,
						preview = a_bol_preview,
						context = a_int_context,
						options = 'forcestreamingdeliver' ) />

	<cfset arguments.event.setArg( 'found' , a_struct_check_access.result) />
	
	<cfset event.setarg( 'a_struct_check_access', a_struct_check_access ) />
	
	<cfif a_struct_check_access.result>
		
		<!--- set data for further calls --->
		<cfset event.setArg( 'artist', a_struct_check_access.item.getArtist() ) />
		<cfset event.setArg( 'album', a_struct_check_access.item.getAlbum() ) />
		<cfset event.setArg( 'title', a_struct_check_access.item.getName() ) />		
		
		<cfset event.setArg( 'mb_artistid', a_struct_check_access.item.getmb_artistid() ) />
		<cfset event.setArg( 'mb_trackid', a_struct_check_access.item.getMB_trackid() ) />	
		<cfset event.setArg( 'mb_albumid', a_struct_check_access.item.getMB_albumid() ) />	
	
		<cfset arguments.event.setArg( 'a_struct_item' , a_struct_check_access.item) />
		
		<cfif StructKeyExists( a_struct_check_access, 'q_select_access')>
			<cfset arguments.event.setArg( 'q_select_access', a_struct_check_access.q_select_access ) />
		</cfif>
		
		<!--- delivery information available? if yes, set it ... --->
		<cfif a_bol_deliver_mode AND StructKeyExists(a_struct_check_access, 'deliver_info')>
			
			<cfset arguments.event.setArg( 'deliver_info' , a_struct_check_access.deliver_info) />
			<cfset arguments.event.setArg( 'logkey' , a_struct_check_access.logkey) />
			
			<!--- recommendation? set read! --->
			<cfif a_plistkey IS 'recommendations'>
			
				<cfset getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).UpdateRecommendedItemAsRead(
										securitycontext = application.udf.GetCurrentSecurityContext(),
										mediaitemkey = a_str_entrykey ) />
										
			</cfif>
			
		</cfif>
	</cfif>
	
</cffunction>

<cffunction access="public" name="GetFullGenreList" output="false" returntype="void"
		hint="return the full list of known genres">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var q_select_genre_list = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetFullGenreList() />
	
	<cfset event.setArg( 'q_select_genre_list', q_select_genre_list) />
</cffunction>

<cffunction access="public" name="GetPlaylistInformation" output="false" returntype="void" hint="get playlist info (public lists only)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_playlistkey = event.getArg( 'entrykey' ) />
	<cfset var a_cmp_plist = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />
	<cfset var a_struct_filter = { entrykeys = a_str_playlistkey } />
	<cfset var a_bol_check_access = 0 />
	<cfset var a_str_owner_userkey = '' />
	<!--- load plist --->
	<cfset var a_struct_plist = a_cmp_plist.getSimplePlaylistInfo( playlistkey = a_str_playlistkey, loaduserinfo = true, bIgnoreUnIdentifiedTracks = true, bReplaceTrackinfoWithMBInfo = true ) />
	
	<!--- load comments on plist --->
	<cfset var a_cmp_comments = getProperty( 'beanFactory' ).getBean( 'CommentsComponent' ) />
	<cfset var a_struct_comments = a_cmp_comments.GetComments( itemtype = 1,
										mediaitemkey = arguments.event.getArg( 'entrykey' ) ) />
	
	<cfif NOT a_struct_plist.result>
		<cfset event.setArg( 'ThisIsTheError', 'access forbidden') />
		<cfreturn />
	</cfif>
	
	<cfif application.udf.IsLoggedIn()>
		<cfset var stCheckAccess  = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(entrykey = a_str_playlistkey,
							securitycontext = application.udf.GetCurrentSecurityContext(),
							type = 'playlist',
							action = 'read',
							ip = cgi.REMOTE_ADDR ) />
							
		<cfset event.setArg( 'stCheckAccess', stCheckAccess ) />
							
		<cfset a_bol_check_access = stCheckAccess.result />
		
	<cfelse>
		<!--- 
		
			public: playlist has to be public and the user has to set the privacy to 0 (all users can see the playlist)
		
		 --->
		<cfset a_bol_check_access = (a_struct_plist.q_select_simple_plist_info.public IS 1) AND ( a_struct_plist.q_select_simple_plist_info.privacy_playlists IS 0) />
	</cfif>
	
	<cfif NOT a_bol_check_access>
		<cfreturn />
	</cfif>
		
	<cfset event.setArg( 'a_struct_playlist', a_struct_plist) />
							
	<cfset event.setArg( 'a_bol_check_access', a_bol_check_access) />
	
	<cfset arguments.event.setArg( 'a_struct_comments', a_struct_comments ) />	
	
	<!--- load other playlists of this user? --->
	
</cffunction>

<cffunction access="public" name="GetArtistInformation" output="false" returntype="void" hint="Get out some artist information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_artist = event.getArg( 'artist' ) />
	<cfset var a_str_album = event.getArg( 'album' ) />
	<!--- datatypes to load, by default empty = load everything --->
	<cfset var a_str_datatypes = event.getArg( 'datatypes', '' ) />
	
	<cfset var a_struct_artist_information = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getArtistInformationEx( artist = a_str_artist,
					MBartistID = event.getArg( 'mb_artistid', 0),
					datatypes = a_str_datatypes ) />
	
	<cfset event.setArg( 'a_struct_artist_information' , a_struct_artist_information ) />
	
</cffunction>

<cffunction access="public" name="GetTracksOfCertainArtist" output="false" returntype="void" hint="get tracks from certain artists">
	<cfargument name="event" type="MACHII.framework.event" required="true" />
	
	<cfset var a_str_artist = event.getArg( 'artist' ) />
<!--- 	<cfset var a_cmp_media = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).SearchContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
					services = 'ownlibrary',
					search = '') /> --->
	
</cffunction>

<cffunction access="public" name="PlaylistExplore" output="false" returntype="void" hint="Search for playlists">
	<cfargument name="event" type="MACHII.framework.event" required="true" />
	
	<cfset var a_str_tags = event.getArg( 'tags' ) />
	<cfset var a_str_artist = event.getArg( 'artist' ) />
	<cfset var a_Str_album = event.getArg( 'album' ) />
	<cfset var a_str_name = event.getArg( 'name' ) />
	<cfset var a_str_trackname = event.getArg( 'trackname' ) />
	
	


</cffunction>

<cffunction access="public" name="GenerateSelectorInformation" output="false" returntype="void" hint="Return the information needed for the selector system">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- what to generate? --->
	<cfset var a_str_type = event.getArg( 'type' ) />
	
	<!--- current values ... be prepared for multiple items! --->
	<cfset var a_str_cur_genres = event.getArg( 'genres' ) />
	<cfset var a_str_cur_rating = event.getArg( 'rating' ) />
	<cfset var a_str_cur_artists = event.getArg( 'artists' ) />
	<cfset var a_str_cur_albums = event.getArg( 'albums' ) />
	<cfset var a_str_cur_tags = event.getArg( 'tags' ) />
	<cfset var a_str_cur_epoch = event.getArg( 'epoch' ) />
	<cfset var a_str_cur_librarykeys = event.getArg( 'librarykeys' ) />
	
	<cfset event.setArg( 'a_struct_selector', getProperty( 'beanFactory' ).getBean( 'UIComponent' ).GenerateSelectorInformation( type = a_str_type,
					securitycontext = application.udf.GetCurrentSecurityContext(), artists = a_str_cur_artists, albums = a_str_cur_albums, genres = a_str_cur_genres,
					rating = a_str_cur_rating, tags = a_str_cur_tags, epoch = a_str_cur_epoch, librarykeys = a_str_cur_librarykeys )) />
	
</cffunction>

</cfcomponent>