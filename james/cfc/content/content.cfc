<!---

	global content

--->

<cfcomponent output="false" hint="general content routines">

	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.content" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="GetArtistGIDByArtistID" output="false" returntype="string" hint="return the artist GID by it's ID">
		<cfargument name="artistid" type="numeric" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'MBTransfer' ).getTransfer() />
		<cfreturn oTransfer.get( 'artists.artist', arguments.artistid ).getGid() />
	
	</cffunction>
	
	<cffunction access="public" name="GenerateImageSizeVariation" output="false" returntype="struct"
			hint="generate various versions of online image">
		<cfargument name="source" type="string" required="true"
			hint="source filename">
		<cfargument name="destination" type="string" required="true"
			hint="destination filename">
		<cfargument name="height" type="string" required="true"
			hint="desired height, can be empty">
		<cfargument name="width" type="string" required="true"
			hint="desired width, can be empty">		
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var img_source = 0 />
		
		<!--- read the image, resize and store it --->
		<cftry>
			<cfimage action="read" source="#arguments.source#" name="img_source">
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfcatch.Message ) />
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfset ImageResize( img_source, arguments.width, arguments.height, 'highQuality' ) />
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfcatch.Message ) />
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfimage action="write" source="#img_source#" destination="#arguments.destination#" overwrite="true" format="jpeg" />
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfcatch.Message ) />
			</cfcatch>
		</cftry>

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="StoreCustomUserImage" output="false" returntype="struct"
			hint="store a custom image provided by the user">
		<cfargument name="securitycontext" type="struct" required="true" />
		<cfargument name="image_type" type="string" required="true"
			hint="PROFILE, PLAYLIST, BACKGROUND" />
		<cfargument name="identifier" type="string" required="true"
			hint="identify the item" />
		<cfargument name="imgsoure" type="string" required="true"
			hint="filename of image" />
		<cfargument name="licence_type_image" type="numeric" required="false" default="0"
			hint="licence type of image, default = 0, 100 = CC basic" />
		<cfargument name="licence_image_link" type="string" required="false" default=""
			hint="link to original source" />
	
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_img_basedir = application.udf.GetLocalContentDirectory() />
		<cfset var a_str_img_path = '' />
		<cfset var a_str_img_big = '' />
		<cfset var a_str_img_small = '' />
		<cfset var a_struct_update = {} />
		
		<cfif Len( arguments.identifier ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
		</cfif>
		
		<cfif not FileExists( arguments.imgsoure )>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
		</cfif>
		
		<cfswitch expression="#arguments.image_type#">
			<cfcase value="playlist">
				
				<cfset a_str_img_path = a_img_basedir & 'playlist_images/' & Right( arguments.identifier, 3 ) & '/' />
				
				<cfif not DirectoryExists( a_str_img_path )>
					<cfdirectory action="create" directory="#a_str_img_path#">
				</cfif>
				
				<!--- generate some variations --->
				<cfset GenerateImageSizeVariation( source = arguments.imgsoure, destination = a_str_img_path & arguments.identifier & '.1024.jpg', height = '', width = 1024 ) />
				<cfset GenerateImageSizeVariation( source = arguments.imgsoure, destination = a_str_img_path & arguments.identifier & '.300.jpg', height = '', width = 300 ) />				
				<cfset GenerateImageSizeVariation( source = arguments.imgsoure, destination = a_str_img_path & arguments.identifier & '.120.jpg', height = '', width = 120 ) />
				<cfset GenerateImageSizeVariation( source = arguments.imgsoure, destination = a_str_img_path & arguments.identifier & '.75.jpg', height = '', width = 73 ) />
				<cfset GenerateImageSizeVariation( source = arguments.imgsoure, destination = a_str_img_path & arguments.identifier & '.48.jpg', height = '', width = 48 ) />
				
				<!--- update plist db item --->				
				<cfset a_struct_update.imageset = 1 />
				<cfset a_struct_update.licence_type_image = Val( arguments.licence_type_image ) />
				<cfset a_struct_update.licence_image_link = Trim( arguments.licence_image_link ) />
				
				<cfset application.beanFactory.getBean( 'PlaylistsComponent' ).SimplePlaylistEdit( securitycontext = arguments.securitycontext,
									entrykey = arguments.identifier,
									data = a_struct_update ) />
				
				<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			</cfcase>
			<cfdefaultcase>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
			</cfdefaultcase>
		</cfswitch>
		
	
		
		
	</cffunction>
	
	<cffunction access="public" name="HandleCustomTrackArtwork" output="false" returntype="struct" hint="store custom artwork for this track">
		<cfargument name="mediaitemkey" type="string" required="true"
			hint="identification of track">
		<cfargument name="file_location" type="string" required="true"
			hint="location of file on hdd">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cftry>
			<cfset InternalStoreRoutineOfArtwork( identification = arguments.mediaitemkey, file_location = arguments.file_location, custom = true ) />
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfcatch.Message ) />
		</cfcatch>
		</cftry>
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
	<cffunction access="private" name="getPathToArtworkImageDirectory" output="false" returntype="string"
			hint="return the path where the image for a track will be stored / is stored">
		<cfargument name="identification" type="string" required="true"
			hint="entrykey of file">
		<cfargument name="custom" type="boolean" required="false" default="false"
			hint="is this a custom artwork?">
			
		<cfset var sPath = application.udf.GetLocalContentDirectory() & 'album_artwork/' />
		
		<cfif arguments.custom>
			<cfset sPath = sPath & 'cust/' />
		</cfif>
		
		<!--- path = basis + 3 chars form the right  --->
		<cfset sPath = sPath & Right( arguments.identification, 3 ) & '/' />
		
		<cfreturn sPath />
		
	</cffunction>
	
	<cffunction access="private" name="InternalStoreRoutineOfArtwork" output="false" returntype="void" hint="store the artwork data internally">
		<cfargument name="identification" type="string" required="true"
			hint="entrykey of musicbrainz id">
		<cfargument name="file_location" type="string" required="true"
			hint="location of file">
		<cfargument name="custom" type="boolean" required="false" default="false"
			hint="is this a custom artwork?">
		
		<!--- get the basic path --->	
		<cfset var a_path = getPathToArtworkImageDirectory( identification = arguments.identification, custom = arguments.custom ) />
		<cfset var a_str_filename = '' />
		<cfset var a_str_target_file_small = '' />
		
		<!--- source files does not exist? --->
		<cfif NOT FileExists( arguments.file_location )>
			
			<!---
			<cfmail from="support@tunesBag.com" to="support@tunesBag.com" subject="InternalStoreRoutineOfArtwork failure" type="html">
				<cfdump var="#arguments#">
			</cfmail>
			--->
			<cfreturn />
		</cfif>
		
		<cfif NOT DirectoryExists( a_path )>			
			<cfdirectory action="create" directory="#a_path#">
		</cfif>
		
		<cflog application="false" file="tb_artwork" log="Application" type="information" text="#a_path##arguments.identification#.120.jpg">
		
		<cfset GenerateImageSizeVariation( source = arguments.file_location, destination = a_path & arguments.identification & '.120.jpg', height = '', width = 120 ) />
		<cfset GenerateImageSizeVariation( source = arguments.file_location, destination = a_path & arguments.identification & '.75.jpg', height = '', width = 75 ) />
		<cfset GenerateImageSizeVariation( source = arguments.file_location, destination = a_path & arguments.identification & '.48.jpg', height = '', width = 48 ) />
		<cfset GenerateImageSizeVariation( source = arguments.file_location, destination = a_path & arguments.identification & '.300.jpg', height = '', width = 300 ) />
		
	
	</cffunction>
	
	<cffunction access="public" name="HandleAlbumArtworkStorage" output="false" returntype="struct" hint="store album artwork in several versions">
		<cfargument name="mbalbumid" type="numeric" required="true"
			hint="the mb id of the album">
		<cfargument name="http_location" type="string" required="true"
			hint="where to find the image">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var cfhttp = 0 />
		<cfset var a_http_content = 0 />
		<cfset var a_str_filename = application.udf.GetTBTempDirectory() & '/' & 'artwork_remote_' & createUUID() & '.jpg' />
		
		<cfif Len( arguments.http_location ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
		</cfif>
		
		<cftry>
			<cfhttp url="#arguments.http_location#" timeout="10" charset="utf-8" getasbinary="auto" method="GET" result="cfhttp" useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"></cfhttp> 
	
			<cfset a_http_content = cfhttp.FileContent />
	
			<!--- if not 200, than an error occured --->
			<cfif (FindNoCase( '200', cfhttp.StatusCode ) NEQ 1) OR (ListFirst( cfhttp.MimeType, '/') NEQ 'image' )>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
			</cfif>
		
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
			</cfcatch>
		</cftry>
		
		<cffile action="write" addnewline="false" file="#a_str_filename#" output="#a_http_content#">
		
		<cfset InternalStoreRoutineOfArtwork( identification = arguments.mbalbumid, file_location = a_str_filename, custom = false ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="CheckStoreUpdateCommonAlbumInfo" output="false" returntype="struct" hint="check if new / update">
		<cfargument name="mbalbumid" type="numeric" required="true"
			hint="id of album (musicbrainz)">
		<cfargument name="data" type="struct" required="false" default="#StructNew()#"
			hint="struct with data">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var a_item = oTransfer.get( 'commoninformation.common_album_information', arguments.mbalbumid ) />

		<cfset a_item.setalbumid( arguments.mbalbumid ) />

		<cfif NOT a_item.getIsPersisted()>
			<cfset a_item.setdt_created( Now() ) />
		</cfif>
		
		<!--- do not calculate now ... --->
		<cfset a_item.setartistid( -1 ) />
		
		<!--- artwork --->
		<cfif StructKeyExists( arguments.data, 'artwork' )>
			<cfset a_item.setartwork( arguments.data.artwork ) />
			
			<!--- checked --->
			<cfset a_item.setartworkchecked( 1 ) />
			
			<!--- download and store artwork? --->
			<cfif NOT a_item.getIsPersisted()>
				<cfset HandleAlbumArtworkStorage( mbalbumid = arguments.mbalbumid, http_location = arguments.data.artwork ) />
			</cfif>
		</cfif>				
		
		<cfif StructKeyExists( arguments.data, 'dt_lastupdate_lastfm' )>
			<cfset a_item.setdt_lastupdate_lastfm( arguments.data.dt_lastupdate_lastfm ) />
		</cfif>			
	
		<cfset oTransfer.save( a_item ) />
		
		<!--- return the item for further readings --->
		<cfset stReturn.a_item = a_item />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="CheckStoreUpdateCommonArtistInfo" output="false" returntype="struct" hint="check if new/update">
		<cfargument name="mbartistid" type="numeric" required="true" hint="the id of this artist">
		<cfargument name="data" type="struct" required="false" default="#StructNew()#"
			hint="struct with update data">
		<cfargument name="bHandleArtistImage" type="boolean" default="false"
			hint="Take the artist image and upload it to S3 for further usage?" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfif Val( arguments.mbartistid ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404 ) />
		</cfif>
		
		<cfset var oArtist = entityLoad( 'common_artist_information', arguments.mbartistid, true ) />
		
		<cfif IsNull( oArtist )>
			<cfset oArtist = entityNew( 'common_artist_information' ) />
			<cfset oArtist.setartistid( arguments.mbartistid ) />
			<cfset oArtist.setdt_created( Now() ) />
		</cfif>
		
		<cfset oArtist.setimg_revision( 0 ) />
		
		<cfif StructKeyExists( arguments.data, 'artistimg' )>
			<cfset oArtist.setartistimg( arguments.data.artistimg ) />
		</cfif>		
		
		<cfif StructKeyExists( arguments.data, 'fans' )>
			<cfset oArtist.setfans( arguments.data.fans ) />
		</cfif>			
		
		<!--- add one fan --->
		<cfif StructKeyExists( arguments.data, 'add_one_fan' )>
			<cfset oArtist.setfans( Val( oArtist.getFans() ) + 1 ) />
		</cfif>				
		
		<cfif StructKeyExists( arguments.data, 'dt_lastupdate_lastfm' )>
			<cfset oArtist.setdt_lastupdate_lastfm( arguments.data.dt_lastupdate_lastfm ) />
		</cfif>		
		
		<!--- bio (english) --->
		<cfif StructKeyExists( arguments.data, 'bio_en' )>
			<cfset oArtist.setbio_en( Left( application.udf.StripHTML( arguments.data.bio_en ), 1000)) />
		</cfif>		
		
		<!--- last.fm data --->		
		<cfif StructKeyExists( arguments.data, 'lastfm_listeners' )>
			<cfset oArtist.setlastfm_listeners( Val(arguments.data.lastfm_listeners )) />
		</cfif>	
		
		<cfif StructKeyExists( arguments.data, 'lastfm_playcount' )>
			<cfset oArtist.setlastfm_playcount( Val(arguments.data.lastfm_playcount )) />
		</cfif>	
		
		<!--- last.fm tags --->
		<cfif StructKeyExists( arguments.data, 'aLastFMTags' ) AND IsArray( arguments.data.aLastFMTags )>
			<cfset oArtist.setlastfm_tags( Left( ArrayToList(arguments.data.aLastFMTags ), 150 )) />
		</cfif>		
		
		<!--- save! --->
		<cfset entitySave( oArtist ) />
		
		<!--- any further stunts? --->
		<cfif arguments.bHandleArtistImage AND StructKeyExists( arguments.data, 'artistimg' )>
			
			<cfset local.stFetchImg = fetchArtistImage(
				iArtist_ID	= arguments.mbartistid,
				sHTTPUrl	= arguments.data.artistimg
				)/>
		
		</cfif>
		
		<cfset stReturn.a_item = oArtist />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
		
	<cffunction access="public" name="getArtistInformationEx" output="false" returntype="struct" hint="return information about artist">
		<cfargument name="MBartistID" type="numeric" required="true"
			hint="the musicbrainz artist id">
		<cfargument name="artist" type="string" required="true"
			hint="artist name">
		<cfargument name="mbArtistGID" type="string" required="false" default=""
			hint="the GID (string) of this artist">
		<cfargument name="datatypes" type="string" required="false" default=""
			hint="which information should be loaded">
		<cfargument name="lang" type="string" required="false" default="en"
			hint="which language?">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		<cfset var a_bol_load_similar_artists = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'similarartists' ) GT 0) />
		<cfset var a_load_links = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'links' ) GT 0) />	
		<cfset var a_load_fans = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'fans' ) GT 0) />	
		<cfset var a_load_users_with_tracks = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'userswithtracks' ) GT 0) />	
		<cfset var a_load_playlists = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'playlists' ) GT 0) />	
		<cfset var a_load_events = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'events' ) GT 0) />	
		<cfset var a_load_bio = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'bio' ) GT 0) />
		<cfset var a_load_tweets = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'tweets' ) GT 0) />
		<cfset var a_load_plists = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'playlists' ) GT 0) />
		<cfset var a_load_lastfm_shouts = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'lastfm_shouts' ) GT 0) />
		<cfset var a_load_web_results_web = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'webresults_web' ) GT 0) />
		<cfset var a_load_web_results_images = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'webresults_images' ) GT 0) />
		<cfset var a_load_web_results_news = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'webresults_news' ) GT 0) />	
		<cfset var bLoadImageStrips = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'image_strips' ) GT 0) />
		<cfset local.bCompilations = Len( arguments.datatypes ) IS 0 OR (ListFindNoCase( arguments.datatypes, 'compilations' ) GT 0) />		
		<cfset var q_select_artist_links = 0 />
		<cfset var q_select_playlists = 0 />
		<cfset var a_struct_call = 0 />
		<cfset var a_cmp_twitter = 0 />
		
		<!--- force slow down on that stuff ... --->
		<cfset bLoadImageStrips = false />
		<cfset a_load_web_results_news = false />
		<cfset a_load_web_results_images = false />
		<cfset a_load_web_results_web = false />
		<cfset a_load_lastfm_shouts = false />
		<cfset a_load_tweets = false />
		<cfset a_load_bio = false />
		<cfset a_load_events = false />
		<cfset a_load_users_with_tracks = false />
		<cfset a_load_fans = false />
		<cfset a_bol_load_similar_artists = false />
		
		<cfset local.sThreadNames = '' />
		
		<!--- all data provided? --->
		<cfif arguments.mbartistid IS 0 OR Len( arguments.artist ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
		</cfif>
		
		<!--- GID provided? or search for it? --->
		<cfif Len( arguments.mbArtistGID ) IS 0>
			<cfset arguments.mbArtistGID = GetArtistGIDByArtistID( arguments.mbArtistID ) />		
		</cfif>
		
		<!--- bio? --->
		<cfif a_load_bio>
		
			<!--- bio is loaded using the search artist query --->

		</cfif>
		
		<!--- compilations --->
		<cfif local.bCompilations>
			
			<cfthread action="run" name="ArtistInfo_compilations_#arguments.mbArtistID#" stArgs="#arguments#">
				
				<cfset thread.qCompilations = application.beanFactory.getBean( 'MusicBrainz' ).GetCompilationItemsOfArtist(
						artistid	= stArgs.mbArtistID
						) />
						
			</cfthread>
			
			<cfset local.sThreadNames = ListAppend( local.sThreadNames, "ArtistInfo_compilations_#arguments.mbArtistID#" ) />
			
		</cfif>
		
		<!--- tweets --->
		<cfif a_load_tweets>
			<cfset a_cmp_twitter = application.beanFactory.getBean( 'TwitterComponent' ).getArtistTweets( artist = arguments.artist, mb_artistid = arguments.MBartistID, exec_search = true ) />
			
			<cfif a_cmp_twitter.result>
				<cfset stReturn.q_select_tweets = a_cmp_twitter.q_select_tweets />
			</cfif>
		</cfif>
				
		<!--- load links? --->
		<cfif a_load_links>			
			<cfinclude template="queries/content/q_select_artist_links.cfm">			
			<cfset stReturn.q_select_artist_links = q_select_artist_links />			
		</cfif>
		
		<!--- similar artists --->
		<cfif a_bol_load_similar_artists>
			
			<!--- load similar artists --->
			<cfthread action="run" name="ArtistInfo_similar_#arguments.mbArtistID#" stArgs="#arguments#">
				
				<cfset thread.stCall = application.beanFactory.getBean( 'LastFMComponent' ).GetSimilarArtistsInformation(
						artist = attributes.stArgs.artist,
						mbartistid = attributes.stArgs.MBartistID,
						mbartistgid = attributes.stArgs.mbArtistGID
						) />
						
			</cfthread>
			
			<cfset local.sThreadNames = ListAppend( local.sThreadNames, "ArtistInfo_similar_#arguments.mbArtistID#" ) />
			
		</cfif>
		
		<!--- fans --->
		<cfif a_load_fans>		
			<cfinclude template="queries/q_select_fans_of_artist.cfm">			
			<cfset stReturn.q_select_fans_of_artist = q_select_fans_of_artist />
		</cfif>
		
		<!--- playlists --->
		<cfif a_load_playlists>
			
			<cfthread action="run" name="ArtistInfo_playlists_#arguments.mbArtistID#" stArgs="#arguments#">
				
				<cfset thread.q_select_playlists = getPlaylistsWithGivenItem( artistid = attributes.stArgs.mbartistID ) />
						
			</cfthread>
			
			<cfset local.sThreadNames = ListAppend( local.sThreadNames, "ArtistInfo_playlists_#arguments.mbArtistID#" ) />
					
		</cfif>
		
		<!--- load users with tracks of this artist? TODO migrate to mbid --->
		<cfif a_load_users_with_tracks>
			<cfinclude template="queries/artists/q_select_users_with_tracks_of_this_artist.cfm">
			
			<cfset stReturn.q_select_users_with_tracks_of_this_artist = q_select_users_with_tracks_of_this_artist />
		</cfif>
		
		<!--- events --->
		<!--- <cfset a_load_events = false /> --->
		<cfif a_load_events>
		
			<!--- songkick ... load events but do not fetch from internet --->
			<cfset a_struct_call = application.beanFactory.getBean( 'Songkick' ).getEvents( sMBArtistID = arguments.mbartistgid, iMB_ArtistID = arguments.mbartistid, bFetchFromProvider = false ) />
			
			<cfset stReturn.stLoadEvents = a_struct_call />
			
			<cfif a_struct_call.result>
				<cfset stReturn.q_select_artist_events = a_struct_call.qEvents />
			</cfif>
		
		</cfif>
		
		<!--- load yahoo WEB results --->
		<cfif a_load_web_results_web>
			
			<cfset a_struct_call = application.beanFactory.getBean( 'YahooComponent' ).PerformSearch( type = 'web', lang = 'en', term = '"' & arguments.artist & '" artist', maxrows = 4 ) />
			
			<cfif a_struct_call.result>
				<cfset stReturn.web_results_web = a_struct_call.hits />
			</cfif>
			
		</cfif>
		
		<!--- load yahoo NEWS results --->
		<cfif a_load_web_results_news>
			
			<cfset a_struct_call = application.beanFactory.getBean( 'YahooComponent' ).PerformSearch( type = 'news', lang = 'en', term = '"' & arguments.artist & '" artist', maxrows = 3 ) />
			
			<cfif a_struct_call.result>
				<cfset stReturn.web_results_news = a_struct_call.hits />
			</cfif>
			
		</cfif>	
		
		<!--- load yahoo IMAGES results --->
		<cfif a_load_web_results_images>
			
			<cfset a_struct_call = application.beanFactory.getBean( 'YahooComponent' ).PerformSearch( type = 'images', lang = 'en', term = '"' & arguments.artist & '" artist', maxrows = 5 ) />
			
			<cfif a_struct_call.result>
				<cfset stReturn.web_results_images = a_struct_call.hits />
			</cfif>
			
		</cfif>	
		
		<!--- image strips --->
		<cfif bLoadImageStrips>
			
			<cfset local.stLoad = loadArtistImageStrip( arguments.mbartistID, 0 ) />
			
			<cfif local.stLoad.result>
				<cfset stReturn.image_strips = local.stLoad.qSelect />
			</cfif>
			
		</cfif>
		
		<!--- join all threads and set the data --->
		<cfif ListLen( local.sThreadNames ) GT 0>
			
			<cfthread action="join" name="#local.sThreadNames#" timeout="30000"></cfthread>
			
			<!--- compilations --->
			<cfif local.bCompilations>
				<cfset stReturn.qCompilations = cfthread[ "ArtistInfo_compilations_#arguments.mbArtistID#" ].qCompilations />
			</cfif>
			
			<!--- plists --->
			<cfif a_load_playlists>
				<cfif StructKeyExists( cfthread[ "ArtistInfo_playlists_#arguments.mbArtistID#" ], 'q_select_playlists')>
					<cfset stReturn.q_select_playlists = cfthread[ "ArtistInfo_playlists_#arguments.mbArtistID#" ].q_select_playlists />	
				</cfif>
			</cfif>
			
			<!--- similar artists --->
			<cfif a_bol_load_similar_artists>
				
				<cfset local.stSimilarArtists = cfthread[ "ArtistInfo_similar_#arguments.mbArtistID#" ].stCall />
				
				<cfif local.stSimilarArtists.result>
					<cfset stReturn.q_select_similar_artists = cfthread[ "ArtistInfo_similar_#arguments.mbArtistID#" ].stCall.q_select_similar_artists />
				</cfif>
				
			</cfif>
			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="getPlaylistsWithGivenItem" output="false" returntype="query"
			hint="return playlists with this artist / album / track ... ">
		<cfargument name="artistid" type="numeric" required="false" default="0"
			hint="musicbrainz ID">
		<cfargument name="albumid" type="numeric" required="false" default="0"
			hint="musicbrainz ID">
		<cfargument name="trackid" type="numeric" required="false" default="0"
			hint="musicbrainz ID">
				
		<cfset var q_select_playlists_with_item = 0 />
		<cfset var q_select_playlists_with_item_collect = 0 />
		<cfset var a_bol_hit = false />
		
		<cfinclude template="queries/content/q_select_playlists_with_item.cfm">
		
		<cfreturn q_select_playlists_with_item />	
	
	</cffunction>
	
	<cffunction access="public" name="GetAvailableAlbumCovers" output="false" returntype="struct"
			hint="return the items where an album cover is available ... very simple query">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="librarykeys" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
		<cfset var a_filter = { fields = 'mb_albumid' } />
		<cfset var a_get_data = a_mediaitems.GetUserContentData( librarykeys = arguments.librarykeys,
									type = 'mediaitems',
									securitycontext = arguments.securitycontext,
									filter = a_filter ) />
		<cfset var q_select_data = a_get_data.q_select_items />
		<cfset var q_select_existing_images = 0 />
		<cfset var a_str_albumid = '' />
		<cfset var a_existing_file_items = StructNew() />
		<cfset var a_str_content_dir = application.udf.GetLocalContentDirectory() & 'album_artwork/' />
		<cfset var a_struct_hash_handled = StructNew() />
		<!--- check caching ... --->
		<cfset var a_str_hash_description = 'filesystem_check_album_artwork' />
		<cfset var a_str_cache_hash = Hash( a_str_hash_description ) />
		<cfset var a_cmp_cache = application.beanFactory.getBean( 'CacheComponent' ) />
		<cfset var a_struct_cache = a_cmp_cache.CheckAndGetStoredElement( hashvalue = a_str_cache_hash ) />
		
		<!--- take the cached version of check the filesystem? --->
		<cfif a_struct_cache.result>
			<cfset a_existing_file_items = a_struct_cache.data />
		<cfelse>
		
			<cfsetting requesttimeout="200" />
			
			<!--- build the structure now --->
			<cfdirectory action="list" directory="#a_str_content_dir#" recurse="true" filter="*.300.jpg" name="q_select_existing_images" />
						
			<!--- build hashvalue and set 1 = exists --->
			<cfloop query="q_select_existing_images">
				
				<!--- get album id --->
				<cfset a_str_albumid = ReplaceNoCase( ReplaceNoCase( q_select_existing_images.name, '.300.jpg', '' ), '.jpg', '') />
				
				<cfset a_existing_file_items[ a_str_albumid] = 1 />
			
			</cfloop>
			
			<!--- cache the generated structure to save IO --->
			<cfset a_cmp_cache.StoreCacheElement( hashvalue = a_str_cache_hash,
								system = 'filesystem',
								description = a_str_hash_description,
								data = a_existing_file_items,
								expiresmin = 60 ) />			
		
		</cfif>
		
		<!--- loop over data and check if the file exists on the harddisk --->	
		<cfloop query="q_select_data">
			
			<cfif (StructKeyExists(a_existing_file_items , q_select_data.mb_albumid) AND NOT StructKeyExists( a_struct_hash_handled, q_select_data.mb_albumid))>
				<!--- make sure we only handle this item once! --->
				<cfset a_struct_hash_handled[ q_select_data.mb_albumid ] = 1 />
			</cfif>
			
		</cfloop>
		
		<cfset stReturn.content = StructKeyList( a_struct_hash_handled, ',' ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

	</cffunction>
	
	<cffunction access="public" name="getPopularArtists" output="false" returntype="struct"
			hint="return popular artists">
		<cfargument name="sType" type="string" required="false" default="COMBINED"
			hint="see application.const.S_REPORTING_INDICATOR_FANS etc" />
		<cfargument name="iDaysBackStart" type="numeric" default="14" required="false"
			hint="range start" />
		<cfargument name="iDaysBackEnd" type="numeric" default="0" required="false"
			hint="range end, default = today" />
		<cfargument name="sOptions" type="string" required="false" default=""
			hint="set certain options" />
		<cfargument name="iMaxRows" type="numeric" required="false" default="15" />
		<cfargument name="bJoinArtistImageStrips" type="boolean" default="false"
			hint="join the artist image strips" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var qSelectPopularArtists = 0 />
		<cfset var local = {} />
		
		<cfinclude template="queries/content/qSelectPopularArtists.cfm">
		
		<cfset stReturn.qSelectPopularArtists = qSelectPopularArtists />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
	</cffunction>
	
	<cffunction access="public" name="GetLastPlayedItems" output="false" returntype="struct"
			hint="Return the recently played items (some sort of global timeline)">
		<cfargument name="userkeys" type="string" required="false" default=""
			hint="userkeys to filter for">
		<cfargument name="maxrows" type="numeric" required="false" default="20"
			hint="max rows to return">
		<cfargument name="filter" type="struct" required="false" default="#StructNew()#">
		<cfargument name="options" type="string" required="false" default="Identifiedonly"
			hint="various options, currently supported: noratings, Identifiedonly, min30sec">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_recently_played_items = 0 />
		<cfset var q_select_collect_entrykeys = 0 />
		<cfset var a_struct_mediaitems = {} />
		
		<cfinclude template="queries/content/q_select_recently_played_items.cfm">
		
		<cfset stReturn.q_select_recently_played_items = q_select_recently_played_items />		
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
	</cffunction>
	
	<cffunction access="public" name="getUserRSSFeed" output="false" returntype="struct" hint="return user RSS feed data">
		<cfargument name="username" type="string" required="true"
			hint="username for which we want to get the info stream">
		<cfargument name="maxagedays" type="numeric" default="0" required="false"
			hint="max age of news item ( 0 = all)">
		<cfargument name="sincedate" type="numeric" default="0" required="false"
			hint="only news since sincedate (format = mmddyyyyhhmmss)">
		<cfargument name="maxrows" type="numeric" default="100" required="false"
			hint="max number of rows to return">
		<cfargument name="options" type="string" required="false" default=""
			hint="options to submit">
		<cfargument name="filter_actions" type="string" required="false" default=""
			hint="list of actions to return">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_cmp_log = application.beanFactory.getBean( 'LogComponent' ) />
		<cfset var q_select_log_items = 0 />
		<cfset var ii = 0 />
		<cfset var a_sec_context = 0 />
		<cfset var a_str_link = '' />
		<cfset var a_str_text = '' />
		<cfset var a_replace = 0 />
		<cfset var a_struct_log_items = 0 />
		<cfset var stFilter = {} />
		
		<!--- no username --->
		<cfif Len( arguments.username ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002 ) />
		</cfif>		
		
		<!--- get the user security context --->
		<cfset a_sec_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUsername( username = arguments.username ) />
		
		<cfif NOT a_sec_context.exists>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002 ) />
		</cfif>
		
		<!--- filter for certain actions? --->
		<cfif Len( arguments.filter_actions ) GT 0>
			<cfset stFilter.actions = arguments.filter_actions />
		</cfif>

		<cfset a_struct_log_items = a_cmp_log.GetLogItems( securitycontext = a_sec_context,
											filter = stFilter,
											maxrows = arguments.maxrows,
											maxagedays = arguments.maxagedays,
											sincedate = arguments.sincedate,
											options = arguments.options ) />
											
		<cfif NOT a_struct_log_items.result >
			<cfreturn a_struct_log_items />
		</cfif>											
											
		<cfset q_select_log_items = a_struct_log_items.q_select_log_items />
		
		<cfinclude template="utils/feed/inc_generate_user_rss_feed.cfm">
		
		<cfset stReturn.q_select_log_items = q_select_log_items />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="BuildExploreRecommendations" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var qfavartists = application.beanFactory.getBean( 'UserComponent' ).getFavouriteArtistsOfUser( securitycontext = arguments.securitycontext,
					options = 'IMPLICIT_FAVOURITES_AS_WELL' ) />
		<cfset var stPlistFilter = { dt_lastmodified_gt = DateAdd( 'd', -14, Now() )} />
		<cfset var a_struct_friends = application.beanFactory.getBean( 'SocialComponent' ).getFriendsList( arguments.securitycontext ) />
		<cfset var stPlists = 0 />
		<cfset var sFriendKeys = ValueList( a_struct_friends.q_select_friends.otheruserkey ) />
		<cfset var qNewTracksFriends = 0 />
		<cfset var qNewTracksFriends_genres = 0 />
		<cfset var qNewTracksFriends_artists = 0 />
		<cfset var qNewTracksFriends_albums = 0 />
		
		<cfset stReturn.qfavartists = qfavartists />
		
		<!--- check if a radio licence is available ... --->
		<cfif arguments.securitycontext.rights.playlist.radio IS 1>
			
			<!--- number of fav artists lower than 5? mix very popular artists to the list --->	
			<cfset stPlists = application.beanFactory.getBean( 'PlaylistsComponent' ).SearchForPlaylists( securitycontext = arguments.securitycontext,
								search = '',
								filter = stPlistFilter,
								artist_ids = ValueList( qfavartists.mbid ),
								options = 'IGNORE_OWN_PLISTS' ) />
			
			
			<cfset stReturn.stPlaylists = stPlists />
			
			<!--- new tracks among friends --->
			<cfinclude template="queries/content/q_select_new_tracks_friends.cfm">
			
			<cfset stReturn.qNewTracksFriends = qNewTracksFriends />
			<cfset stReturn.qNewTracksFriends_genres = qNewTracksFriends_genres />
			<cfset stReturn.qNewTracksFriends_artists = qNewTracksFriends_artists />
			<cfset stReturn.qNewTracksFriends_albums = qNewTracksFriends_albums />
			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="getSocialInformationOfTrack" output="false" returntype="struct">
		<cfargument name="artist" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_mediaitems_owners = 0 />
		<cfset var q_select_avg_rating = 0 />
		<cfset var q_select_plists_with_this_track = 0 />
		
		<cfinclude template="queries/content/q_select_mediaitems_owners.cfm">
		<cfset stReturn.q_select_mediaitems_owners = q_select_mediaitems_owners />

		<cfinclude template="queries/content/q_select_avg_rating.cfm">
		<cfset stReturn.q_select_avg_rating = q_select_avg_rating />

		<cfinclude template="queries/content/q_select_plists_with_this_track.cfm">
		<cfset stReturn.q_select_plists_with_this_track = q_select_plists_with_this_track />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>

	<cffunction access="public" name="fetchArtistImage" output="false" returntype="struct"
			hint="Fetch artist image from given location and try to save it with various sizes">
		<cfargument name="iArtist_ID" type="numeric" required="true" />
		<cfargument name="sHTTPUrl" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var sImageSizes = '30,48,75,120,300' />
		<cfset var local = {} />
		<cfset var cfhttp = 0 />
		
		<!--- generate dest content ... always take the three numbers from the right to gain a better distribution --->
		<cfset local.sDestDir = application.udf.getLocalArtistImagePath( arguments.iArtist_ID ) />
	
		<cfif NOT DirectoryExists( local.sDestDir )>
			<cfdirectory action="create" directory="#local.sDestDir#" />
		</cfif>
		
		<cfif Len( arguments.sHTTPUrl ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'Empty url prohibited' ) />
		</cfif>
	
		<cfset local.sDestFileBase = local.sDestDir & arguments.iArtist_ID />
		
		<!--- try to use big image instead of small one ... http://userserve-ak.last.fm/serve/126/294545.jpg --->
		<cfset arguments.sHttpURL = ReplaceNoCase( arguments.sHttpURL, '/126/', '/252/' ) />
		
		<cfset stReturn.sSource = arguments.shttpURL />
	
		<!---  try to load image --->	
		
		<cftry>
			<cfhttp url="#arguments.sHTTPUrl#" timeout="10" charset="utf-8"
					getasbinary="auto" method="GET" result="cfhttp"
					useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"></cfhttp> 
		
			<cfset local.sHttpContent = cfhttp.FileContent />
			
			<!--- if not 200, than an error occured --->
			<cfif (FindNoCase( '200', cfhttp.StatusCode ) NEQ 1) OR (ListFirst( cfhttp.MimeType, '/') NEQ 'image' ) OR (cfhttp.ResponseHeader['Content-Length'] IS 13510) OR (cfhttp.ResponseHeader['Content-Length'] IS 13079)>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfhttp.FileContent ) />
			</cfif>
			
			<cfset local.sFetchedImage = local.sDestFileBase & '.fetched.jpg' />
			
			<cffile action="write" output="#local.sHttpContent#" file="#local.sFetchedImage#" />
			
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
			</cfcatch>
		</cftry>
		
		<cfloop list="#sImageSizes#" index="local.iSize">
			<cfset GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.' & local.iSize & '.jpg', height = '', width = local.iSize ) />				
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>

	<cffunction access="public" name="fetchAlbumImage" output="false" returntype="struct"
			hint="load album img">
		<cfargument name="iAlbum_ID" type="numeric" required="true" />
		<cfargument name="sHTTPURL" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var sImageSizes = '30,48,75,120,300' />
		<cfset var local = {} />
		<cfset var cfhttp = 0 />
		
		<!--- generate dest content ... always take the three numbers from the right to gain a better distribution --->
		<cfset local.sDestDir = getLocalAlbumImagePath( arguments.iAlbum_ID ) />
	
		<cfif NOT DirectoryExists( local.sDestDir )>
			<cfdirectory action="create" directory="#local.sDestDir#" />
		</cfif>
		
		<cfif Len( arguments.sHTTPUrl ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'Empty url prohibited' ) />
		</cfif>
	
		<cfset local.sDestFileBase = local.sDestDir & arguments.iAlbum_ID />
		
		<!--- try to use big image instead of small one ... http://userserve-ak.last.fm/serve/126/294545.jpg --->
		<!--- <cfset arguments.sHttpURL = ReplaceNoCase( arguments.sHttpURL, '/126/', '/252/' ) /> --->
		
		<cfset stReturn.sSource = arguments.shttpURL />
	
		<!---  try to load image --->	
		<cftry>
			<cfhttp url="#arguments.sHTTPUrl#" timeout="10" charset="utf-8"
					getasbinary="auto" method="GET" result="cfhttp"
					useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"></cfhttp> 
		
			<cfset local.sHttpContent = cfhttp.FileContent />
			
			<!--- if not 200, than an error occured --->
			<cfif (FindNoCase( '200', cfhttp.StatusCode ) NEQ 1) OR (ListFirst( cfhttp.MimeType, '/') NEQ 'image' ) OR (cfhttp.ResponseHeader['Content-Length'] IS 13510) OR (cfhttp.ResponseHeader['Content-Length'] IS 13079)>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, cfhttp.FileContent ) />
			</cfif>
			
			<cfset local.sFetchedImage = local.sDestFileBase & '.fetched.jpg' />
			
			<cffile action="write" output="#local.sHttpContent#" file="#local.sFetchedImage#" />
			
			<cfcatch type="any">
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999 ) />
			</cfcatch>
		</cftry>
		
		<cfloop list="#sImageSizes#" index="local.iSize">
			<cfset GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.' & local.iSize & '.jpg', height = '', width = local.iSize ) />				
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>

	<!--- 
	
		remove the pre-filled tracks from the database
	
	 --->
	 <cffunction access="public" name="removePrefilledTracks" output="false" returntype="struct"
	 		hint="delete all prefilled tracks from library">
	 	<cfargument name="securitycontext" type="struct" required="true"
			hint="the user who has just been created" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		
		<cfquery name="local.qSelectPrefilled" datasource="mytunesbutleruserdata">
		SELECT
			entrykey
		FROM
			mediaitems
		WHERE
			userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">
			AND
			source = 'prefill'
		</cfquery>
		
		<cfloop query="local.qSelectPrefilled">
			
			<cfset application.beanFactory.getBean( 'MediaItemsComponent' ).RemoveItemFromLibrary(securitycontext = arguments.securitycontext,
															entrykey = local.qSelectPrefilled.entrykey ) />
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>

	<!--- prefill library and pre-create a plist --->
	<cffunction access="public" name="prefillLibraryPlaylist" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true"
			hint="the user who has just been created" />
			
		<!--- read list of tracks to add --->
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qSelectPrefillData" datasource="mytunesbutlercontent" cachedwithin="#CreateTimeSpan(0, 0, 10, 0)#">
		/* get all valid items */
		SELECT
			hashvalue,originalhashvalue,metainformation,originalmediaitemkey
		FROM
			prefill_librarydata
		WHERE
			(
				/* certain country */
				countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.COUNTRYISOCODE#">
				OR
				/* all countries */
				countrycode = ''
			)
			AND
			/* active */
			active = 1
		;
		</cfquery>
		
		<cfset stReturn.qSelectPrefillData = local.qSelectPrefillData />
		
		<cfset local.sCollectCreatedEntrykeys = '' />
		
		<!--- loop over data --->
		<cfoutput query="local.qSelectPrefillData">
			
			<cfset local.stMetaInformation = DeSerializeJSON( local.qSelectPrefillData.metainformation ) />
			
			<!--- read cover art --->
			<cfset local.sArtworkFilename = getPathToArtworkImageDirectory( identification = local.qSelectPrefillData.originalmediaitemkey, custom = true ) & '/' & local.qSelectPrefillData.originalmediaitemkey & '.300.jpg' />
			
			<!--- <cflog application="false" file="tb_artwork" text="#local.sArtworkFilename# (#FileExists( local.sArtworkFilename )#)" type="information" log="Application" />
			
			<!--- add as custom artwork --->
			<cfif FileExists( local.sArtworkFilename )>
				
				<cffile action="read" file="#local.sArtworkFilename#" variable="local.sArtworkContent" />
				
				<!--- add as property ... --->
				<cfset local.stMetaInformation.ARTWORKFILECONTENT = ToBase64( local.sArtworkContent ) />
				
			</cfif> --->
			
			<!--- add! --->
			<cfset local.stAdd = application.beanFactory.getBean( 'MediaItemsComponent' ).StoreMediaItemInformation(
						operation = 'CREATE',
						entrykey = createUUID(),
						userkey = arguments.securitycontext.entrykey,
						librarykey = '',
						hashvalue = local.qSelectPrefillData.hashvalue,
						originalhashvalue = local.qSelectPrefillData.originalhashvalue,
						filename = '',
						metainformation = local.stMetaInformation ) />
			
			<!--- success! --->			
			<cfif local.stAdd.result>
				
				<cfset InternalStoreRoutineOfArtwork( identification = local.stAdd.entrykey,
							file_location = local.sArtworkFilename,
							custom = true ) />
							
				<!--- collect entrykeys --->
				<cfset local.sCollectCreatedEntrykeys = ListAppend( local.sCollectCreatedEntrykeys, local.stAdd.entrykey) />
				
			</cfif>
		
		</cfoutput>
		
		<!--- create a default playlist with these tracks --->
		<!--- <cfset local.stAddPlist = application.beanFactory.getBean( 'PlaylistsComponent' ).CreateEditPlaylist(
					securitycontext = arguments.securitycontext,
					librarykey = '',
					name = application.udf.GetLangValSec( 'cm_ph_plist_prefilled_data' ),
					description = application.udf.GetLangValSec( 'cm_ph_plist_prefilled_data_desc' ),
					tags = '',
					additems = local.sCollectCreatedEntrykeys ) /> --->
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	

<!--- 
	get all images for artist strip
 --->
	<cffunction access="public" name="generateArtistImageStrip" output="false" returntype="struct"
			hint="perform loading of artist images and create the image strip">
		<cfargument name="iMBArtist_ID" type="numeric" required="true" />
		<cfargument name="sArtistName" type="string" required="true" />
		<cfargument name="iImageWidth" type="numeric" required="true" />
		<cfargument name="iImageHeight" type="numeric" required="true" />
		<cfargument name="iMaxImages" type="numeric" required="true" />
		
		<cfsetting requesttimeout="120">
	
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		
		<!--- db --->
		<cfset local.oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />	
		
		<!--- invalid image sizes --->
		<cfset local.lImageInvalidSizes = '2737,3386' />
		
		<!--- path to store the raw images --->
		<cfset local.sImagePath = application.udf.getLocalFlickrArtistImagePath( arguments.iMBArtist_ID ) />
		
		<!--- raw artist path --->
		<cfset local.sArtistImgPath = application.udf.getLocalArtistImagePath( arguments.iMBArtist_ID ) />
		
		<cfset local.itc = GetTickcount() />
		
		<cfif Len( arguments.sArtistName ) IS 0 OR Val( arguments.iMBArtist_ID ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404, 'Empty artist name/ID prohibited' ) />
		</cfif>
		
		<cfset local.oFinalImage = ImageNew( '', arguments.iImageWidth, arguments.iImageHeight, "argb","white") />
		
		<cfset ImageSetDrawingColor(local.oFinalImage,"black") />
		<cfset local.stTextAttr = StructNew() />
		<cfset local.stTextAttr.size=12 />
		<!--- <cfset local.stTextAttr.style="bold"> --->
		<cfset local.stTextAttr.font="ArialMT" />
		
		<!--- where to place the next image? --->
		<cfset local.iTop = -20 />
		
		<!--- number of images read successsfully --->
		<cfset local.iSuccessImages = 0 />
		
		<!--- copyright --->
		<cfset local.aCopyRightHints = ArrayNew( 1 ) />
		
		<!--- read helper images --->	
		<cfset local.oImgStripTop = ImageRead( 'res/strip-top.jpg' ) />
		<cfset local.oImgStripBottom = ImageRead( 'res/strip-bottom.jpg' ) />
		
		<cfset local.oImgCC = ImageRead( 'res/ccsmall.png' ) />
		
		<!--- 
			perform search on flickr
		 --->
		<cfset local.stLoadImages = application.beanFactory.getBean( 'Flickr' ).searchForImages( sSearch = arguments.sArtistName, sLoadResolutions = 'size_large', iHits = Ceiling( iMaxImages * 2.5 ) ) />
		
		<cfif NOT local.stLoadImages.result>
			<cfreturn local.stLoadImages />
		</cfif>
			
		<cfset local.qPhotos = local.stLoadImages.QRESULT />
		
		<cfloop query="local.qPhotos">
		
			<!--- read next image? --->
			<cfif local.iSuccessImages LT arguments.iMaxImages>
			
				<!--- specify target path --->
				<cfset local.sImgFilename = "#local.sImagePath##arguments.iMBArtist_ID#-#local.qPhotos.id#.jpg" />
				
				<!--- <cfif NOT FileExists( local.sImgFilename )> --->
				
					<!--- TODO: caching and check if image already exists! --->
					<cftry>
					<cfhttp charset="utf-8" url="#local.qPhotos.size_large#" getasbinary="true" result="local.cfhttp"></cfhttp>
			
					<!--- flickr not available img --->
					<cfif ListFindNoCase( local.lImageInvalidSizes, local.cfhttp.responseheader[ 'Content-Length' ] ) IS 0>
						
						<cfif NOT DirectoryExists( local.sImagePath )>
							<cfdirectory action="create" directory="#local.sImagePath#" />
						</cfif>
						
						<!--- store in database --->
		
						<cfset local.oItem = local.oTransfer.get( 'commoninformation.flickrimages', local.qPhotos.id ) />
						
						<cfset local.oItem.setFlickrID( local.qPhotos.id ) />
						<cfset local.oItem.setusername( local.qPhotos.username ) />
						<cfset local.oItem.setuserid( local.qPhotos.userid ) />
						
						<cfif NOT local.oItem.getIspersisted()>
							<cfset local.oItem.setdt_created( Now() ) />
						</cfif>
						
						<cfset local.oItem.setmbid( arguments.iMBArtist_ID ) />
						<cfset local.oItem.setmbitemtype( 2 ) />				
						
						<cfset local.oItem.setsize_large( local.qPhotos.size_large ) />	
						<cfset local.oItem.setfurtherinfo( '' ) />	
						<cfset local.oItem.setlicence_type( local.qPhotos.license ) />	
						
						<cfset local.oTransfer.save( local.oItem ) />
						
						<!--- store image! --->
						<cfset local.sImgFilename = "#local.sImagePath##arguments.iMBArtist_ID#-#local.qPhotos.id#.jpg" />
						
						<cffile action="write" output="#local.cfhttp.FileContent#" file="#local.sImgFilename#" />
						
						<!--- read image --->
						<cftry>
						<cfset local.oImg = ImageRead( local.sImgFilename ) />
						
						<!--- paste strip --->
						<cfset ImagePaste( local.oImg, local.oImgStripTop, 0, 0 ) />
					
						<cfset ImagePaste( local.oImg, local.oImgStripBottom, 0, (local.oImg.height - local.oImgStripBottom.height) ) />
						
						<!--- paste copyright hint ... like http://www.flickr.com/photos/30245869@N07/2842809037 --->
						<cfset ImageDrawText( local.oImg, 'www.flickr.com/photos/' & local.qPhotos.userid & '/' & local.qPhotos.id, 125, (local.oImg.height - local.oImgStripBottom.height - 30), { size = 22 } ) />
						
						<cfset local.aCopyRightHints[ ArrayLen( local.aCopyRightHints ) + 1 ] = { username = local.qPhotos.username, userid = local.qPhotos.userid, link = 'http://www.flickr.com/photos/' & local.qPhotos.userid & '/' & local.qPhotos.id } /> --->
						
						<!--- "shake" it a little bit --->
						<cfset ImageRotate( local.oImg, RandRange( -10, 10 ) ) />
					
						<!--- fit! --->
						<cfset ImageResize(local.oImg, 550, '' ) />
					
						<!--- get height etc --->
						<cfset local.stImgInfo = ImageInfo( local.oImg ) />
					
						<!--- paste single img on big image --->
						<cfset ImagePaste( local.oFinalImage, local.oImg, -70, local.iTop ) />
						
						<!--- destroy old img --->
						<cfset local.oImg = 0 />
					
						<!--- set new top position --->
						<cfset local.iTop = local.iTop + local.stImgInfo.height - 20 />
						
						<!--- success! --->				
						<cfset local.iSuccessImages = local.iSuccessImages + 1  />
						
						<cfcatch type="any">
							<!--- 
								invalid image
							 --->
							 <cfset stReturn.stImageReadException = cfcatch />
						</cfcatch>
						</cftry>
						
					</cfif>
					
						<cfcatch type="any">
							<cfrethrow >
						</cfcatch>
					</cftry>
					
				<!--- <cfelse>
					<!--- success! --->				
						<cfset local.iSuccessImages = local.iSuccessImages + 1  />
				</cfif> --->
				
				<cfset local.sPath = application.udf.getLocalArtistImagePath( arguments.iMBArtist_ID ) />
			
			</cfif>
		
		</cfloop>
		
		<!--- add CC hint --->
		<cfset ImagePaste( local.oFinalImage, local.oImgCC, 20, (arguments.iImageHeight - 40 ) ) />
		
		<!--- <cfset stReturn.oImage = local.oFinalImage /> --->
		
		<cfset local.sFinalImagePath = local.sArtistImgPath & application.udf.getStripFilename( arguments.iMBArtist_ID, 2, arguments.iImageWidth, arguments.iImageHeight ) />
		
		<!--- store! --->
		<cfset ImageWrite( local.oFinalImage, local.sFinalImagePath ) />
		
		<cfset stReturn.sImagePath = local.sFinalImagePath />
		
		<cfset streturn.tc = (GetTickCount() - local.itc ) />
		
		<cfset stReturn.qPhotos = local.qPhotos />
		
		<!--- return number of generated images --->
		<cfset stReturn.iSuccessImages = local.iSuccessImages />
		
		<!--- copyright --->
		<cfset stReturn.sLicenceInfo = SerializeJSON( local.aCopyRightHints ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="loadArtistImageStrip" output="false" returntype="struct">
		<cfargument name="iMBArtist_ID" type="numeric" required="true" />
		<cfargument name="iImgType" type="numeric" required="false" default="0"
			hint="0 = 380x4000" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		
		<cfquery name="local.qSelect" datasource="mytunesbutlercontent">
		SELECT
			img_revision,
			copyrighthints,
			imgheight,
			imgwidth,
			mbid
		FROM
			image_strips
		WHERE
			mbid > 0
			AND
			mbid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMBArtist_ID#" />
			AND
			img_type = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iImgType#" />
			AND
			mbtype = 2
		;
		</cfquery>
		
		<cfset stReturn.qSelect = local.qSelect />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="updateArtistImageStrip" output="false" returntype="struct">
		<cfargument name="iMBArtist_ID" type="numeric" required="true" />
		<cfargument name="sArtistName" type="string" required="true" />
		<cfargument name="iImgType" type="numeric" required="false" default="0"
			hint="0 = 380x4000" />
			
		<!--- set parameters based on type --->
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		
		<cfswitch expression="#arguments.iImgType#">
			<cfdefaultcase>
				<cfset arguments.iImageWidth = 380 />
				<cfset arguments.iImageHeight = 4000 />
				<cfset arguments.iMaxImages = 10 />						
			</cfdefaultcase>
		</cfswitch>
		
		<!--- db --->
		<cfset local.oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />	
		
		<cfset local.stMap = { mbid = arguments.iMBArtist_ID, mbtype = 2, img_type = arguments.iImgType } />
		
		<!--- save image strip --->
		<cfset local.oStripItem = local.oTransfer.readByPropertyMap( 'commoninformation.image_strips', local.stMap ) />
		
		<!--- <cfset stREturn.oStripItem = local.oStripItem /> --->
		
		<cfif NOT local.oStripItem.getIsPersisted()>
		
	 		<cfset local.stGenerateStripItem = generateArtistImageStrip( iMBArtist_ID = arguments.iMBArtist_ID,
							 sArtistName = arguments.sArtistName,
							 iImageWidth = arguments.iImageWidth,
							 iImageHeight = arguments.iImageHeight,
							 iMaxImages = arguments.iMaxImages ) />
							 
			<!--- <cfif NOT local.stGenerateStripItem.result>
				<cfreturn local.stGenerateStripItem />
			</cfif> --->
			
			<!--- insert --->
			<cfset local.oStripItem.setmbid( arguments.iMBArtist_ID ) />
			<cfset local.oStripItem.setmbtype( 2 ) />		
			<cfset local.oStripItem.setimgheight( arguments.iImageHeight ) />		
			<cfset local.oStripItem.setimgwidth( arguments.iImageWidth ) />		
			<cfset local.oStripItem.setimg_revision( 0 ) />		
			<cfset local.oStripItem.setimgformat( 'jpg' ) />				
			<cfset local.oStripItem.setdt_created( Now() ) />
			<cfset local.oStripItem.setdt_updated( Now() ) />		
			
			
			
			
			<!--- valid or invalid? --->
			<cfif local.stGenerateStripItem.result AND local.stGenerateStripItem.iSuccessImages GT 3>
				<cfset local.oStripItem.setimg_type( application.const.I_IMG_STRIP_TYPE_DEFAULT ) />	
				<cfset local.oStripItem.setcopyrighthints( local.stGenerateStripItem.sLicenceInfo ) />
				
				<!--- not even half of the images found? --->
				<cfset local.oStripItem.setImageCount( local.stGenerateStripItem.iSuccessImages ) />
				
			<cfelse>
				<cfset local.oStripItem.setimg_type( application.const.I_IMG_STRIP_TYPE_INVALID ) />
				<cfset local.oStripItem.setcopyrighthints( '' ) />
				<cfset local.oStripItem.setImageCount( 0 ) />
			</cfif>			
			
					
			<cfset local.oTransfer.save( local.oStripItem ) />
		
		</cfif>
		
		<cfset streturn.sPath = application.udf.getArtistStripImg( arguments.iMBArtist_ID, 2, local.oStripItem.getImgWidth(), local.oStripItem.getImgHeight(), local.oStripItem.getimg_revision() ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>	

</cfcomponent>