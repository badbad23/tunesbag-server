<!--- //

	Module:		Handle Public Infos
	Description: 
	
// --->

<cfcomponent name="publicinfo" displayname="Public info component"output="false" extends="MachII.framework.Listener" hint="Handle public info items">
	
<cfinclude template="/common/scripts.cfm">


<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="getFurtherPublicArtistInformation" output="false" returntype="void"
		hint="return further information about artist not stored in the MB database (fans, playlists etc)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_artist_id = event.getArg( 'mbArtistID' ) />
	<cfset var a_artist_gid = event.getArg( 'mbArtistGid' ) />
	<cfset var a_artist = event.getArg( 'Artist' ) />
	<cfset var a_cmp_content = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ) />
	<cfset var a_struct_info = a_cmp_content.getArtistInformationEx( MBartistID = a_artist_id,
			artist = a_artist,
			mbArtistGID = a_artist_gid,
			datatypes = 'bio,similarartists,compilations',
			lang = event.getArg( 'lang', application.defaultlanguage) ) />
	
	<cfset event.setArg( 'a_struct_info', a_struct_info ) />

</cffunction>


<!--- find out which request


	pnnn = playlist
	
	annn = artist
	
	mnnn = album
	
	tnnn = track --->
	
<cffunction access="public" name="CheckPublicContentRequest" output="false" returntype="void"
		hint="check incoming seo optimized request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<!--- replace spaces with + sign ... this is our default way --->
	<cfset var local = {} />
	
	<!--- ignore stupid ;jsessionid= URL parameters --->
	<!--- <cfset var sRequest = ListFirst( event.getArg( 'request' ), ';') /> --->
	
	<cfset local.stHeaders = GetHttpRequestData().headers />
	
	<!--- 
	
		get the request from the http header
		
		only this solution is compatible with the tomcat / apache load balancer in order to
		tell the machine properly which URL has been requested
	
	 --->
	<cfif NOT StructKeyExists( local.stHeaders, 'X_PLAYLIST_SEO_REQUEST')>
		<!--- that's not possible ... --->
		<cfthrow message="invalid request to #event.getArg( 'request' )#">
	</cfif>
	
	<!--- the original request --->
	<cfset var sOriginalRequest = local.stHeaders.X_PLAYLIST_SEO_REQUEST />
	
	<!--- old stuff, remove jsessionid= ... --->
	<cfif FindNoCase( ';jsessionid', sOriginalRequest) GT 0>
		<cfset sOriginalRequest = ListFirst( sOriginalRequest, ';' ) />
	</cfif>
	
	<!--- e.g. GET /playlist-Bj%C3%B6rk-a1022 HTTP/1.1 --->
	<!--- or: GET /playlist-Lifehouse-a15595?ajax=true&tab=1&rand=0.177454034049467 --->
	<cftry>
		<cfset sRequest = Trim( ListGetAt( sOriginalRequest, 2, ' ' ) ) />
		
		<cfcatch type="any">
			
			<cfthrow message="failed to load request from #sOriginalRequest#">
			
		</cfcatch>		
	</cftry>

	<!--- <cflog application="false" log="Application" text="sOriginalRequest: #sOriginalRequest#" type="information" file="tb_public_log" /> --->
	
	<!--- parameters provided? --->
	<cfif ListLen( sRequest, '?' ) GT 1>
		
		<cfset local.sParams = ListLast( sRequest, '?' ) />
		
		<cfloop list="#local.sParams#" delimiters="&" index="local.sParamKeyValue">
			
			<cfset local.sParamKey = ListFirst( local.sParamKeyValue, '=' ) />
			<cfset local.sParamValue = Mid( local.sParamKeyValue, Len( local.sParamKey ) + 2, Len( local.sParamKeyValue )) />
			
			<cfset event.setArg( local.sParamKey, local.sParamValue ) />
			
		</cfloop>
		
	</cfif>
	
	<!--- remove all parameters ... http://tunesbagdev/playlist-Bj%C3%B6rk-a1022?jsession --->
	<cfset sRequest = ListFirst( sRequest, '?' ) />
	
	<!--- replace %20 with empty space ... why?! --->
	<cfset sRequest = ReplaceNoCase( sRequest, '%20', ' ', 'ALL' ) />
	
	<!--- <cflog application="false" log="Application" text="UrlDecoded: #UrlDecode( sRequest )#" type="information" file="tb_public_log" /> --->
		
	<!--- reset var --->
	<cfset arguments.event.setArg( 'request', sRequest ) />
	
	<!--- the URLDecoded version --->
	<cfset arguments.event.setArg( 'request_urldecoded', UrlDecode( sRequest )) />
	
	<!--- <cfset local.stParseURL = parseUrl( 'http://dummy/?' & ListFirst( cgi.QUERY_STRING, ';' ) ) />
	
	<cfparam name="local.stParseURL.params.url.request" type="string" default="" />
	
	<!--- set the request var ... --->
	<cfset sRequest = local.stParseURL.params.url.request />
		
	<cfset event.setArg( 'request', ReplaceNoCase( sRequest, ' ', '+', 'ALL')) /> --->
	
	<!--- remove trailing / ... just for our comparison, leave the original string untouched! --->
	<cfif Right( sRequest, 1 ) IS '/'>
		<cfset sRequest = Left( sRequest, Len( sRequest ) - 1 ) />
	</cfif>
	
	<!--- <cflog application="false" log="Application" text="check: #sRequest#" type="information" file="tb_public_log"> --->
	
	<!--- check for playlist, artist etc --->
	<cfset var bIsPlaylistRequest = ReFindNoCase( 'p[0-9]*$', sRequest, 1) />
	<cfset var bIsArtistRequest = ReFindNoCase( 'a[0-9]*$', sRequest, 1) />
	<cfset var bIsAlbumRequest = ReFindNoCase( 'm[0-9]*$', sRequest, 1) />
	<cfset var bIsTrackRequest = ReFindNoCase( 't[0-9]*$', sRequest, 1) />
	<cfset var iID = Val( ReFindNoCase( '[0-9]*$', sRequest, 1)) />

	<!--- already called as tab? --->
	<cfset var bAjax = event.getArg( 'ajax', false ) />

	<!--- get the supported TLDs ... com is the default one --->
	<cfset var sSupported_tlds = getAppManager().getPropertyManager().getProperty('supported_tlds') />

	<!--- 
		not called as tab ...
		public viewing + default layout
		--->
		
	<!--- make sure no exception happens --->
	<cfif NOT IsBoolean( bAjax )>
		<cfset bAjax = false />
	</cfif>
		
	<cfif NOT bAjax>
		<!--- yes, it's a public viewing --->
		<cfset event.setArg( 'IsPublicView', true ) />
			
		<!--- modify the layout event --->
		<cfset event.setArg( 'layoutEvent', 'layout.main' ) />
		
		
	</cfif>	
	
	<!--- set the ID now --->
	<cfset iID = Val( Mid( sRequest, iID, Len( sRequest ))) />
	
	<cfset event.setArg( 'iItemID', iID ) />
	
	<!--- any ID found at all? --->
	<cfif iID IS 0 AND NOT bIsTrackRequest>
		<!--- 
		
			try to set as artist request
			
			/playlist-Air
			
			we try to find the ID later
		
		 --->
		<cfset bIsArtistRequest = true />
	</cfif>
	
	<cfset event.setARg( 'bIsArtistRequest', bIsArtistRequest) />
	
	<!--- a special layout event submitted? --->
	<cfif StructKeyExists( local.stHeaders, 'X_layoutEvent') AND Len( local.stHeaders.X_layoutEvent ) GT 0>
		<cfset event.setArg( 'layoutEvent', local.stHeaders.X_layoutEvent ) />
	</cfif>	
	
	<!--- layout format --->
	<cfif StructKeyExists( local.stHeaders, 'X_DocumentOutputFormat') AND Len( local.stHeaders.X_DocumentOutputFormat ) GT 0>
		<cfset event.setArg( 'DocumentOutputFormat', local.stHeaders.X_DocumentOutputFormat ) />
	</cfif>	
	
	
	<!--- have we cached the entire page? --->
	<cfset var sCacheKey = 'c_' & application.udf.generatePublicPageHashKey( bIsArtistRequest, bIsAlbumRequest, bIsTrackRequest, bAjax, event.getArg( 'IsPublicView' ), sOriginalRequest, application.udf.GetCurrentLanguage(), application.udf.IsLoggedIn() , iID) />
	
	<!--- cached version exists? hell, let's serve it! --->
	<cfset event.setArg( 'sCacheKey', sCacheKey)>
	
	<cfset var stCachedVersionExists = getProperty( 'beanFactory' ).getBean( 'SimpleEHCache' ).GetCachedResult( sCacheKey ) />
	
	<cfif stCachedVersionExists.bresult>
		<cfset request.content.final = stCachedVersionExists.oItem />
		<cfset event.setArg( 'stCachedVersionExists', stCachedVersionExists)>
		<cfset announceEvent( 'public.content.serve.cached.content', event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# #sRequest# | ID = #iID# | bIsPlaylistRequest = #bIsPlaylistRequest#" log="Application" type="information" /> --->
	
	<!--- do we need to rewrite the host as well? --->
	
	<!--- // requesting an artist page // --->
	<cfif bIsArtistRequest>
		<cfset announceEvent( 'public.content.request.artist', event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- // requesting a plist // --->
	<cfif bIsPlaylistRequest>
		<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# PLIST request, announcing event public.content.request.playlist" log="Application" type="information" /> --->
		
		<cfset announceEvent( 'public.content.request.playlist', event.getArgs() ) />
		
		<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# PLIST request, announcing event public.content.request.playlist" log="Application" type="information" /> --->
		
	</cfif>
	
	<!--- // album request // --->
	<cfif bIsAlbumRequest>
		<cfset announceEvent( 'public.content.request.album', event.getArgs() ) />
		
	</cfif>
	
	<!--- // track request // --->
	<cfif bIsTrackRequest>
		<cfset announceEvent( 'public.content.request.track', event.getArgs() ) />
	</cfif>

</cffunction>


<cffunction access="public" name="CheckPublicContentRequestPlaylist" output="false" returntype="void"
		hint="check public content request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from CheckPublicContentRequestPlaylist!" log="Application" type="information" /> --->
	
	<cfset var sRequest = event.getArg( 'request' ) />
	<cfset var sRequestUrlDecoded = arguments.event.getArg( 'request_urldecoded' ) />
	<cfset var iItem = event.getArg( 'iItemID' ) />
	<cfset var stSEO = application.beanFactory.getBean( 'SEO' ).getLatestPlaylistURL( iPlaylistID = iItem ) />

	<cfif NOT stSEO.result>
		<!--- TODO: does not exist any more, show error page --->
		<cfheader statuscode="404" />
		<cfabort />
	</cfif>
	
		<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# plist Request, latest URL: #stSEO.sURL#" log="Application" type="information" /> --->
	
	<!--- not the very same? redirect! --->
	<cfif Compare( UrlDecode( stSEO.sURL ), sRequestUrlDecoded) NEQ 0>
		<cfif IsLiveServer()>
			
			<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# plist Request, redirect to http://www.tunesBag.com#stSEO.sURL#" log="Application" type="information" /> --->
			<cflocation addtoken="false" url="http://www.tunesBag.com#stSEO.sURL#" statusCode="301" />
		<cfelse>
			<cflocation addtoken="false" url="#stSEO.sURL#" statusCode="301" />
		</cfif>
	</cfif>
	
	<!--- continue, load plist information --->
	<cfset event.setARg( 'stSEO', stSEO) />
	
	<cfset event.setArg( 'entrykey', stSEO.sEntrykey ) />
	

</cffunction>

<!--- // check the artist request // --->
<cffunction name="CheckPublicContentRequestArtist" access="public" output="false" returntype="void"
		hint="check public artist page request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from CheckPublicContentRequestArtist" log="Application" type="information" /> --->
	<cfset var iId = event.getArg( 'iItemID' ) />
	<cfset var sRequest = event.getArg( 'request' ) />
	<cfset var sRequestUrlDecoded = arguments.event.getArg( 'request_urldecoded' ) />
	<cfset var sTab = '' />
	<cfset var bAjaxRequest = event.getArg( 'ajax', false ) />
	<cfset var local = {} />
	
	<!--- <cflog application="false" file="tb_redir" log="Application" text="sRequest: #sRequest#" type="information" /> --->

	
	<!--- just a try in case we have an URL like /playlist-Air instead of /playlist-Air-a394 --->
	<cfset var sArtistName = ReplaceNoCase( sRequest, '/playlist-', '' ) />

	<!--- no ID given ... try to get it out by query and redirect --->
	<cfif Val( iID ) IS 0>
		<cfset event.setArg( 'sArtistName', sArtistName ) />
		
		<cfset var stLookup = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists(
			artist 		= ReplaceNoCase(ReplaceNoCase( sArtistName, '+', ' ', 'ALL'), '-', ' ', 'ALL'),
			searchmode 	= 0,
			gettags 	= false,
			maxrows 	= 1
			) />
		
		<!--- forward! --->
		<cfif stLookup.result AND stLookup.Q_SELECT_SEARCH_ARTISTS.recordcount GT 0>
			
			<!--- called as tab using ajax? --->
			<cfif bAjaxRequest>
				<cfset sTab = '?ajax=true' />
			</cfif>
			
			<cfif IsLiveServer()>
				<cflocation addtoken="false" url="http://www.tunesBag.com#application.udf.generateArtistURL( stLookup.Q_SELECT_SEARCH_ARTISTS.name, stLookup.Q_SELECT_SEARCH_ARTISTS.id )##sTab#" statusCode="301" />
			<cfelse>
				<cflocation addtoken="false" url="#application.udf.generateArtistURL( stLookup.Q_SELECT_SEARCH_ARTISTS.name, stLookup.Q_SELECT_SEARCH_ARTISTS.id )##sTab#" statusCode="301" />
			</cfif>
			
		
		<cfelse>
		
			<cfset local.sSimpleArtistName = Left( ReReplaceNoCase( sArtistName, '[^a-z,0-9]*', '', 'ALL'), 100) />
			
			<cflog application="false" file="tb_redir" log="Application" text="simple name: #local.sSimpleArtistName#" type="information" />
			
			<cfif Len( local.sSimpleArtistName ) GT 3>
				
				<cfquery name="local.qSelectNameSimple" datasource="mytunesbutler_mb">
				SELECT
					id,
					name
				FROM
					artist
				WHERE
					namesimple LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.sSimpleArtistName#%">
				LIMIT
					3
				;
				</cfquery>
				
				<!--- one hit? --->
				<cfif local.qSelectNameSimple.recordcount IS 1>
				
					<!--- <cflog application="false" file="tb_redir" log="Application" text="target: http://www.tunesBag.com#application.udf.generateArtistURL( local.qSelectNameSimple.name, local.qSelectNameSimple.id )##sTab#" type="information" /> --->

					<!--- 
						
						just make 302 redirects as we're not absolutly sure about this ...
					 --->
					<cfif IsLiveServer()>
						<cflocation addtoken="false" url="http://www.tunesBag.com#application.udf.generateArtistURL( local.qSelectNameSimple.name, local.qSelectNameSimple.id )##sTab#" />
					<cfelse>

						<cflocation addtoken="false" url="#application.udf.generateArtistURL( local.qSelectNameSimple.name, local.qSelectNameSimple.id )##sTab#" />
					</cfif>
					
				</cfif>
			
			</cfif>
			
			<!--- sorry, artist not found ... --->
			<!--- <cfthrow message="handle missing artist name #sArtistName# (looking for #local.sSimpleArtistName#)"> --->
			
			<cflog application="false" file="tb_seo_error" log="Application" text="missing artist: #sArtistName#" type="information" />
			
			<cflocation addtoken="false" url="/404.cfm?missing=#UrlEncodedFormat( sArtistName )#" />
			<cfreturn />
		
		</cfif>
		
	</cfif>
	
	<!--- load the artist information --->
	<cfset var a_struct_search = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists(
			artist 		= '',
			mbids 		= iId,
			searchmode 	= 0,
			gettags 	= true,
			bLoadBio	= true,
			maxrows 	= 1
			) />
			
	<cfset var q_select_artist = a_struct_search.q_select_search_artists />
	
	<!--- generate the very right URL for this artist --->
	<cfset var sArtistURL = application.udf.generateArtistURL( a_struct_search.Q_SELECT_SEARCH_ARTISTS.name, a_struct_search.Q_SELECT_SEARCH_ARTISTS.id ) />
		
	<!---
		not the very same? redirect! 
		
		for example: /playlist-Groove-Armada-a923/
					 /playlist-groove-armada-a923
					 
		only if no ajax request (ajax=True is autmatically added by jQuery)
		
	--->
	<cfif Compare( UrlDecode( sArtistURL ), sRequestUrlDecoded) NEQ 0 AND NOT bAjaxRequest>
	
		<cfif IsLiveServer()>
			<cflocation addtoken="false" url="http://www.tunesBag.com#sArtistURL#" statusCode="301" />
		<cfelse>
		<!--- 	<cfthrow message="#sArtistURL#         #sRequest#"> --->
			<cflocation addtoken="false" url="#sArtistURL#" statusCode="301" />
		</cfif>
	</cfif>
	
	<!--- set data: query, id and gid (string) --->
	<cfset event.setArg( 'q_select_artist', q_select_artist ) />
	<cfset event.setArg( 'mbArtistID', Val( q_select_artist.id ) ) />
	<cfset event.setArg( 'mbArtistGID', q_select_artist.gid ) />
	<cfset event.setArg( 'Artist', q_select_artist.name ) />
	
	<cfif q_select_artist.recordcount IS 0>
		<cfreturn />
	</cfif>
	
	<cfparam name="request.bIsSpiderRequest" type="boolean" default="false" />
	
	<!--- log this hit! --->
	
	<!--- TODO: re-enable using a cookie! --->
	<!--- <cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).logArtistRelatedPageHit( iMBartistid = q_select_artist.id,
				sSessionHash = Hash( client.URLToken ),
				iPage_Type = 0,
				bSpiderHit = request.bIsSpiderRequest ) /> --->
	
	<!--- TODO: use CFTHREAD --->
	
	<!--- get albums of arist --->
	<cfset event.setArg( 'q_select_albums', application.beanFactory.getBean( 'MusicBrainz' ).GetAlbumsOfArtist( artistid = q_select_artist.id, mbdataonly = true ) ) />
	
	<!--- get recent listerns --->
	<cfset event.setArg( 'q_select_recent_listeners', getProperty( 'beanFactory' ).getBean( 'LogComponent' ).getRecentlyPlayedItemsUsers( artistid = q_select_artist.id )) />
	
</cffunction>

<cffunction name="CheckPublicContentRequestAlbum" access="public" output="false" returntype="void" hint="check public artist page request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from CheckPublicContentRequestAlbum" log="Application" type="information" /> --->
	<cfset var iId = event.getArg( 'iItemID' ) />
	<cfset var sRequest = event.getArg( 'request' ) />
	<cfset var sRequestUrlDecoded = arguments.event.getArg( 'request_urldecoded' ) />
	<cfset var sTab = '' />
	<cfset var bAjaxRequest = event.getArg( 'ajax', false ) />
	<cfset var local = {} />
	
	<cfif Val( iId ) IS 0>
		<cfthrow message="invalid call to album page #cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" />
	</cfif>
	
	<!--- generate the latest album id and check if it'S the same --->
	<cfset local.stGetAlbum = application.beanFactory.getBean( 'MusicBrainz' ).GetAlbumsByID( albumids = iId, bIgnoreCustomAlbums = true ) />
	
	<!--- album not found --->
	<cfif NOT local.stGetAlbum.result>
		<!--- TODO: #404 site --->
		<cflocation addtoken="false" url="/404.cfm">
	</cfif>
	
	<cfset local.qAlbum = local.stGetAlbum.Q_SELECT_ALBUMS_BY_IDS />
	
	<cfset local.sCorrectAlbumURL = generateAlbumURL( local.qAlbum.artist_name, local.qAlbum.name, local.qAlbum.id ) />
	
	<!--- URL ok? --->
	<cfif Compare( URLDecode( local.sCorrectAlbumURL ), sRequestUrlDecoded) NEQ 0 AND NOT bAjaxRequest>
		<cfif IsLiveServer()>
			
			<cflocation addtoken="false" url="http://www.tunesBag.com#local.sCorrectAlbumURL#" statusCode="301" />
		<cfelse>
			<cflocation addtoken="false" url="#local.sCorrectAlbumURL#" statusCode="301" />
		</cfif>
	</cfif>
	
	<!--- set ID + artist --->
	<cfset event.setArg( 'Artist', local.qAlbum.artist_name ) />
	<cfset event.setArg( 'mbAlbumID', local.qAlbum.id ) />
	
	<cfparam name="request.bIsSpiderRequest" type="boolean" default="false" />
	
	<!--- log this hit! --->
	<!--- <cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).logArtistRelatedPageHit( iMBartistid = local.qAlbum.artist,
				sSessionHash = Hash( session.SessionID ),
				iPage_Type = 1,
				iAsset_MBID = local.qAlbum.id,
				bSpiderHit = request.bIsSpiderRequest ) /> --->

</cffunction>

<cffunction name="CheckPublicContentRequestTrack" access="public" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from CheckPublicContentRequestTrack" log="Application" type="information" /> --->
	<cfset var iId = event.getArg( 'iItemID' ) />
	<cfset var sRequest = event.getArg( 'request' ) />
	<cfset var sRequestUrlDecoded = arguments.event.getArg( 'request_urldecoded' ) />
	<cfset var sTab = '' />
	<cfset var bAjaxRequest = event.getArg( 'ajax', false ) />
	<cfset var local = {} />
	
	<cfif Val( iId ) IS 0>
		<cfheader statuscode="404">
<!--- 		<cfthrow message="invalid call to track page #cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" /> --->
	</cfif>
	
	<cfset event.setArg( 'mbTrackID', iId ) />
	
	<cfset local.stTrackInfo = application.beanFactory.getBean( 'MusicBrainz' ).qSelectSimpleTrackArtistRelation( iId ) />
	
	<cfif NOT local.stTrackInfo.result>
		<cflocation addtoken="false" url="/404.cfm">
	</cfif>
	
	<cfset local.qTrack = local.stTrackInfo.QSELECTSIMPLETRACKARTISTRELATION />
	<cfset local.sCorrectTrackURL = generateGenericURLToTrack( local.qTrack.artist, local.qTrack.name, local.qTrack.track_id, '' ) />
	
	<!--- URL ok? --->
	<cfif Compare( URLDecode( local.sCorrectTrackURL ), sRequestUrlDecoded) NEQ 0 AND NOT bAjaxRequest>
		<cfif IsLiveServer()>
			
			<!--- <cflog application="false" log="Application" text="REDIRECT: #local.sCorrectTrackURL#" type="information" file="tb_public_log" />
			<cflog application="false" log="Application" text="REDIRECT urlDecoded: #URLDecode( local.sCorrectTrackURL )# vs #sRequestUrlDecoded#" type="information" file="tb_public_log" /> --->
			
			
			<cflocation addtoken="false" url="http://www.tunesBag.com#local.sCorrectTrackURL#" statusCode="301" />
		<cfelse>
			<cflocation addtoken="false" url="#local.sCorrectTrackURL#" statusCode="301" />
		</cfif>
	</cfif>
	
	<cfparam name="request.bIsSpiderRequest" type="boolean" default="false" />
	
	<!--- log this hit! --->
	<!--- <cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).logArtistRelatedPageHit( iMBartistid = local.qTrack.artist_id,
				sSessionHash = Hash( session.SessionID ),
				iPage_Type = 2,
				iAsset_MBID = local.qTrack.track_id,
				bSpiderHit = request.bIsSpiderRequest ) />	 --->
				
</cffunction>




<!--- old --->

<cffunction access="public" name="CheckMusicContentInfoRequest" output="false" returntype="void"
		hint="check type of incoming info request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- check which  --->
	<cfset var a_str_request = event.getArg( 'req' ) />
	
	<!--- requests may look like
	
		/music/Air
		/music/Air/
		/music/Air/Talkie+Walkie
		/music/Air/Talkie+Walkie/2938-where-is-the-love.html
	
		 --->
	<cfset var a_arr = 0 />

	<!--- already called as tab? --->
	<cfset var a_bol_called_as_tab = event.getArg( 'tab' ) IS 1 />

	
	<cfset a_str_request = ReplaceNoCase( a_str_request, '/music/', '' ) />
	
	<cfset a_arr = ListToArray( a_str_request, '/' ) />	 
	
	<!--- <cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from CheckMusicContentInfoRequest" log="Application" type="information" /> --->
	
	<!--- invalid request --->
	<cfif ArrayLen( a_arr ) IS 0>
		<cflocation addtoken="false" url="/">
	</cfif>
	
	<cfset event.setArg( 'request', a_arr ) />
	
	<!---  not called as tab ... public viewing + default layout --->
	<cfif NOT a_bol_called_as_tab>
		<!--- yes, it's a public viewing --->
		<cfset event.setArg( 'IsPublicView', true ) />
			
		<!--- modify the layout event --->
		<cfset event.setArg( 'layoutEvent', 'layout.main' ) />
	</cfif>	
	
	<!--- just one item ... artist --->
	<cfif ArrayLen( a_arr ) IS 1>
		<cfset event.setarg( 'type', 'artist' ) />
		<cfset announceEvent( 'music.content.info.artist', event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- two items ... album --->
	<cfif ArrayLen( a_arr ) IS 2>
		<cfset event.setarg( 'type', 'album' ) />
		<cfset announceEvent( 'music.content.info.album', event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- three items ... track --->
	<cfif ArrayLen( a_arr ) IS 3>
		<cfset event.setarg( 'type', 'track' ) />
		
		<cfset announceEvent( 'music.content.info.track', event.getArgs() ) />
	</cfif>
	

</cffunction>

<cffunction access="public" name="CheckPublicTrackInfo" output="false" returntype="void"
		hint="get info for track by trackkey">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_request = event.getArg( 'req' ) />
	<cfset var a_arr = ListToArray( a_str_request, '/' ) />
	
	<!--- invalid request ... no entrykey provided --->
	<cfif ArrayLen( a_arr ) LTE 1>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'trackkey', a_arr[2] ) />

</cffunction>

<cffunction access="public" name="CheckPublicStatusInfo" output="false" returntype="void"
		hint="get info for status msg">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_request = event.getArg( 'req' ) />
	<cfset var a_arr = ListToArray( a_str_request, '/' ) />
	
	<!--- invalid request ... no entrykey provided --->
	<cfif ArrayLen( a_arr ) LTE 1>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'entrykey', a_arr[2] ) />

</cffunction>

<cffunction access="public" name="CheckPublicUserInfo" output="false" returntype="void"
		hint="check the public access info when displaying user information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- the full request --->
	<cfset var a_str_request = event.getArg( 'req' ) />
	<!--- parse the full provided request by the apache rewrite rule, e.g.
	
			/user/username/
			
			might also be
			
			/user/username/friends/
			
			etc ...
	
		 --->
	<cfset var a_arr = ListToArray( a_str_request, '/' ) />
	
	<!--- already called as tab? --->
	<cfset var a_bol_called_as_tab = event.getArg( 'tab' ) IS '1' />
	
	<!--- maybe already provided username --->
	<cfset var a_str_already_provided_username = event.getArg( 'username' ) />
	
	<!--- invalid request ... no username provided --->
	<cfif ArrayLen( a_arr ) LTE 1>
		<cfreturn />
	</cfif>
	
	<!--- set the username --->
	<cfif Len( a_str_already_provided_username ) IS 0>
		<cfset event.setArg( 'username', a_arr[2] ) />	
	</cfif>
	
	<!---  not called as tab ... public viewing + default layout --->
	<cfif NOT a_bol_called_as_tab>
		<!--- yes, it's a public viewing --->
		<cfset event.setArg( 'IsPublicView', true ) />
			
		<!--- modify the layout event --->
		<cfset event.setArg( 'layoutEvent', 'layout.main' ) />
	</cfif>
	
</cffunction>

<!---
	legacy redirect for tracks
--->

<cffunction access="public" name="LegacyRedirectCheckPublicTrack" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<cfset var local = {} />
	<cfset var a_str_request = event.getArg( 'req' ) />
	<cfset var a_track_info = ListLast( a_str_request, '/' ) />
	<cfset var a_track_id = Val( ListFirst( a_track_info, '-' )) />
	<!--- 	<cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from LegacyRedirectCheckPublicTrack" log="Application" type="information" /> --->
	<!--- invalid request? --->
	<cfif a_track_id IS 0>
		<cflocation addtoken="false" url="/">
	</cfif>
	
	<cfset local.stTrackInfo = application.beanFactory.getBean( 'MusicBrainz' ).qSelectSimpleTrackArtistRelation( a_track_id ) />
	
	<cfif NOT local.stTrackInfo.result>
		<cflocation addtoken="false" url="/404.cfm">
	</cfif>
	
	<cfset local.qTrack = local.stTrackInfo.QSELECTSIMPLETRACKARTISTRELATION />
	<cfset local.sCorrectTrackURL = generateGenericURLToTrack( local.qTrack.artist, local.qTrack.name, local.qTrack.track_id, '' ) />
	
	<!--- URL ok? --->
	<cfif IsLiveServer()>
		<cflocation addtoken="false" url="http://www.tunesBag.com#local.sCorrectTrackURL#" statusCode="301" />
	<cfelse>
		<cflocation addtoken="false" url="#local.sCorrectTrackURL#" statusCode="301" />
	</cfif>

</cffunction>

<!---

	legacy redirector for album
	
	--->

<cffunction access="public" name="LegacyRedirectCheckPublicAlbum" output="false" returntype="void"
		hint="generate album redirector">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<cfset var local = {} />
	<cfset var a_req = event.getArg( 'request' ) />
	<cfset var iAlbumID = Val( ListFirst( a_req[2], '-' )) />
<!--- 			<cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from LegacyRedirectCheckPublicAlbum" log="Application" type="information" /> --->
	<cfif Val( iAlbumID ) IS 0>
		<cflocation addtoken="false" url="/">
	</cfif>
	
	<!--- generate the latest album id and check if it'S the same --->
	<cfset local.stGetAlbum = application.beanFactory.getBean( 'MusicBrainz' ).GetAlbumsByID( albumids = iAlbumID, bIgnoreCustomAlbums = true ) />
	
	<!--- album not found --->
	<cfif NOT local.stGetAlbum.result OR local.stGetAlbum.Q_SELECT_ALBUMS_BY_IDS.recordcount IS 0>
		<!--- TODO: #4040 site --->
		<cflocation addtoken="false" url="/404.cfm">
	</cfif>
	
	<cfset local.qAlbum = local.stGetAlbum.Q_SELECT_ALBUMS_BY_IDS />
	
	<!--- get the correct redirector URL --->	
	<cfset local.sCorrectAlbumURL = generateAlbumURL( local.qAlbum.artist_name, local.qAlbum.name, local.qAlbum.id ) />
	
	<cfif IsLiveServer()>
		<cflocation addtoken="false" url="http://www.tunesBag.com#local.sCorrectAlbumURL#" statusCode="301" />
	<cfelse>
		<cflocation addtoken="false" url="#local.sCorrectAlbumURL#" statusCode="301" />
	</cfif>

	
</cffunction>

<!--- 

	this is the legacy redirector
	
	/music/Air

 --->

<cffunction access="public" name="LegacyRedirectCheckPublicArtist" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<cfset var a_req = event.getArg( 'request' ) />
	<cfset var a_artist = a_req[ 1 ] />
	<cfset var local = {} />
	
	<!--- simple search --->
	<cfset local.stSearch = application.beanFactory.getBean( 'MusicBrainz' ).SearchForArtists( artist = a_artist, searchmode = 0, gettags = false, maxrows = 1 ) />
<!--- 				<cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from LegacyRedirectCheckPublicArtist" log="Application" type="information" /> --->
	<cfif NOT local.stSearch.result>
		<cflocation addtoken="false" url="/404.cfm">
	</cfif>
	
	<!--- redirect ... --->
	<cfset local.sRedirectURL = application.udf.generateArtistURL( local.stSearch.Q_SELECT_SEARCH_ARTISTS.name, local.stSearch.Q_SELECT_SEARCH_ARTISTS.id ) />
	
	<cfif NOT IsLiveServer()>
		<cflocation addtoken="false" url="#local.sRedirectURL#" statusCode="301" />
	<cfelse>
		<cflocation addtoken="false" url="http://www.tunesBag.com#local.sRedirectURL#" statusCode="301" />
	</cfif>	

</cffunction>

<!---
	
	this is a legacy function to handle old

	http://en.tunesBag.com/playlist/7351D39A-946F-4ACB-869FE05D48CBE267/uk-stuff.html
	
	requests and map them to the new URL system
	
	--->
<cffunction access="public" name="LegacyRedirectCheckPublicPlaylistInfo" output="false" returntype="void"
		hint="check the public access data when performing a playlist request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<!--- the full request 
	
		look like /playlist/UUID
	
	--->
	<cfset var local = {} />
	<cfset var a_str_request = event.getArg( 'req' ) />
	<cfset var a_arr = ListToArray( a_str_request, '/' ) />
	
	<!--- already called as tab? --->
	<cfset var a_bol_called_as_tab = event.getArg( 'tab' ) IS '1' />
	
	<!--- maybe already provided username --->
	<cfset var a_str_already_provided_entrykey = event.getArg( 'entrykey' ) />
<!--- 					<cflog application="false"  file="tb_redir" text="#cgi.REMOTE_ADDR# hello from LegacyRedirectCheckPublicPlaylistInfo" log="Application" type="information" /> --->
	<!--- invalid request ... no plist provided --->
	<cfif ArrayLen( a_arr ) LTE 1>
		<cfreturn />
	</cfif>
	
	<!--- set the username --->
	<cfif Len( a_str_already_provided_entrykey ) IS 0>
		<cfset event.setArg( 'entrykey', a_arr[2] ) />	
	</cfif>
	
	<!--- invalid request? --->
	<cfif Len( event.getArg( 'entrykey' )) IS 0>
		<cflocation addtoken="false" url="/" />
		<cfreturn />
	</cfif>
	
	<!--- get latest URL of this plist --->
	<cfset local.stSEO = getProperty( 'beanFactory' ).getBean( 'SEO' ).getLatestPlaylistURL( sPlaylistEntrykey = event.getArg('entrykey' )) />
	
	<cfif NOT local.stSEO.result>
		<cflocation addtoken="false" url="/" />
		<cfreturn />
	</cfif>
	
	<!--- are we on a dev server or on the live system for redirection reasons? --->
	<cfif NOT IsLiveServer()>
		<!--- 
			
			example: http://tunesbagdev/playlist/7351D39A-946F-4ACB-869FE05D48CBE267/test.html
		
		 --->
		<cflocation addtoken="false" url="#local.stSEO.sURL#" statusCode="301" />
	<cfelse>
		<!--- valid for all tlds 
		
			TODO: check for #cgi.SERVER_NAME#
		--->
		<cflocation addtoken="false" url="http://www.tunesBag.com#local.stSEO.sURL#" statusCode="301" />
	</cfif>
	
</cffunction>

</cfcomponent>