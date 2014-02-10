<!--- //

	Module:		Page/Mail Content
	Description: 
	
// --->

<cfcomponent name="pagecontent" displayname="Page info component"output="false" extends="MachII.framework.Listener" hint="Handle page content items">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="BuildExploreRecommendations" description="" returntype="void" hint="get basic recommendations" output="false">
	<cfargument name="event" type="MachII.framework.event" required="true" />
	
	<!--- <cfset oContent = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ) />
	
	<cfset event.setArg( 'stExplore', oContent.BuildExploreRecommendations( securitycontext = application.udf.GetCurrentSecurityContext() )) /> --->

</cffunction>

<cffunction access="public" name="GetWelcomePageData" description="load playlists etc" returntype="void" output="false">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ) />	
	<cfset var q_select_puid_analyzed_unchecked_items = 0 />
	<cfset var stFollowStream = 0 />
	
	<cfset local.iUser_ID = application.udf.GetCurrentSecurityContext().userID />
	
	<!--- plists to load --->
	<cfset local.sPlistNames = 'toprated,recentlyadded,recentlyplayed,recommendations' />	
	
	<!--- add follow stream? radio licence has to be available --->
	<cfif application.udf.GetCurrentSecurityContext().rights.playlist.RADIO IS 1>
		<cfset local.sPlistNames = ListAppend( local.sPlistNames, "followstream" ) />
	</cfif>
	
	<cfset local.sThreadNames = '' />
	
	<!--- run threads --->
	<cfloop list="#local.sPlistNames#" index="local.sPlistName">
		
		<cfset local.sThreadName = "pgdata_plist_#local.sPlistName#_#local.iUser_ID#" />
		<cfset local.sThreadNames = ListAppend( local.sThreadNames, local.sThreadName ) />
		
		<cfthread
			action		= "run"
			name		= "#local.sThreadName#"
			stContext	= "#application.udf.GetCurrentSecurityContext()#"
			sPlistName 	= "#local.sPlistName#"
			iMaxRows	= 10>
			
			<cfset thread.stPlist = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).ReturnPlaylistItems(
					securitycontext = attributes.stContext,
					playlistkey 	= attributes.sPlistName,
					maxrows 		= attributes.iMaxRows
					) />
					<!--- 
					<cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="plist" type="html">
					<cfdump var="#thread.stplist#">
					<cfdump var="#attributes#">
					</cfmail> --->
			
		</cfthread>
		
	</cfloop>
	
	<!--- get recently played plists as well --->
	<cfthread action="run" name="pgdata_recent_plists_#local.iUser_ID#">
		<cfset THREAD.stRecentlyPlayedPlists = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).getRecentlyPlayedPlaylists( securitycontext = application.udf.GetCurrentSecurityContext() ) />
	</cfthread>
	
	<cfset local.sThreadNames = ListAppend( local.sThreadNames, "pgdata_recent_plists_#local.iUser_ID#" ) />
	
	<!--- join and wait for all threads to finish --->
	<cfthread action="join" name="#local.sThreadNames#" timeout="15000"></cfthread>
	
	<cfset var a_struct_plist_recentlyadded = cfThread[ "pgdata_plist_recentlyadded_#local.iUser_ID#" ].stPlist />
				
	<cfset var a_struct_plist_toprated = cfThread[ "pgdata_plist_toprated_#local.iUser_ID#" ].stPlist />
	
											
	<cfset var a_struct_plist_recentlyplayed = cfThread[ "pgdata_plist_recentlyplayed_#local.iUser_ID#" ].stPlist />									
											
	<cfset var a_struct_plist_recommendations = cfThread[ "pgdata_plist_recommendations_#local.iUser_ID#" ].stPlist />		
											
	<cfset var stRecentlyPlayedPlists = cfThread[ "pgdata_recent_plists_#local.iUser_ID#" ].stRecentlyPlayedPlists />																					
						
	<!--- check the general permissions if other tracks are allowed at all --->
	
	<!--- at least viewing has to be possible --->
	<cfif application.udf.GetCurrentSecurityContext().rights.playlist.RADIO IS 1>
		<cfset stFollowStream = cfThread[ "pgdata_plist_followstream_#local.iUser_ID#" ].stPlist />	
		
		<!--- set args --->
		<cfif stFollowStream.result>
			<cfset event.setArg( 'stFollowStream' , stFollowStream) />
		</cfif>
	</cfif>
	
	<cfif a_struct_plist_toprated.result>
		<cfset event.setArg( 'q_select_items_toprated' , a_struct_plist_toprated.q_select_items) />
	</cfif>	
	
	<cfif a_struct_plist_recentlyadded.result>
		<cfset event.setArg( 'q_select_items_recentlyadded' , a_struct_plist_recentlyadded.q_select_items) />
	</cfif>
	
	<cfif a_struct_plist_recommendations.result>
		<cfset event.setArg( 'q_select_items_recommendations', a_struct_plist_recommendations.q_select_items ) />
	</cfif>
	
	<cfif a_struct_plist_recentlyplayed.result>
		<cfset event.setArg( 'qSelectRecentlyPlayed', a_struct_plist_recentlyplayed.q_select_items ) />		
	</cfif>
	
	<cfif stRecentlyPlayedPlists.result>
		<cfset event.setArg( 'qSelectRecentlyPlayedPlists', stRecentlyPlayedPlists.qSelectRecentlyPlayedPlists ) />
	</cfif>
	
	<!--- sync source data --->
	<cfset event.setArg( 'qSyncSources', getProperty( 'beanFactory' ).getBean( 'Sync' ).getAllSyncSources( application.udf.GetCurrentSecurityContext()).qSyncSources ) />
	
	<!--- get recently played playlists --->
	
	<!--- <cfset event.setArg( 'q_select_favourite_artists_of_user', getProperty( 'beanFactory' ).getBean( 'UserComponent').getFavouriteArtistsOfUser( application.udf.GetCurrentSecurityContext() ) ) /> --->
			
</cffunction>

<cffunction access="private" name="CheckPicture" description="check the incoming image" returntype="struct" output="false">
	<cfargument name="imagefile" type="string" required="true">
	<cfargument name="imagetype" type="string" required="true" hint="background or profile">
	
	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_info = 0 />
	<cfset var a_str_valid_file_ext = 'JPG,PNG,GIF,JPEG' />
	<cfset var a_str_file_ext = ListLast( arguments.imagefile, '.' ) />
	<cfset var a_int_filesize = application.udf.fileSize( arguments.imagefile ) />
	<cfset var a_str_resize_target = application.udf.GetTBTempDirectory() & CreateUUID() & '.jpg' />
	
	<!--- valid file extension? --->
	<cfif ListFindNoCase( a_str_valid_file_ext, a_str_file_ext ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(a_struct_return, 5150 ) />
	</cfif>
	
	<cftry>
	<cfimage action="info" source="#arguments.imagefile#" structName="a_struct_info">
	<cfcatch type="any">
		<cfreturn application.udf.SetReturnStructErrorCode(a_struct_return, 5150 ) />
	</cfcatch>
	</cftry>
	
	<cfswitch expression="#arguments.imagetype#">
		<cfcase value="background">
			<!--- page bg --->
			<cfif a_int_filesize GT 2000000>
				<cfreturn application.udf.SetReturnStructErrorCode(a_struct_return, 5151 ) />
			</cfif>
		
		</cfcase>
		<cfcase value="profile">
			<!--- profile image --->
			<cfif a_int_filesize GT 5000000>
				<cfreturn application.udf.SetReturnStructErrorCode(a_struct_return, 5151 ) />
			</cfif>
			
		</cfcase>
		<cfcase value="plist">
			<!--- plist img --->
			<cfif a_int_filesize GT 5000000>
				<cfreturn application.udf.SetReturnStructErrorCode(a_struct_return, 5151 ) />
			</cfif>
		</cfcase>
	</cfswitch>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(a_struct_return) />

</cffunction>

<cffunction access="public" name="CheckChangePicture" output="false" returntype="void" hint="Check if the picture needs to be updated">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_photo_upload = event.getArg( 'userphotoupload' ) />
	<cfset var a_str_bg_pic_upload = event.getArg( 'design_bg_image' ) />
	<cfset var a_str_plist_pic_upload = event.getArg( 'plist_image' ) />
	<cfset var cffile = 0 />
	<cfset var a_call = 0 />
	<cfset var a_str_file = '' />
	<cfset var a_struct_check = 0 />
	<cfset var a_cmp_user = getProperty( 'beanFactory' ).getBean( 'UserComponent' ) />
	<cfset var local = {} />
	
	<!---  update the user image --->
	<cfif FileExists( a_str_photo_upload )>
	
		<cffile action="upload" filefield="userphotoupload" destination="#application.udf.GetTBTempDirectory()#" nameconflict="makeunique" result="cffile">
		
		<cfset a_str_file = cffile.ServerDirectory &  '/' & cffile.ServerFile />
		
		<cfset a_struct_check = CheckPicture( imagefile = a_str_file, imagetype = 'profile' ) />

		<cfset event.setArg( 'a_struct_photo_upload_result', a_struct_check) />
		
		<!--- store image --->
		<cfif a_struct_check.result>
			
			<cfset a_cmp_user.StoreUserProfilePhoto( securitycontext = application.udf.GetCurrentSecurityContext(), bigimagefile = a_str_file ) />
		</cfif>
		
	</cfif>
	
	<!--- update the background image --->
	<cfif FileExists( a_str_bg_pic_upload )>
		
		<cffile action="upload" filefield="design_bg_image" destination="#application.udf.GetTBTempDirectory()#" nameconflict="makeunique" result="cffile">
		
		<cfset a_str_file = cffile.ServerDirectory &  '/' & cffile.ServerFile />
		
		<cfset a_struct_check = CheckPicture( imagefile = a_str_file, imagetype = 'background' ) />
		
		<cfset event.setArg( 'a_struct_background_upload_result', a_struct_check) />
		
		<!--- store image --->
		<cfif a_struct_check.result>
			
			<cfset a_cmp_user.StoreDesignBackgroundImage( securitycontext = application.udf.GetCurrentSecurityContext(), imagefile = a_str_file ) />
			
		</cfif>
		
	</cfif>
	
	<!--- plist image --->
	<cfif Len( a_str_plist_pic_upload ) GT 0>
	
		<!--- file upload or  --->
		<cfif FindNoCase( 'http://', a_str_plist_pic_upload ) IS 1>
			<cfhttp result="local.cfhttp" url="#a_str_plist_pic_upload#" getasbinary="true" timeout="15">
			</cfhttp>
			
			<cfset a_str_file = application.udf.GetTBTempDirectory() & 'plist_' & CreateUUID() & '.jpg' />	
			
			<cffile action="write" file="#a_str_file#" output="#local.cfhttp.FileContent#" />
			
			
		<cfelse>
			<cffile action="upload" filefield="plist_image" destination="#application.udf.GetTBTempDirectory()#" nameconflict="makeunique" result="cffile">			
			<cfset a_str_file = cffile.ServerDirectory &  '/' & cffile.ServerFile />		
		</cfif>
		
		
		<cfset a_struct_check = CheckPicture( imagefile = a_str_file, imagetype = 'plist' ) />
		
		<cfset event.setArg( 'a_struct_plist_upload_result', a_struct_check) />
		
		
		<!--- store image --->
		<cfif a_struct_check.result>
			
			<cfset a_call = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).StoreCustomUserImage( securitycontext = application.udf.GetCurrentSecurityContext(),
								image_type = 'PLAYLIST',
								identifier = event.getArg( 'plistkey' ),
								licence_type_image = Val( event.getArg( 'licence_type_image', 0)),
								licence_image_link = event.getArg( 'licence_image_link', ''),
								imgsoure = a_str_file ) />
		
			<cfset event.setArg( 'a_struct_img_upload_result', a_call) />
			
		</cfif>
	
	</cfif>

</cffunction>

<cffunction access="public" name="FindAlbumImage" output="false" returntype="void" hint="find an album image and store it">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var local = {} />
	<cfset var cfhttp = 0 />
	<cfset var q_select_album_coverart = 0 />
	<cfset var sContentDir = application.udf.GetLocalContentDirectory() & 'album_artwork' />
	
	<!--- incoming call: res/images/artists/1060/1060.120.jpg --->
	<cfset local.sLastPart = ListLast( cgi.redirect_url, '/' ) />
	
	<!--- 
		get the number ... and round down using INT
	 --->
	<cfset event.setArg( 'mbAlbumID', Int(Val(local.sLastPart))) />
	
	<!--- somthing wrong anyway --->
	<cfif ListLen( local.sLastPart, '.') NEQ 3>
		<!--- get the preferred size --->
		<cfset local.sSize = 120 />
	<cfelse>
		<!--- get the preferred size --->
		<cfset local.sSize = ListGetAt( local.sLastPart, 2, '.') />
	</cfif>
	
	<cfset event.setArg( 'Size', local.sSize ) />
	
	<!--- ok? --->
	<cfif event.getArg( 'mbAlbumID' ) IS 0>
		<cfset event.setArg( 'error', 'invalid id')>
		<cfreturn />
	</cfif>	
	
	<cfinclude template="queries/q_select_album_coverart.cfm">
	
	<cfif (q_select_album_coverart.recordcount IS 0 OR Len( q_select_album_coverart.amazon_url_img ) IS 0)>
		<cfset event.setArg( 'error', 'invalid row')>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'q_select_album_coverart', q_select_album_coverart)>
	
	<!--- generate dest content --->
	<cfset local.sDestDir = sContentDir & '/' & Right( q_select_album_coverart.album_ID, 3 ) & '/' />
	
	<cfif NOT DirectoryExists( local.sDestDir )>
		<cfdirectory action="create" directory="#local.sDestDir#" />
	</cfif>
	
	<cfset local.sDestFileBase = local.sDestDir & q_select_album_coverart.album_id />
	
	<!---  try to load image --->	
	<cftry>
		<cfhttp url="#q_select_album_coverart.amazon_url_img#" timeout="10" charset="utf-8"  getasbinary="auto" method="GET" result="cfhttp" useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"></cfhttp> 
	
		<cfset local.sHttpContent = cfhttp.FileContent />
		
		<!--- if not 200, than an error occured --->
		<cfif (FindNoCase( '200', cfhttp.StatusCode ) NEQ 1) OR (ListFirst( cfhttp.MimeType, '/') NEQ 'image' )>
			<cfreturn />
		</cfif>
		
		<cfset local.sFetchedImage = local.sDestFileBase & '.fetched.jpg' />
		
		<cffile action="write" output="#local.sHttpContent#" file="#local.sFetchedImage#" />
		
		<cfcatch type="any">
			<cfreturn />
		</cfcatch>
	</cftry>
	
	<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.300.jpg', height = '', width = 300 ) />	
	<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.120.jpg', height = '', width = 120 ) />	
	<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.75.jpg', height = '', width = 73 ) />	
	<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.48.jpg', height = '', width = 48 ) />	
	<cfset getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = local.sFetchedImage, destination = local.sDestFileBase & '.30.jpg', height = '', width = 30 ) />		
	
	<!--- return the new image --->
	<cfset event.setArg( 'image_location',local.sDestFileBase & '.' & local.sSize & '.jpg') />
	
</cffunction>

<!--- 

	an artist image is missing, go get it!

 --->
<cffunction access="public" name="FindArtistImage" output="false" returntype="void" hint="find artist image and store it!">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var local = {} />
	<cfset var cfhttp = 0 />
	
	<!--- incoming call: res/images/artists/1060/1060.120.jpg --->
	<cfset local.sLastPart = ListLast( cgi.redirect_url, '/' ) />
	
	<!--- 
		get the number ... and round down using INT
	 --->
	<cfset event.setArg( 'mbArtistid', Int(Val(local.sLastPart))) />
	
	<!--- somthing wrong anyway --->
	<cfif ListLen( local.sLastPart, '.') NEQ 3>
		<!--- get the preferred size --->
		<cfset local.sSize = 120 />
	<cfelse>
		<!--- get the preferred size --->
		<cfset local.sSize = ListGetAt( local.sLastPart, 2, '.') />
	</cfif>
	
	<cfset event.setArg( 'Size', local.sSize ) />
	
	<!--- ok? --->
	<cfif event.getArg( 'mbArtistid' ) IS 0>
		<cfset event.setArg( 'error', 'invalid id')>
		<cfreturn />
	</cfif>	
	
	<cfquery name="local.qSelectImgArtist" datasource="mytunesbutler_mb">
	SELECT
		artist.id,
		common.artistimg
	FROM
		artist
	LEFT JOIN
		mytunesbutlercontent.common_artist_information AS common ON (common.artistid = artist.id)
	WHERE
		artist.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#event.getArg( 'mbArtistid' )#">
	LIMIT
		1
	;
	</cfquery>

	<cfif (local.qSelectImgArtist.recordcount IS 0 OR (Len( local.qSelectImgArtist.artistimg ) IS 0) OR ( FindNoCase( 'noartist', local.qSelectImgArtist.artistimg ) GT 0 ))>
		<cfset event.setArg( 'error', 'invalid row')>
		<cfreturn />
	</cfif>
	
	<!--- perform loading --->	
	<cfset local.stLoadArtistImage = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).fetchArtistImage( iArtist_ID = local.qSelectImgArtist.id, sHTTPUrl = local.qSelectImgArtist.artistimg ) />

	<!--- return the new image --->
	<cfif local.stLoadArtistImage.result>
		<cfset event.setArg( 'image_location', application.udf.getLocalArtistImagePath( local.qSelectImgArtist.id ) & local.qSelectImgArtist.id & '.' & local.sSize & '.jpg') />
		<cfset event.setArg('local', local)>
	</cfif>	
	
</cffunction>

<cffunction access="public" name="getUserRSSFeed" output="false" returntype="void" hint="return user RSS feed data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_username = event.getArg( 'username' ) />
	<cfset var a_cmp_content = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ) />
	<cfset var a_struct_get_items = a_cmp_content.getUserRSSFeed( username = a_str_username ) />
	
	<cfif a_struct_get_items.result>
		<cfset event.setArg( 'q_select_log_items', a_struct_get_items.q_select_log_items ) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="getChartsData" output="false" returntype="void" hint="return charts data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_int_timeframe = event.getArg( 'days', 7 ) />
	<cfset var a_target = event.getArg( 'target', 'user' ) />
	<cfset var a_struct_filter = { dt_created_from = DateAdd( 'd', -#a_int_timeframe#, Now() ) } />
	<cfset var q_select_recently_played_items = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GetLastPlayedItems( userkeys = application.udf.GetCurrentSecurityContext().entrykey, filter = a_struct_filter, maxrows = 1000 ).q_select_recently_played_items />
	<cfset var q_select_artists = 0 />
	<cfset var q_select_artist_count = 0 />
	
	<cfquery name="q_select_artists" dbtype="query">
	SELECT
		COUNT(artist) AS artist_count,
		artist
	FROM
		q_select_recently_played_items
	GROUP BY
		artist
	ORDER BY
		artist_count DESC
	;
	</cfquery>

	<cfset event.setArg( 'q_select_artists', q_select_artists ) />

</cffunction>

<cffunction access="public" name="GetCommonArtistInformation" output="false" returntype="void" hint="Check common artist info">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<cfset var a_int_mbid = event.getArg( 'artistid' ) />
	<cfset var a_struct_info = 0 />
	
	<cfif Len( a_str_artist ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfset a_struct_info = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetCommonArtistInformation( artistid = a_int_mbid ) />
	
	<cfset event.setArg( 'a_struct_artist_information', a_struct_info ) />
	
</cffunction>

</cfcomponent>