<!---

	tunesBag.com REST api
	
	Provide access to the most important features for other applications
	
	Supporting JSON / XML
	
	(c) 2008-2009 tunesBag.com Ltd

--->

<cfcomponent name="rest" displayname="rest"output="false" extends="MachII.framework.Listener" hint="Handle REST calls">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="GetAllEnabledApplications" output="false" returntype="void"
		hint="return all known apps">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'q_select_all_applications', getProperty( 'beanFactory' ).getBean( 'RESTAPIComponent' ).GetAllEnabledApplications() ) />

</cffunction>

<cffunction access="public" name="CheckIssueRemoteKey" output="false" returntype="void"
		hint="Issue a remote key">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- only for registered users ... --->
	<cfif NOT application.udf.IsLoggedIn()>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'a_str_app_remote_key', getProperty( 'beanFactory' ).getBean( 'RESTAPIComponent' ).IssueRemoteKeyForApplication( appkey = event.getArg( 'appkey' ),
									securitycontext = application.udf.GetCurrentSecurityContext() ) ) />
	
</cffunction>

<cffunction access="private" name="getAPIUserRemotekeyPath" output="false" returntype="string">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<cfreturn '&amp;appkey=' & event.getArg( 'appkey' )
				& '&amp;username=' & event.getArg( 'username' )
				& '&amp;remotekey=' & event.getArg( 'remotekey' )
				& '&amp;sessionkey=' & event.getArg( 'sessionkey' ) />
</cffunction>

<cffunction name="CheckRestRequest" access="public" output="false" returntype="void" hint="Check incoming REST request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- name of request --->
	<cfset var a_str_request = event.getArg( 'request' ) />
	<!--- username --->
	<cfset var a_str_username = event.getArg( 'username' ) />
	<!--- password --->
	<cfset var a_str_hash_password = event.getArg( 'hashpassword' ) />
	<cfset var a_str_userkey = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetEntrykeyByUsername( a_str_username ) />
	<cfset var a_str_remotekey = event.getArg( 'remotekey' ) />
	<cfset var a_str_appkey = event.getArg( 'appkey' ) />
	<!--- desired return format (e.g. JSON / XML) --->
	<cfset var a_str_format = event.getArg( 'format', 'XML' ) />
	<!--- return structure --->
	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
	<!--- helper vars --->
	<cfset var a_struct_call = 0 />
	<cfset var a_str_req_key = CreateUUID() />
	<cfset var oApi = getProperty( 'beanFactory' ).getBean( 'RestAPIComponent' ) />
	<!--- check if app is valid --->
	<cfset var stApp = oApi.getAppByAppkey( a_str_appkey ) />
	<!--- does the feature need auth? --->
	<cfset var a_bol_auth_needed = true />
	<cfset var a_bol_security_check_result = false />
	<cfset var a_struct_securitycontext = '' />
	<cfset var a_struct_get_data = 0 />
	<cfset var a_struct_get_data_2 = 0 />
	<cfset var a_struct_get_data_3 = 0 />
	<cfset var a_str_playlist_filename = '' />
	<cfset var a_str_content = '' />
	<cfset var a_struct_filter = StructNew() />
	<cfset var a_tc_start = GetTickCount() />
	<cfset var a_struct_quota = 0 />
	<cfset var a_str_librarykey = '' />
	<cfset var a_str_player_id = '' />
	<cfset var a_str_player_file = '' />
	<cfset var q_select_data = 0 />
	<cfset var q_select_items = 0 />
	<cfset var a_str_data = '' />
	<cfset var sData = '' />
	<cfset var local = {} />
	
	<!--- caching ... --->
	<cfset local.oCache = getProperty( 'beanFactory' ).getBean( 'SimpleCache' ) />

	<!--- replace all slashed with dots --->
	<cfset event.setArg( 'request', Replace( ReplaceNoCase( Trim(ReplaceNoCase( a_str_request, '/', ' ', 'ALL' )), ' ', '.', 'ALL' ), 'api.rest.', '')) />
	<cfset event.setArg( 'format', a_str_format ) />
	
	<!--- start check ... begin with app key --->
	<cfif NOT stApp.result>
		<cfset event.setArg( 'a_struct_return', application.udf.SetReturnStructErrorCode( a_struct_return, 20001,  'Unknown or invalid application key. Please apply for a new one or contact the support team.')) />
		<cfreturn />
	</cfif>
	
	<!--- is user verification needed? --->
	<cfset a_bol_auth_needed = ListFindNoCase( 'public.content,test.ping,mobile.user.authrequest,user.create,internal.streaming.getconvertdata,internal.streaming.submitstat,internal.widget.notifyembedding,internal.widget.streamtrack,internal.widget.logplaystatus', event.getArg( 'request' ) ) IS 0 />
	
	<!--- perform check of user identity --->
	<cfif a_bol_auth_needed>
	
		<!--- perform security check (remotekey or password hash) --->
		<cfset a_bol_security_check_result = oAPI.checkUserRemoteKeySecurity( appkey = a_str_appkey,
																userkey = a_str_userkey,
																username = a_str_username,
																remotekey = a_str_remotekey,
																hashpassword = a_str_hash_password ) />

		<!--- failed --->
		<cfif NOT a_bol_security_check_result>
			
			<cflog application="false" file="tb_api_auth_failed" log="Application" type="information" text="appkey: #a_str_appkey#; username: #a_str_username#; remotekey: #a_str_remotekey#; hashpassword: #a_str_hash_password#">
			
			<cfset event.setArg( 'a_struct_return', application.udf.SetReturnStructErrorCode( a_struct_return, 20010,  'Access forbidden - please check the username and remotekey. Make sure the user has accepted your application request.' )) />
			<cfreturn />
		</cfif>
		
		<!--- generate the security context --->
		<cfset local.sCacheIdentifier = 'securitycontext_api_' & a_str_userkey />
		
		<!--- try to read from cache --->
		<cfset local.stCachedSecContext = oCache.GETCACHEDRESULT( sIdentifier = local.sCacheIdentifier ) />
		
		<cfif local.stCachedSecContext.bresult>
			<cfset a_struct_securitycontext = local.stCachedSecContext.oItem />
		<cfelse>
			<!--- read + store in cache --->
			<cfset a_struct_securitycontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( a_str_userkey ) />

			<cfset local.oCache.AddItemToCache( sIdentifier = local.sCacheIdentifier, oItem = a_struct_securitycontext, iMaxAgeMinutes = application.DefaultSimpleCacheTimeoutMin ) />
		</cfif>
		
	</cfif>
	
	<!--- log the request --->
	<cfset LogAPIRequest( logkey = a_str_req_key,
						  params = event.getArgs(),
						  requestname = event.getARg( 'request' ),
						  applicationkey = a_str_appkey,
						  userkey = a_str_userkey,
						  ip = cgi.REMOTE_ADDR ) />
	
	
	<cfswitch expression="#event.getArg( 'request' )#">
		<cfcase value="public.content">
			<!--- deliver public content --->
			
			<cfswitch expression="#event.getArg( 'type' )#">
				<cfcase value="concerts">
					<cfset local.stData = application.beanFactory.getBean( 'Songkick' ).getEvents( iMB_ArtistID = Val( event.getArg( 'mb_artistid' )), bFetchFromProvider = true ) />
					
					<cfif local.stData.result>
						<cfset a_struct_return.html = application.beanFactory.getBean( 'Songkick' ).formatEventData( local.stData.qEvents ) />
						
						<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
					<cfelse>

						<!--- otherwise, return the error --->
						<cfset application.udf.SetReturnStructErrorCode( a_struct_return, 404, 'No concerts found') />
						
					</cfif>
				</cfcase>
			</cfswitch>
			
		</cfcase>
		<cfcase value="internal.streaming.getconvertdata">
		
			<!--- get internal convert data --->
			<cfset a_struct_return = application.beanFactory.getBean( 'AudioConverter' ).getStreamingJobConvertdata( jobkey = event.getArg( 'jobkey' ) ) />
		
		</cfcase>
		<cfcase value="internal.streaming.submitstat">
		
			<!--- submit statistics ... returns nothing --->
			<cfset application.beanFactory.getBean( 'LogComponent' ).LogStreamingNodeStat( jobkey = event.getArg( 'jobkey' ),
										readfromcache = Val( event.getArg( 'readfromcache' ) ) ) />
										
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
		
		</cfcase>
		<cfcase value="internal.db.createdb">
		
			<!--- return a full SQLite database --->
			<cfset a_struct_get_data = oAPI.CreateIPhoneAppDB( securitycontext = a_struct_securitycontext ) />
			
			<cfcontent deletefile="false" type="binary/unknown" file="#a_struct_get_data.filename#">
		
		</cfcase>
		<cfcase value="internal.widget.notifyembedding">
			
			<!--- a widget with a playlist has been embedded somewhere ...
				  notify our server about this and return the basic information for this --->
			<cfset var sPlistkey = event.getArg( 'setkey' ) />
			<cfset var sIP = cgi.REMOTE_ADDR />
			<cfset var sReferer = cgi.HTTP_REFERER />
			<cfset var sUserAgent = cgi.HTTP_USER_AGENT />
			
			<cfif Len( event.getArg( 'location' ) ) IS 0>
				<cfset event.setArg( 'location', cgi.HTTP_REFERER ) />
			</cfif>
			
			<!--- start with logging ... --->
			<cfset var stLog = getProperty( 'beanFactory' ).getBean( 'WidgetComponent' ).logWidgetEmbedding(
						sSource = event.getArg( 'source' ),
						sWidgetkey = a_str_appkey,
						sPlistkey = sPlistkey,
						sUserAgent = sUserAgent,
						sIP = sIP,
						sLocation = event.getArg( 'location')) />
						
			<!--- this is the new "session key" --->
			<cfset var sSessionkey = stLog.sEntrykey />
			
			<!--- check if the security allows playing of plists in this country --->
			<cfset var stPlistSecurity = getProperty( 'beanFactory' ).getBean( 'WidgetComponent' ).checkEmbedSecurity( sPlistkey = sPlistkey,
						sIP = sIP,
						sWidgetkey = a_str_appkey ) />
						
			<!--- check the result --->
			<cfif NOT stPlistSecurity.result>
				<cfset a_struct_return = stPlistSecurity />
				
			<cfelse>
			
				<!--- SUCCESS - continue! --->
			
				<!--- add cover field --->

				<cfset QueryAddColumn( stPlistSecurity.QPLIST, 'coverart', 'Varchar', ArrayNew(1) ) />
				<cfset QuerySetCell( stPlistSecurity.QPLIST, 'coverart', 'http://' & cgi.HTTP_HOST & application.udf.getPlistImageLink( stPlistSecurity.QPLIST.entrykey, 120), 1 ) />
				
				<!--- ok, now return the data --->
				<cfset a_struct_return.sessionkey = sSessionkey />
				<cfset a_struct_return.meta = stPlistSecurity.QPLIST />
				<cfset a_struct_return.items = stPlistSecurity.QPLISTITEMS />
				
				<cfset a_struct_return.stRight = stPlistSecurity.STSECURITYCONTEXT.RIGHTS.playlist />
				
				<!--- <cfmail from="hansjoerg@tunesBag.com" to="hansjoerg@tunesBag.com" type="html" subject="plist">
				<cfdump var="#stPlistSecurity#">
				<cfdump var="#a_struct_return#">
				<cfdump var="#event.getArgs()#">
				</cfmail> --->
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
			</cfif>
			
			
			
		</cfcase>
		<cfcase value="internal.widget.streamtrack">
			<!--- stream a track to the widget --->
			<cfset var sSessionkey = event.getArg( 'sessionkey' ) />
			
			<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'WidgetComponent' ).checkEmbedDeliverTrack( sWidgetKey = event.getArg( 'appkey' ),
						sSessionkey = sSessionkey,
						sIP = cgi.REMOTE_ADDR,
						sTrackKey = event.getArg( 'entrykey')) />
		</cfcase>
		<cfcase value="internal.widget.logplaystatus">
			
			<!--- log seconds played --->
			<cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).LogMediaItemPlayPingBySessionkey( sessionkey = event.getArg( 'sessionkey' ),
						mediaitemkey = event.getArg( 'entrykey' ),
						applicationkey = event.getArg( 'appkey' ),
						secondsplayed = Val( event.getArg( 'seconds' ) )) />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			
		</cfcase>
		<cfcase value="test.ping">
		
			<!--- dummy request --->
			<cfset a_struct_return = TestPing( event= arguments.event ) />
	
		</cfcase>	
		<cfcase value="mobile.user.authrequest">
			<!--- login from mobile user --->
			
			<!--- check pwd ... TODO: migrate to MD5 --->
			<cfset local.stCheckLoginData = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).CheckLoginData( username = event.getArg( 'username' ), password = event.getArg( 'password' ) ) />
			
			<cfif NOT local.stCheckLoginData.result>
				<cfset application.udf.SetReturnStructErrorCode( a_struct_return, 403, 'Invalid access data.' ) />
			<cfelse>
				
				<!--- issue remote key --->
				<cfset a_struct_securitycontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserName( event.getArg( 'username' ) ) />
				
				<cfset local.sRemotekey = getProperty( 'beanFactory' ).getBean( 'RESTAPIComponent' ).IssueRemoteKeyForApplication( appkey = event.getArg( 'appkey' ), securitycontext = a_struct_securitycontext ) />
			
				<cfset a_struct_return.remotekey = local.sRemotekey />
				
				<!--- <cfset a_struct_return.firstname = a_struct_securitycontext.firstname /> --->
				
				<!--- return true --->
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			</cfif>
			
		
		</cfcase>
		<cfcase value="mobile.logbackback">
			
			<!--- log playback status --->
			
			
			
		</cfcase>
		<cfcase value="mobile.getTrackAdditionalContent">
			
			
			
		</cfcase>
		<cfcase value="player.remotecontrol">
		
			
			<!--- player remote control --->
			
			<cfswitch expression="#event.getArg( 'action' )#">
				<cfcase value="plist.load">
					
					<!--- play a plist --->
					
					<cfset local.stSendMsg = application.beanFactory.getBean( 'RemoteService' ).sendRemoteControlCommand(
						stContext	= a_struct_securitycontext,
						sAction		= event.getArg( 'action' ),
						stParams	= {
							'playlistkey'	= event.getArg( 'playlistkey' ),
							'forceplay'		= true
							}
						) />
						
				</cfcase>
				<cfcase value="item.play">
					
					<!--- play a single item --->
					
					<cfset local.stSendMsg = application.beanFactory.getBean( 'RemoteService' ).sendRemoteControlCommand(
						stContext	= a_struct_securitycontext,
						sAction		= event.getArg( 'action' ),
						stParams	= {
							'plistkey'		= event.getArg( 'plistkey' ),
							'mediaitemkey'	= event.getArg( 'mediaitemkey' ),
							'context'		= 0
							}
						) />
					
				</cfcase>
			</cfswitch>
			
			
				
			<cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="remote control" type="html">
			<cfdump var="#event.getArgs()#">
			<cfdump var="#local.stSendMsg#">
			</cfmail>
			
		</cfcase>
		<cfcase value="items.add">
			
			<!--- add a media item --->
			
			<cfset a_struct_quota = getProperty( 'beanFactory' ).getBean( 'StorageComponent' ).GetQuotaDataOfUser( userkey = a_str_userkey ) />
			
			<!--- over quota ... exit and return error message ... --->
			<cfif NOT a_struct_quota.result>
			
				<cfset a_struct_return = a_struct_quota />
				
			<cfelse>
			
				<!--- return location to upload the file --->
					
				<!--- TODO: VarSCOPE --->
				<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'UploadComponent' ).IssueUploadAuthkey( securitycontext = a_struct_securitycontext,
							ip = cgi.REMOTE_ADDR,
							runkey = CreateUUID() ) />
	
				<cfset var a_auth_info = a_struct_get_data />
				<cfset var a_str_uploadrunkey = a_auth_info.runkey />
				<cfset var a_str_authkey = a_auth_info.Authkey />
				
				<cfset var stUploadServer = getProperty( 'beanFactory' ).getBean( 'Server' ).getUploadEngineAssignment( a_struct_securitycontext ) />

				<cfset var sUploadHandlerURL = 'http://' & stUploadServer.sServerName & '/processing/?event=upload&authkey=' & a_str_authkey & '&userkey=' & a_struct_securitycontext.entrykey & '&runkey=' & a_str_uploadrunkey />

				<!--- TODO: development mode? --->
				<cfif application.udf.IsDevelopmentServer()>
					<cfset sUploadHandlerURL = 'http://tunesbagincomingdev/processing/?event=upload&authkey=' & a_str_authkey & '&userkey=' & a_struct_securitycontext.entrykey & '&runkey=' & a_str_uploadrunkey />
				</cfif>
				
				<cfset a_struct_return.Location = sUploadHandlerURL />
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			
			</cfif>
			
		</cfcase>
		<cfcase value="items.rate">
					
			<!--- rate an item --->			
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).RateItem(securitycontext = a_struct_securitycontext,
												rating = event.getArg( 'rating', 0 ),
												librarykey = '',
												mediaitemkey = event.getArg( 'entrykey' ),
												mbid = val( event.getArg( 'mbid'))) />
				
			<!--- return the result --->								
			<cfif a_struct_get_data.result>
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			<cfelse>
				<cfset a_struct_return = a_struct_get_data />
			</cfif>
		
		</cfcase>
		<cfcase value="items.library.lastkey">
			<!--- get the last key for this library --->
			<cfset a_str_librarykey = event.getArg( 'librarykeys' ) />
			
			<cfif Len( a_str_librarykey ) IS 0>
				<cfset a_str_librarykey = a_struct_securitycontext.defaultlibrarykey />
			</cfif>
			
			<!--- get query --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetLibrariesLastKeys( a_str_librarykey ) />
			
			<cfset a_struct_return.items = a_struct_get_data />		
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
			
		</cfcase>
		<cfcase value="items.get">
		
			<!--- return all mediaitems --->
			<cfset a_struct_get_data = GetItems( securitycontext = a_struct_securitycontext,
												event = arguments.event ) />
												
			<!--- which librarykeys has been given? --->
			<cfif Len( event.getArg( 'librarykeys' )) GT 0>
				<!--- take the first one of the list --->
				<cfset a_str_librarykey = ListFirst( event.getArg( 'librarykeys' )) />
			<cfelse>
				<cfset a_str_librarykey = a_struct_securitycontext.defaultlibrarykey />
			</cfif>
							
			<!--- return data + lastkey --->					
			<cfif NOT a_struct_get_data.result>
				<cfset a_struct_return = a_struct_get_data />
			<cfelse>
				<!--- items itself --->
				<cfset a_struct_return.items = a_struct_get_data.q_select_items />
				
				<!--- unique data --->
				<cfif StructKeyExists( a_struct_get_data, 'uniqueData')>
					<cfset a_struct_return.uniquedata = a_struct_get_data.uniqueData />
				</cfif>

				<cfset a_struct_return.lastkey = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetLibraryLastkey( a_str_librarykey ) />
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			</cfif>
			
		</cfcase>
		<cfcase value="items.get.deliver.player,set.deliver.player">
			
			<cfset a_str_player_id = 'player_' & ReplaceNoCase( CreateUUID(), '-', '', 'ALL' ) />
			<cfset a_str_player_file = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/api/rest/items/get/deliver/?targetbitrate=96&entrykey=' & UrlEncodedFormat( event.getArg( 'entrykey') ) & '&appkey=' & urlencodedformat( a_str_appkey ) & '&username=' & UrlEncodedFormat( a_str_username) & '&remotekey=' & UrlEncodedFormat( a_str_remotekey ) & '&options=logplayed,FORWARDTOPLAYURL' />
		
			<!--- deliver the full player HTML code for an item or playlist --->
			<cfsavecontent variable="a_str_content">
				
				<script type="text/javascript" src="http://www.tunesBag.com/static/demos/swfobject.js"></script>
			
				<div id="<cfoutput>#a_str_player_id#</cfoutput>">This text will be replaced</div>
				
				<script type="text/javascript">
				var so = new SWFObject('http://www.tunesBag.com/static/demos/player.swf','mpl','470','20','9');
				so.addParam('allowscriptaccess','always');
				so.addParam('allowfullscreen','true');
				so.addParam('flashvars','&type=mp3<cfif ListFindNoCase( event.getArg( 'options' ), 'autostart' )>&autostart=true</cfif>&file=<cfoutput>#urlencodedformat( a_str_player_file )#</cfoutput>');
				so.write('<cfoutput>#a_str_player_id#</cfoutput>');
				</script>
			
			</cfsavecontent>
			<cfset a_struct_return.content = a_str_content />
			
			<cfset application.udf.SetReturnStructSuccessCode ( a_struct_return ) />
		
		</cfcase>
		<cfcase value="items.get.deliver">
			
			<!--- app wants DL location of an item --->
			<cfset a_struct_get_data = GetItemDeliveryLink( securitycontext = a_struct_securitycontext,
												event = arguments.event ) />
												
			<cfif NOT a_struct_get_data.result>
				<cfset a_struct_return = a_struct_get_data />
			<cfelse>
			
				<!--- needs to be converted first ... return special location --->
				<cfset a_struct_return.location = a_struct_get_data.deliver_info.location />
				<cfset a_struct_return.contenttype = a_struct_get_data.deliver_info.contenttype />
				<cfset a_struct_return.contentlength = a_struct_get_data.deliver_info.contentlength />
				
				<!--- start playing now? --->
				<cfif ListFindNoCase( event.getarg( 'options'), 'FORWARDTOPLAYURL' ) GT 0>
					<cflocation addtoken="false" url="#a_struct_get_data.deliver_info.location#">
				</cfif>
				
				<cfset application.udf.SetReturnStructSuccessCode ( a_struct_return ) />
			
			</cfif>
		
		</cfcase>
		<cfcase value="items.checkhashvalues">
			
			<!--- check if the submitted items already exist or not --->
			<cfset a_struct_get_data = oAPI.CheckSubmittedHashData( userkey = a_str_userkey,
										filename = event.getArg( 'filedata' )) />
											
			<cfset a_struct_return = a_struct_get_data />
		
		</cfcase>
		<cfcase value="items.queue">
		
			<!--- processing queue --->
		
		</cfcase>
		<cfcase value="item.log.playstatus">		
			<!--- log the play status ... entrykey + seconds --->
			
			<cfset getProperty( 'beanFactory' ).getBean( 'LogComponent' ).LogMediaItemPlayPing( securitycontext = a_struct_securitycontext,
						secondsplayed = Val(Int( Val(event.getArg( 'seconds' )))),
						mediaitemkey = event.getArg( 'entrykey' ) ) />
						
						
			<!--- simply return true --->
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
			
		</cfcase>
		<cfcase value="sync.query">
		
			<!--- query informations --->
		
		</cfcase>
		<cfcase value="user.create">
			
			<!--- create a new user --->
		
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).CreateUser(
					username = event.getArg( '_username' ),
					password = event.getArg( '_password' ),
					email = event.getArg( '_email' ),
					firstname = event.getArg( '_firstname'),
					surname = event.getArg( '_surname' ),
					city = event.getArg( '_city' ),
					zipcode = event.getArg( '_zipcode' ),
					countryisocode = event.getArg( '_countryisocode' ),
					lang_id = event.getArg( '_lang_id' ),
					source = a_str_appkey ) />
					
			<!--- return the result --->
			<cfset a_struct_return = a_struct_get_data />
			
			<cfif NOT a_struct_return.result>
				<cfmail from="support@tunesBag.com" to="support@tunesBag.com" subject="Creating an user via API failed" type="html">
					<cfdump var="#a_struct_return#" label="result" />
					<cfdump var="#event.getargs()#" label="arguments">
					<cfdump var="#cgi#" label="CGI scope">
				</cfmail>
			</cfif>
			
		</cfcase>
		
		<cfcase value="user.info">
			
			<!--- return info about an user --->
			
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserData( userkey = a_str_userkey ).a_struct_item />
			
			<cfset a_struct_return.entrykey = a_struct_get_data.getEntrykey() />
			<cfset a_struct_return.firstname = a_struct_get_data.getFirstName() />
			<cfset a_struct_return.surname = a_struct_get_data.getSurname() />
			<cfset a_struct_return.sex = a_struct_get_data.getSex() />		
			<cfset a_struct_return.city = a_struct_get_data.getCity() />
			<cfset a_struct_return.countryisocode = a_struct_get_data.getcountryisocode() />
			<cfset a_struct_return.lang_id = a_struct_get_data.getlang_id() />
			<cfset a_struct_return.online = a_struct_get_data.getonline() />
			<cfset a_struct_return.libraryitemscount = a_struct_get_data.getlibraryitemscount() />		
			<cfset a_struct_return.homepage = a_struct_get_data.gethomepage() />
			<cfset a_struct_return.about_me = a_struct_get_data.getabout_me() />
			<cfset a_struct_return.photoindex = a_struct_get_data.getPhotoIndex() />
			<cfset a_struct_return.status = a_struct_get_data.getStatus() />
			
			<!--- return the default librarykey --->
			<cfset a_struct_return.librarykey = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetDefautLibraryEntrykey( userkey = a_str_userkey ) />
			
			<!--- load quota --->
			<cfset a_struct_quota = getProperty( 'beanFactory' ).getBean( 'StorageComponent' ).GetQuotaDataOfUser( userkey = a_str_userkey ) />
			
			<cfset a_struct_return.quota_currentsize = a_struct_quota.currentsize />
			<cfset a_struct_return.quota_maxsize = a_struct_quota.maxsize />
			
			<!--- permissions --->
			<cfset a_struct_return.permissions = a_struct_securitycontext.rights />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
			
		
		</cfcase>
		<cfcase value="user.checkaccess">
		
			<!--- simple login check, worked! --->
			
			<!--- check version of user --->
			<cfif a_str_appkey IS 'CC0D5A94-F8D9-60D4-4572A1A21EFEE8EE'>
				<!--- windows uploader ... check version --->
				
				<cfset var sVersion = event.getArg( '_programversion', 0 ) />
				<cfset var sUnifiedVersion = '' />
				<cfset var ii = 0 />
				<cfset var sPart = '' />
				
				<cfloop list="#sVersion#" delimiters="." index="sPart">
					<cfset sUnifiedVersion = sUnifiedVersion & NumberFormat( sPart, '00' ) />
				</cfloop>
				
				<cfset var iUnifiedVersion = Val( sUnifiedVersion ) />
				
				<!--- <cfmail from="hansjoerg@tunesBAg.com" to="hansjoerg@tunesBag.com" subject="add" type="html">
				<cfdump var="#iUnifiedVersion#">
				<cfdump var="#event.getargs()#">
				</cfmail> --->
				
				<!--- version is too old, remind user of updating ... --->
				<cfif iUnifiedVersion LT getAppManager().getPropertyManager().getProperty('I_MIN_VERSION_UPLOADER_WIN32') >
					<cfset application.udf.SetReturnStructErrorCode( a_struct_return, 1300, 'Please update your installed version' ) />
					<cfset event.setArg( 'a_struct_return', a_struct_return ) />
					
					<cfreturn />
				</cfif>
				
			</cfif>
			
			<cfset a_struct_return.userkey = a_struct_securitycontext.entrykey />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
		
		</cfcase>
		<cfcase value="user.feed">
			
			<cfset a_str_content = event.getArg( 'feedusername' ) />
			
			<cfif Len( a_str_content ) IS 0>
				<cfset a_str_content = a_struct_securitycontext.username />
			</cfif>
		
			<!--- user feed --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getUserRSSFeed( username = a_str_content,
											maxagedays = Val( event.getArg( 'maxagedays' ) ),
											sincedate = trim( event.getArg( 'sincedate' )),
											options = event.getArg( 'options' ),
											filter_actions = event.getArg( 'actions' ) ) />
			
			<cfif a_struct_get_data.result>
				
				<cfset a_struct_return.items = a_struct_get_data.q_select_log_items />			
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
				
			<cfelse>
				<cfset application.udf.SetReturnStructErrorCode( a_struct_return, 1002,  'Item not found or access forbidden' ) />
			</cfif>		
		
		</cfcase>
		<cfcase value="user.friends">
			
			<!--- return info about friends --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetFriendsList( securitycontext = a_struct_securitycontext,
												realusers_only = true ) />
												
			<cfif a_struct_get_data.result>
				
				<cfset a_struct_return.items = a_struct_get_data.q_select_friends />			
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />	
				
			<cfelse>
				<cfset application.udf.SetReturnStructErrorCode( a_struct_return, 1002,  'Item not found or access forbidden' ) />
			</cfif>													
		
		</cfcase>
		<cfcase value="sets.get">
		
			<!--- get the item sets (e.g. playlists) --->
						
			<cfif ListFindNoCase( event.getArg( 'options', ''),  'ownonly' ) GT 0>
				<cfset a_struct_filter.ownonly = true />
			</cfif>			
			
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
										librarykeys = '',
										calculateitems = false,
										filter = a_struct_filter,
										type = 'playlists' ) />
										
			<cfset a_struct_return.items = a_struct_get_data.q_select_items />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
		
		</cfcase>
		<cfcase value="sets.search">
			
			<!--- search for sets --->
			<cfset a_str_data = trim( event.getArg( 'search' )) />
			
			<cfif Len( a_str_data ) IS 0>
				<cfreturn />
			</cfif>
			
			<cfset a_struct_get_data_2 = getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).SearchForArtists( artist = a_str_data, searchmode = 1 ) />

			<!--- search for tracks --->
			<cfset a_struct_get_data_3 = getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).SearchForTracks( name = a_str_data ) />

			<!--- perform the search operation --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).SearchForPlaylists( securitycontext = a_struct_securitycontext,
					artist_ids = ValueList( a_struct_get_data_2.q_select_search_artists.id ),
					track_ids = ValueList( a_struct_get_data_3.q_select_search_tracks.id ),
					search = a_str_data ) />
					
			<cfif a_struct_get_data.result>
				<cfset a_struct_return.items = a_struct_get_data.q_select_search_plists />
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			</cfif>
		
		</cfcase>
		<cfcase value="sets.get.allaccessible">
		
			<!--- get the item sets (e.g. playlists) --->
			
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).GetAllPlayablePlaylistForUser(securitycontext = a_struct_securitycontext ) />
										
			<cfset a_struct_return.items = a_struct_get_data.q_select_all_accessable_playlists_for_user />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
		
		</cfcase>
		<cfcase value="sets.set.getitems">
			
			<!--- get items of set --->
			<!--- use default way --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).ReturnPlaylistItems( securitycontext = a_struct_securitycontext,
										playlistkey = event.getArg( 'setkey' ),
										options = 'logaccess',
										preview = event.getArg( 'preview', false ) ) />
			
			<!--- TODO: return permissions --->
					
			<!--- OK? --->						
			<cfif a_struct_get_data.result>
			
				<!--- plist information --->
				<cfif ListFindNoCase( event.getArg( 'options' ), 'actionScriptFix' ) GT 0>
					
					<!--- actionscript does not accept the "set" keyword ... therefore we've to use a different key --->
					<cfset a_struct_return.plist = a_struct_get_data.plist_info.q_select_items />					
				<cfelse>
					<cfset a_struct_return.set = a_struct_get_data.plist_info.q_select_items />
				</cfif>

				<cfset a_struct_return.permissions = a_struct_get_data.STLICENCEPERMISSIONs />
				
				<!--- only own items (win up/downloader) --->
				<cfif ListFindNoCase( event.getArg( 'options' ), 'ownitemsonly' ) GT 0>
					
					<cfquery name="a_struct_get_data.q_select_items" dbtype="query">
					SELECT
						*
					FROM
						a_struct_get_data.q_select_items
					WHERE
						userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.entrykey#">
					;
					</cfquery>
				
				</cfif>
				
				<cfloop query="a_struct_get_data.q_select_items">
					
					<cfquery name="qSelectMBTrackIds" datasource="mytunesbutleruserdata">
					SELECT
						mb_trackid
					FROM
						mediaitems
					WHERE
						mediaitems.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_get_data.plist_info.q_select_items.items#" list="true">)
					;
					</cfquery>	
					<cfset sData = ValueList( qSelectMBTrackIds.mb_trackid ) />
					
					<cfif ListFindNoCase( event.getArg( 'options' ), 'actionScriptFix' ) GT 0>
						<cfset QuerySetCell( a_struct_return.plist, 'mb_trackidlist', sData, 1 ) />
					<cfelse>
						<cfset QuerySetCell( a_struct_return.set, 'mb_trackidlist', sData, 1 ) />					
					</cfif>			
				
				</cfloop>
				
				<!--- return items list? --->			
				<cfif ListFindNoCase( event.getArg( 'options' ), 'simplelist' ) IS 0>
					<cfset a_struct_return.items = a_struct_get_data.q_select_items />
				</cfif>
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			
			</cfif>
								
		</cfcase>
		<cfcase value="set.additems">
			
			<!--- clear playlist first? --->
			<cfif ListFindNoCase( event.getArg( 'options' ), 'clearplaylist' ) GT 0>
				
				<!--- yes, call clearing ... --->
				<cfset getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).ClearPlaylistItems(securitycontext = a_struct_securitycontext,
						playlistkey = event.getArg( 'setkey' )) />
				
			</cfif>
					
			<!--- add items to a set --->
			<cfloop list="#event.getArg( 'itemkeys' )#" delimiters="," index="a_str_content">

				<cfset getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).AddItemToPlaylist(securitycontext = a_struct_securitycontext,
												librarykey = '',
												mediaitemkey = a_str_content,
												playlistkey = event.getArg( 'setkey' )) />
			
			</cfloop>
			
			<!--- return the whole playlist --->
			<cfset a_struct_filter.entrykeys = event.getArg( 'setkey' ) />
						
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
										filter = a_struct_filter,
										librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
										type = 'playlists') />
							
			<!--- check result --->			
			<cfif NOT a_struct_get_data.result OR a_struct_get_data.q_select_items.recordcount IS 0>
			
				<cfset a_struct_return = application.udf.SetReturnStructErrorCode( a_struct_return, 1002,  'Item not found or access forbidden' ) />
			
			<cfelse>
			
				<!--- TODO: FIX RETURN --->
				<cfset a_struct_return.set = a_struct_get_data.q_select_items />
				
				<cfset StructClear(a_struct_filter) />
				<cfset a_struct_filter.entrykeys = a_struct_get_data.q_select_items.items />
				<cfset a_struct_filter.info_playlistkey = event.getArg( 'setkey' ) />
				
				<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData( securitycontext = a_struct_securitycontext,
						librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
						type = 'mediaitems',
						filter = a_struct_filter) />
				
				<!--- return whole item list? --->			
				<cfif ListFindNoCase( event.getArg( 'options' ), 'simplelist' ) IS 0>
					<cfset a_struct_return.items = a_struct_get_data.q_select_items />
				</cfif>
				
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			
			</cfif>
		
		</cfcase>
				
		<cfcase value="set.save">
		
			<!--- create / edit a set --->
			<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).CreateEditPlaylist(securitycontext = a_struct_securitycontext,
												entrykey = event.getArg( 'setkey' ),
												librarykey = '',
												name = event.getArg( 'name' ),
												description = event.getArg( 'description' ),
												tags = event.getArg( 'tags' ),
												public = Val( event.getArg( 'public', 0)) ) />
												
		
		</cfcase>
		<cfcase value="set.delete">
		
			<!--- delete a set --->
		
		</cfcase>
		
		<cfcase value="set.prefill">
		
			<!--- pre-fill a set with data coming a little bit later (when being really uploaded) --->
			<cffile action="upload" nameconflict="makeunique" destination="#application.udf.GetTBTempDirectory()#" filefield="filedata">
			
			<cfset a_str_playlist_filename = cffile.ServerDirectory & '/' & cffile.ServerFile />
			
			<cffile action="read" charset="utf-8" file="#a_str_playlist_filename#" variable="a_str_content">
			
			<cfset a_struct_return = CheckSubmittedPlaylistData( securitycontext = a_struct_securitycontext,
											playlist_xml = a_str_content ) />
		
		</cfcase>
		<cfcase value="set.linktolibrary">
		
			<!--- link a set to the library --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).LinkPlaylisttoLibrary( securitycontext = a_struct_securitycontext,
												playlistkey = event.getArg( 'playlistkey' ),
												playlistuserkey = event.getArg( 'playlistuserkey' ) ) />
												
			<cfif a_struct_get_data.result>
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			</cfif>
			
		
		</cfcase>
		<cfcase value="social.share">
		
			<!--- share an item ... the URL has to be calculated --->
			
			
			<!--- call component --->
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).ShareItem( securitycontext = a_struct_securitycontext,
										itemtype = Val( event.getArg( 'itemtype' )),
										identifier = event.getArg( 'identifier' ),
										title = event.getArg( 'title' ),
										recipients = event.getArg( 'recipients' ),
										comment = event.getarg( 'comment' ),
										url = '') />
		
			<!--- <cfmail from="hansjoerg@tunesbag.com" to="hansjoerg@tunesbag.com" subject="share" type="html">
			<cfdump var="#event.getArgs()#">
			<cfdump var="#a_struct_get_data#">
			</cfmail> --->
		
			<!--- everything worked fine --->
			<cfif a_struct_get_data.result>
				<cfset a_struct_return.entrykey = a_struct_get_data.entrykey />
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			</cfif>
		
		</cfcase>
		
		<cfcase value="social.share.list">
		
			<!--- return shared items --->
			<cfset q_select_items = QueryNew( 'entrykey,type,direction,createdbyuserkey,createdbyusername,objecttitle,linked_objectkey,dt_created,comment,unread,recipients' ) />
			<cfset queryAddRow( q_select_items, 1 ) />
			
			<cfset querySetCell( q_select_items, 'entrykey', CreateUUID(), 1 ) />
			<cfset querySetCell( q_select_items, 'type', 1, 1 ) />
			<cfset querySetCell( q_select_items, 'direction', 1, 1 ) />
			<cfset querySetCell( q_select_items, 'createdbyuserkey', CreateUUID(), 1 ) />
			<cfset querySetCell( q_select_items, 'createdbyusername', 'user1', 1 ) />
			<cfset querySetCell( q_select_items, 'objecttitle', 'Red Alert - Basement Jaxx', 1 ) />
			<cfset querySetCell( q_select_items, 'linked_objectkey', CreateUUID(), 1 ) />
			<cfset querySetCell( q_select_items, 'dt_created', Now(), 1 ) />
			<cfset querySetCell( q_select_items, 'comment', 'This is really great!', 1 ) />
			<cfset querySetCell( q_select_items, 'unread', 1, 1 ) />
			<cfset querySetCell( q_select_items, 'recipients', 'mailto:username@domain.com,user:tunesBagusername1', 1 ) />
			
			<cfset a_struct_return.items = q_select_items />
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
		
		</cfcase>
		<cfcase value="social.artist.info">
			<!--- artist information --->
			<cfset a_str_content = event.getArg( 'artist' ) />
			
			<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GetArtistInformationEx( artist = a_str_content,
					datatypes = '' ) />
	
			<!--- fans --->
			<cfif StructKeyExists( a_struct_get_data, 'q_select_fans_of_artist' )>
				<cfset a_struct_return.fans = a_struct_get_data.q_select_fans_of_artist />
			</cfif>
			
			<!--- playlists --->
			<cfif StructKeyExists( a_struct_get_data, 'q_select_playlists_with_this_artist' )>
				<cfset a_struct_return.playlists = a_struct_get_data.q_select_playlists_with_this_artist />
			</cfif>
			
			<!--- events --->
			<cfif StructKeyExists( a_struct_get_data, 'q_select_artist_events' ) >
				<cfset a_struct_return.events = a_struct_get_data.q_select_artist_events />
			</cfif>
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
			
		
		</cfcase>
		<cfcase value="social.explore.newitems">
			
			<!--- return information about new items --->
			<cfset a_struct_get_data = application.beanFactory.getBean( 'ContentComponent' ).BuildExploreRecommendations( securitycontext = a_struct_securitycontext ) />
			
			<cfif StructKeyExists( a_struct_get_data, 'stplaylists' ) AND a_struct_get_data.stplaylists.result>
				<cfset a_struct_return.qNewUpdatedPlaylists = a_struct_get_data.stplaylists.q_select_search_plists />
			</cfif>
			
			<cfif StructKeyExists( a_struct_get_data, 'qnewtracksfriends_artists')>
				<cfset a_struct_return.qNewTracksArtists = a_struct_get_data.qnewtracksfriends_artists />
			</cfif>
			
			<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
		
		</cfcase>
		<cfcase value="content.comments.post">
			<!--- post a comment --->
		
		
		</cfcase>
		<cfcase value="content.artist.info">
			<!--- post a comment --->
		
		
		</cfcase>
		<cfcase value="content.album.info">
			<!--- post a comment --->
		
		
		</cfcase>
		<cfcase value="tools.convert">
		
			<!--- convert a file --->
		
		</cfcase>
		<cfcase value="messages.send">
			
			<!--- send a message --->
			<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'MessagesComponent' ).StoreMessage( securitycontext = a_struct_securitycontext,
						userkey_to = event.getArg( 'userkey_to' ),
						subject = event.getArg( 'subject' ),
						body = event.getArg( 'body' ),
						notify_recipient = true ) />
								
		</cfcase>
		<cfcase value="messages.get">
		
			<!--- read the mailbox of this user --->											
			<cfset a_struct_call = getProperty( 'beanFactory' ).getBean( 'MessagesComponent' ).GetMessagesOfUser( securitycontext = a_struct_securitycontext ) />
	
			<cfif a_struct_call.result>
				
				<cfset a_struct_return.data = a_struct_call.q_select_messages />
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
				
			</cfif>
		
		</cfcase>
		<cfcase value="misc.sendinvitation">
		
			<!--- send an invitation --->			
			<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).CreateInvitation( securitycontext = a_struct_securitycontext,
											recipient = event.getArg( 'email' ),
											customtext = event.getArg( 'customtext' )) />
			
		</cfcase>
		<cfcase value="misc.check.albumcovers">
		
			<!--- check the available album covers --->

			<cfset a_struct_call = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GetAvailableAlbumCovers( securitycontext = a_struct_securitycontext,
										librarykeys = event.getArg( 'librarykeys' ) ) />
						
			<cfif a_struct_call.result>
				
				<cfset a_struct_return.data = a_struct_call.content />
				<cfset application.udf.SetReturnStructSuccessCode( a_struct_return ) />
				
			</cfif>
			
		
		</cfcase>
		<cfcase value="rss.welcome">
			
			<!--- rss welcome request ... force XML --->
			<cfset event.setArg( 'format', 'rss' ) />
			
			<cfinclude template="rss/dsp_rss.welcome.cfm">
		
		</cfcase>
		<cfcase value="rss.genres">
		
			<!--- rss genres --->
			<cfset event.setArg( 'format', 'rss' ) />
			
			<cfinclude template="rss/dsp_rss.genres.cfm">
		
		</cfcase>
		<cfcase value="rss.browse">
		
			<!--- browse lib --->
			<cfset event.setArg( 'format', 'rss' ) />
			
			<cfinclude template="rss/dsp_rss.browse.cfm">
			
		</cfcase>
		<cfcase value="rss.playlist">
		
			<!--- display playlist as rss --->
			<cfset event.setArg( 'format', 'rss' ) />
			
			<cfinclude template="rss/dsp_rss.playlist.cfm">
		
		</cfcase>
		<!--- 
			opml (for squeezenetwork support)
		 --->
		<cfcase value="opml.welcome">
			<!--- OPML welcome request ... force XML --->
			<cfset event.setArg( 'format', 'XML_PREPARED' ) />
			
			<cfinclude template="opml/dsp_opml.welcome.cfm">
		</cfcase>
		<!--- 
			show tracks as playlist
		 --->
		<cfcase value="opml.playlist">
			<cfset event.setArg( 'format', 'XML_PREPARED' ) />
						
			<cfinclude template="opml/dsp_opml.playlist.cfm">
		</cfcase>
		
		<!--- browse --->
		<cfcase value="opml.browse">
			<cfset event.setArg( 'format', 'XML_PREPARED' ) />
			
			<cfset local.sType = event.getArg( 'type' ) />
			
			<cfswitch expression="#local.sType#">
				<cfcase value="artists">
				<cfinclude template="opml/dsp_browse_artists.cfm" />
				</cfcase>
				<cfcase value="albums">
					<cfinclude template="opml/dsp_browse_albums.cfm" />
				</cfcase>
			</cfswitch>
			
			
		</cfcase>
		
		<cfdefaultcase>
			<!--- unknown request --->
			<cfset a_struct_return = application.udf.SetReturnStructErrorCode( a_struct_return, 404,  '#event.getArg( 'request' )# Unknown request name. Please check the documentation or contact the support team') />

		</cfdefaultcase>
	</cfswitch>
	
	<cfset FinishLogAPIRequest( logkey = a_str_req_key, errorno = a_struct_return.error, runtime = (GetTickCount() - a_tc_start) ) />
	
	<cfset a_struct_return.requestkey = a_str_req_key />
	<cfset event.setArg( 'a_struct_return', a_struct_return ) />
	
</cffunction>

<cffunction access="private" name="FinishLogAPIRequest" output="false" returntype="void"
		hint="write error msg / runtime information to table">
	<cfargument name="logkey" type="string" required="true">
	<cfargument name="errorno" type="numeric" default="0" required="true">
	<cfargument name="runtime" type="numeric" default="0" required="true">
	
	 <cfset var local = StructNew() />
	
	<cfquery name="local.qUpdate" datasource="mytunesbutlerlogging">
	UPDATE
		apicalls_logging
	SET
		runtime = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.runtime#">,
		errorno = <cfqueryparam cfsqltype="cf_sql_integer" value="#Val( arguments.errorno )#">
	WHERE
		entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.logkey#">
	;
	</cfquery>

</cffunction>

<cffunction access="private" name="LogAPIRequest" output="false" returntype="void"
		hint="log the request (start)">
	<cfargument name="logkey" type="string" required="true">
	<cfargument name="requestname" type="string" required="true">
	<cfargument name="applicationkey" type="string" required="true">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="params" type="any"
		hint="incoming parameters">
	<cfargument name="ip" type="string" required="true"
		hint="current IP">

	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_item = a_transfer.new( 'api.calls' ) />
	<cfset var a_str_param = '' />
	<cfset var a_str_params = '' />
	
	<cfset a_item.setentrykey( arguments.logkey ) />
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setrequestname( arguments.requestname ) />
	<cfset a_item.setapplicationkey( arguments.applicationkey ) />
	<cfset a_item.setuserkey( arguments.userkey ) />
	<cfset a_item.setip( arguments.ip ) />
	
	<cfloop list="#StructKeyList( arguments.params )#" index="a_str_param">
		<cfset a_str_params = a_str_params & a_str_param & '=' & arguments.params[ a_str_param ] & Chr(13) & chr(10) />
	</cfloop>
	
	<cfset a_item.setparams( Trim( a_str_params ) ) />
	
	<cfset a_transfer.save( a_item ) />	
	
</cffunction>

<cffunction access="private" name="TestPing" output="false" returntype="struct">
	<cfargument name="event" type="MachII.framework.Event" required="true" />

	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />

	<cfreturn application.udf.SetReturnStructSuccessCode(a_struct_return) />
	
</cffunction>

<cffunction access="private" name="GetItems" output="false" returntype="struct"
		hint="return mediaitems">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_get_data = 0 />
	<cfset var a_struct_filter = StructNew() />
	<cfset var a_str_librarykeys = arguments.event.getArg( 'librarykeys' ) />
	
	<!--- filter for certain entrykeys --->
	<cfif Len( event.getArg( 'filter_entrykeys' ) ) GT 0>
		<cfset a_struct_filter.entrykeys = event.getArg( 'filter_entrykeys' ) />
	</cfif>
	
	<!--- only return certain fields? --->
	<cfif Len( event.getArg( 'fields' ) ) GT 0>
		<cfset a_struct_filter.fields = event.getArg( 'fields' ) />
	</cfif>	
	
	<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = arguments.securitycontext,
										librarykeys = a_str_librarykeys,
										lastkey = '',
										orderby = event.getArg( 'orderby' ),
										maxrows = Val( event.getArg( 'maxrows' ) ),
										filter = a_struct_filter,
										type = 'mediaitems',
										options = arguments.event.getArg( 'options' )) />
										
	<cfif a_struct_get_data.result>
		<cfreturn a_struct_get_data />
	</cfif>
										
	<cfreturn application.udf.SetReturnStructSuccessCode( a_struct_return ) />
	
</cffunction>

<cffunction access="private" name="GetItemDeliveryLink" output="false" returntype="struct"
		hint="return mediaitems">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	<cfargument name="securitycontext" type="struct" required="true" />

	<cfset var a_struct_return = 0 />
	<cfset var a_str_options = arguments.event.getArg( 'options' ) />
	<cfset var a_int_bitrate = val( arguments.event.getArg( 'targetbitrate' ) ) />
	<cfset var a_str_format = arguments.event.getArg( 'targetformat' ) />
	<cfset var a_str_op = 'READ' />
	<cfset var a_struct_dl_ticket = 0 />
	<!--- context: manually selected, plist, recommendation etc --->
	<cfset var iContext = Val( event.getArg( 'context', 0 )) />
	<!--- session in which the track is played --->
	<cfset var sSessionkey = event.getArg( 'sessionkey' ) />
	<cfset var local = {} />
	
	<cfset local.sOptions = '' />
	
	<!--- log played? --->
	<cfif ListFindNoCase( a_str_options, 'logplayed' ) GT 0>
		<cfset a_str_op = 'PLAY' />
	</cfif>
	
	<!--- iPhone app --->
	<cfif ListFindNoCase( application.const.S_APPKEY_IPHONE & ',' & application.const.S_APPKEY_SQUEEZENETWORK, event.getArg( 'appkey' )) GT 0>
		<cfset a_str_op = 'PLAY' />
		
		<!--- force delivery from streaming engines! do not distribute directly from S3 --->
		<cfset local.sOptions = 'forcestreamingdeliver' />
		
		<!--- 
		
			the squeezebox needs an (invalid) filesize in order to jump to the next track,
			it seems that otherweise a radio station is the default type
			
			we're file based, however ;-)
		
		 --->
		<cfif event.getArg( 'appkey' ) IS application.const.S_APPKEY_SQUEEZENETWORK>
			<cfset local.sOptions = ListAppend( local.sOptions, application.const.S_PLAY_PARAM_FORCE_RETURN_FILESIZE ) />
		</cfif>
		
	</cfif>
	
	<!--- <cfif arguments.securitycontext.username IS 'itunes'>
		<cfset a_int_bitrate = 128 />
	</cfif> --->
	
	<!--- get item, perform logging etc --->
	<cfset a_struct_return = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItem(applicationkey = event.getarg( 'appkey' ),
						securitycontext = arguments.securitycontext,
						entrykey = event.getArg( 'entrykey' ),
						type = 0,
						operation = a_str_op,
						targetbitrate = a_int_bitrate,
						targetformat = a_str_format,
						deliver_mode = true,
						context = iContext,
						sessionkey = sSessionkey,
						options = local.sOptions,
						preview = arguments.event.getArg( 'preview', false)) />
					
	<!--- all fine? --->	
	<cfif NOT a_struct_return.result>
		<cfreturn a_struct_return />
	</cfif>
	
	<!--- in case we already have a location, we're fine, otherwise create a download ticket --->
	<cfif a_struct_return.deliver_info.type IS 'file'>
		
		<cfset a_struct_dl_ticket = application.beanFactory.getBean( 'StorageComponent' ).CreateDownloadTicketForFile( a_struct_return.deliver_info ) />
	
		<!--- createDLTicket --->
		<cfset a_struct_return.deliver_info.location = a_struct_dl_ticket.url />
	
	</cfif>	
										
	<cfreturn a_struct_return />
	
</cffunction>


	<cffunction access="public" name="CheckSubmittedPlaylistData" returntype="struct" output="false"
			hint="analyze the provided playlist XML data and create the playlists if necessary">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="playlist_xml" type="string" required="true"
			hint="XML data of playlist">
			
		<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
		<cfset var a_cmp_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
		<cfset var a_struct_return_create_plist = 0 />
		<cfset var a_xml_obj = 0 />
		<cfset var a_playlists = 0 />
		<cfset var a_plist = 0 />
		<cfset var a_name = '' />
		<cfset var a_items = 0 />
		<cfset var ii = 0 />
		<cfset var jj = 0 />
		<cfset var a_struct_lookup_hash_values = 0 />
		<cfset var a_str_plist_entrykey = '' />
		<cfset var a_str_hashvalue = '' />
		<cfset var a_transfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var a_struct_map_get_item = StructNew() />
		<cfset var a_struct_db_item = 0 />
		<cfset var a_cmp_plists = application.beanFactory.getBean( 'PlaylistsComponent' ) />
		
		<cfif NOT IsXML( arguments.playlist_xml )>
			<cfreturn application.udf.SetReturnStructErrorCode( a_struct_return, 999 ) />
		</cfif>
		
		<cfset a_xml_obj = XMLParse( arguments.playlist_xml ) />

		<cfset a_playlists = a_xml_obj.playlists.playlist />

		<cfloop from="1" to="#ArrayLen( a_playlists.xmlchildren )#" index="ii">

			<cfset a_plist = a_playlists.xmlchildren[ ii ] />
			<cfset a_name = a_plist.name.xmltext />
			<cfset a_items = a_plist.items />

			<cfset a_struct_lookup_hash_values = StructNew() />
	
			<cfloop from="1" to="#ArrayLen( a_items.xmlchildren )#" index="jj">
				<cfset a_struct_lookup_hash_values[ a_items.xmlchildren[ jj].xmltext ] = 1 />
			</cfloop>
			
			<!--- create the playlist or get the entrykey of the existing one --->
			<cfset a_struct_return_create_plist = a_cmp_plists.CreateEditPlaylist(
				librarykey = '',
				securitycontext = arguments.securitycontext,
				name = a_name,
				description = '' ) />
				
			<cfset a_str_plist_entrykey = a_struct_return_create_plist.entrykey />
				
			<cfloop list="#StructKeyList( a_struct_lookup_hash_values )#" index="a_str_hashvalue">
			
				<cfset StructClear( a_struct_map_get_item ) />
				<cfset a_struct_map_get_item.userkey = arguments.securitycontext.entrykey />
				<cfset a_struct_map_get_item.playlistkey = a_str_plist_entrykey />
				<cfset a_struct_map_get_item.hashvalue = a_str_hashvalue />
				
				<cfset a_struct_db_item = a_transfer.readByPropertyMap( 'playlists.autoaddplist', a_struct_map_get_item) />
				
				<cfset a_struct_db_item.setUserkey( arguments.securitycontext.entrykey ) />
				<cfset a_struct_db_item.setplaylistkey( a_str_plist_entrykey ) />
				<cfset a_struct_db_item.sethashvalue( a_str_hashvalue ) />
				<cfset a_struct_db_item.setdt_created( Now() ) />
				
				<cfset a_transfer.save( a_struct_db_item ) />
												
			</cfloop>				
				
			<!--- store reference for these items so that the plist item can be created when the file is uploaded --->
			
		</cfloop>
			
		<cfreturn application.udf.SetReturnStructSuccessCode(a_struct_return) />
	</cffunction>



	<!--- enable dropbox sync agent --->
	<cffunction access="public" name="linkDropboxAccount" output="false" returntype="void"
			hint="prepare everything for linking a tb and a dp account">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset local.stOauth = getProperty( 'beanFactory' ).getBean( 'Dropbox' ).connectUserAccount( application.udf.GetCurrentSecurityContext() ) />
		
		<!--- success? --->	
		<cfif local.stOauth.result AND local.stOAuth.stoAuth.success>

			<!--- temporarely store the received token + secret --->
			<cfset session.stTempDPAuth = {
				token			= local.stoAuth.stoAuth.token,	
				token_secret	= local.stoAuth.stoAuth.token_secret
				} />
				
			<!--- relocate to auth url --->
			<cflocation addtoken="false" url="#local.stoAuth.stoAuth.authURL#" />
		
		</cfif>
		
		<cfset arguments.event.setArg( 'oAuth', local.stOAuth ) />		
		
	</cffunction>
	
	<!--- incoming feedback ... --->
	<cffunction access="public" name="handleDropboxAuthFeedback" output="false" returntype="void"
			hint="Incoming feedback from DP">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<!--- local temp auth info ... set in  --->
		<cfset local.stTempDPAuth = session.stTempDPAuth />
		
		<cfset local.stAccess = getProperty( 'beanFactory' ).getBean( 'Dropbox' ).handleDPAuthFeedback(
			stContext			= application.udf.GetCurrentSecurityContext(),
			sAuthToken 			= local.stTempDPAuth.token,
			sAuthTokenSecret	= local.stTempDPAuth.token_secret
			) />
			
			
		<cfset arguments.event.setArg( 'stAccess', local.stAccess ) />
		
	</cffunction>
	
	<cffunction access="public" name="performInitialScan" output="false" returntype="void"
			hint="Query for the initial scan">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset local.oDP = getProperty( 'beanFactory' ).getBean( 'Dropbox' ) />
		
		<!--- has the user selected a source folder? --->
		<cfif event.getArg( 'stored', false )>
			
			<cfset local.sSourceFolder = event.getArg( 'sourcefolder', '' ) />
			
			<!--- store the base sync directory --->
			<cfset getProperty( 'beanFactory' ).getBean( 'UserComponent' ).updateParamOfExternalService(
				stContext		= application.udf.GetCurrentSecurityContext(),
				sServiceName	= application.const.S_SERVICE_DROPBOX,
				sParam1			= local.sSourceFolder
				) />		
			
		</cfif>
					
		<cfset local.stAccessData = local.oDP.getAccessData( application.udf.GetCurrentSecurityContext() ) />
		<cfset local.oAccess = local.stAccessData.oItem />
		
		<!--- load account info --->
		<cfset local.stDPAccount = local.oDP.getAccountInfo( stContext = application.udf.GetCurrentSecurityContext() ) />
		
		<cfset local.stContent = local.oDP.performSync(
				stContext			= application.udf.GetCurrentSecurityContext(),
				bReturnDataFound	= true,
				bForceSync			= true
				) />
						
		<cfset event.setArg( 'stContent', local.stContent ) />
			
		<!--- <cfset event.setArg( 'stKnownData', getProperty( 'beanFactory' ).getBean( 'Dropbox' ).getKnownData( application.udf.GetCurrentSecurityContext() )) /> --->
	</cffunction>
	
</cfcomponent>