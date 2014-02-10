<!--- //

	Module:		Handle media items of user
	
// --->

<cfcomponent name="remoteservers" displayname="Remote server connections"output="false" extends="MachII.framework.Listener" hint="Handle media items">
	
<cfinclude template="/common/scripts.cfm">

<cfset variables.sSignatureSecret = application.udf.GetSettingsProperty( 'RemoteSignatureSecret', 'is9g9u9q+ßvvlwr' ) />
<cfset variables.sAllowedRemoteHosts = application.udf.GetSettingsProperty( 'RemoteAllowedHosts', '127.0.0.1,::1,streaming01.tunesbag.com,streaming02.tunesbag.com,streaming03.tunesbag.com' ) />

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="CheckValidRequestServerSource" output="false" returntype="void"
		hint="check if the request is coming from a valid server (IP)">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
			
	<cfset var sRemote = cgi.REMOTE_ADDR />
	<cfset var sSignature = event.getArg( 'signature' ) />	
	
	<!--- TODO: check against the list of allowed hosts --->
	<!--- <cfif ListFindNoCase( variables.sAllowedRemoteHosts, cgi.REMOTE_ADDR ) IS 0>
		
		<cflog application="false" file="tb_invalid_closed_api_request" log="Application" text="#cgi.REMOTE_ADDR#" type="warning" />
		
		<cfmail from="hansjoerg@tunesBag.com" to="hansjoerg@tunesBag.com" subject="remote closed api invalid request IP" type="text">
		Allowed: #variables.sAllowedRemoteHosts#
		Request IP: #cgi.REMOTE_ADDR#
		</cfmail>
		<cfabort>
	</cfif> --->
	
	<!--- only check the signature --->
	<cfif NOT CheckSignature( sSignature )>
		<cfabort>
	</cfif>

</cffunction>

<cffunction access="private" name="CheckSignature" output="false" returntype="boolean"
		hint="check the provided signature ... build the whole signature from scratch and compare">
	<cfargument name="signature" type="string" required="true" />
	
	<cfset var stData = form />		
	<cfset var sResult = '' />
	<cfset var sIndex = '' />
	<cfset var ii = 0 />
	<cfset var sKeys = ListSort( StructKeyList( stData ), 'textnocase') />
				
	<cfloop from="1" to="#ListLen( sKeys )#" index="ii">
			
		<cfset sIndex = ListGetAt( sKeys, ii ) />
		
		<cfif sIndex NEQ 'FIELDNAMES'>
			<cfset sResult = sResult & lcase( sIndex) & lcase( stData[ sIndex ] ) />
		</cfif>
		
	</cfloop>
	
	<cfset sResult = Hash( sResult & sSignatureSecret, 'sha1' ) />
	
	<cfreturn (arguments.signature IS sResult) />		

</cffunction>

<cffunction access="public" name="HandleIncomingPUIDDataCalculated" output="false" returntype="void" hint="receive calculated PUID">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_mediaitemkey = event.getArg( 'entrykey' ) />
	<cfset var a_puid = event.getArg( 'puid' ) />
	
	<cfif Len( a_mediaitemkey ) GT 0 AND Len( a_puid ) GT 0>
	
		<!--- ok, set data! --->
		<cfset getProperty( 'beanFactory' ).getBean( 'MusicBrainz' ).StoreCalculatedPUIDData( mediaitemkey = a_mediaitemkey, puid = a_puid ) />
		
	</cfif>

</cffunction>

<cffunction access="public" name="ReceiveServerPing" output="false" returntype="void" hint="receive ping from server">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_item = a_transfer.new( 'logging.serverstat' ) />

	<cfset a_item.sethostname( event.getArg( 'hostname' ) ) />	
	<cfset a_item.sethostip( event.getArg( 'hostip' ) ) />	
	<cfset a_item.setdt_created( Now() ) />	
	<cfset a_item.setserverload( Val( event.getArg( 'serverload' ) )) />	
	<cfset a_item.setffmpeg_processes( Val( event.getArg( 'ffmpeg_processes' )) ) />	
	<cfset a_item.setwaiting_incoming( Val( event.getArg( 'waiting_incoming' )) ) />	
	<cfset a_item.setwaiting_s3upload( Val( event.getArg( 'waiting_s3upload' )) ) />	
	<cfset a_item.setwaiting_converting( Val( event.getArg( 'waiting_converting' )) ) />	
	
	<!--- is this server handling streaming stuff? --->
	<cfif ListFindNoCase( event.getArg( 'hosttype' ), getAppManager().getPropertyManager().getProperty('I_CONST_SATELLITE_TYPE_STREAMING') ) GT 0>
		<cfset a_item.setisstreaming( 1 ) />
	<cfelse>
		<cfset a_item.setisstreaming( 0 ) />
	</cfif>
	
	<!--- can people upload to this server? --->
	<cfif ListFindNoCase( event.getArg( 'hosttype' ), getAppManager().getPropertyManager().getProperty('I_CONST_SATELLITE_TYPE_UPLOAD') ) GT 0>
		<cfset a_item.setisuploading( 1 ) />
	<cfelse>
		<cfset a_item.setisuploading( 0 ) />
	</cfif>
	
	<!--- www server --->
	<cfif ListFindNoCase( event.getArg( 'hosttype' ), getAppManager().getPropertyManager().getProperty('I_CONST_WEB_CONTENT_SERVER') ) GT 0>
		<cfset a_item.setiswebserver( 1 ) />
	<cfelse>
		<cfset a_item.setiswebserver( 0 ) />
	</cfif>
	
	<!--- country code --->
	<cfset a_item.setcountrycode( application.beanFactory.getBean( 'LicenceComponent' ).IPLookupCountry( cgi.REMOTE_ADDR ) ) />
	
	<cfset a_transfer.create( a_item ) />	
</cffunction>

<cffunction access="private" name="updateQueueStatus" output="false" returntype="void"
		hint="update the status of uploaded items on the master server">
	<cfargument name="sQueueData" type="string" hint="jsoned struct" />
	<cfargument name="hostip" type="string" required="true"
		hint="of of host" />
		
	<cfset var stData = DeSerializeJSON( arguments.sQueueData ) />
	<cfset var sIndex = '' />
	<cfset var stItem = 0 />
	<cfset var oTransfer = getProperty( 'beanFactory' ).getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var oItem = 0 />
	<cfset var qDelete = 0 />
	<cfset var local = {} />
	
	<cfif NOT IsStruct( stData )>
		<cfreturn />
	</cfif>
	
	<!--- delete old items --->
	<cfquery name="qDelete" datasource="mytunesbutleruserdata">
	DELETE FROM
		uploaded_items_status
	WHERE
		hostid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hostip#">
	;
	</cfquery>
	
	<cfloop list="#StructKeyList( stData )#" index="sIndex">
		
		<cfset stItem = stData[ sIndex ] />
		
		<cfquery name="local.qInsert" datasource="mytunesbutleruserdata">
		INSERT INTO
			uploaded_items_status
			(
			entrykey,
			dt_created,
			userkey,
			location,
			handled,
			librarykey,
			source,
			status,
			hostid			
			)
		VALUES
			(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#stItem.entrykey#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#stItem.dt_created#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#stItem.userkey#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left( stItem.location, 500)#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#stItem.handled#">,		
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#stItem.librarykey#">,	
			'',
			<cfqueryparam cfsqltype="cf_sql_integer" value="#stItem.status#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left( arguments.hostip, 100 )#">
			)
		;
		</cfquery>
		
		<!--- <cfset oItem = oTransfer.get( 'storage.uploaded_items_status', stItem.entrykey ) />
		
		<cfset oItem.setdt_created( stItem.dt_created ) />
		<cfset oItem.setEntrykey( stItem.entrykey ) />
		<cfset oItem.setLocation( stItem.location ) />
		<cfset oItem.setUserkey( stItem.userkey ) />
		<cfset oItem.setStatus( stItem.status ) />
		<cfset oItem.setLibraryKey( stItem.librarykey ) />
		<cfset oItem.setHandled( stItem.handled ) />
		<cfset oItem.setHostID( arguments.hostip ) />
		
		<cfset oTransfer.save( oItem ) /> --->
	
	</cfloop>

</cffunction>

<cffunction access="public" name="HandleIncomingSlaveStatusInformation" output="false" returntype="void" hint="handle various incoming information">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var sType = event.getArg( 'type' ) />
	<cfset var stResult = application.udf.GenerateReturnStruct() />
	<cfset var stSecurityContext = {} />
	<cfset var stStoreInfo = {} />
	<cfset var stMetaInfo = {} />
	<!---  --->
	
	<!--- <cflog application="false" file="tb_slave_comm" log="Application" type="information" text="#SerializeJSON( event.getargs() )#"> --->
	
	<cfswitch expression="#sType#">
		
		<cfcase value="slave.queuestatus">
			
			<!--- slave is reporting the queue status --->
			<cfset updateQueueStatus( hostip = event.getArg( 'hostip' ), sQueueData = event.getArg( 'sQueue' )) />
			
			<!--- return true --->
			<cfset application.udf.SetReturnStructSuccessCode( stResult ) />
		</cfcase>
	
		<cfcase value="item.add.checkrequest">
			
			<!--- a file has been received ... check if the request is valid, this hashvalue already exists in database etc ...--->
			<cfset stResult = getProperty( 'beanFactory' ).getBean( 'RemoteService' ).PerformRemoteIncomingRequestCheck( userkey = event.getArg( 'userkey' ),
														runkey = event.getArg( 'runkey' ),
														authkey = event.getArg( 'authkey' ),
														librarykey = event.getArg( 'librarykey' ),
														ip = event.getArg( 'ip' ),
														originalFileHashValue = event.getArg( 'originalFileHashValue' ) ) /> 
														
		</cfcase>
		<cfcase value="item.add.requeststoragepath">
			
			<!--- requesting the upload path (e.g. S3 upload URL) --->			
			<cfset stResult.s3 = createUUID() />
			
			<cfset stResult = getProperty( 'beanFactory' ).getBean( 'RemoteService' ).ReturnStorageInformationToClient( userkey = event.getArg( 'userkey' ),
														hashvalue = event.getArg( 'hashvalue' )) />
			
		
		</cfcase>
		<cfcase value="item.add.success">
		
			<!--- item has been converted + stored on s3 successfully ... --->
			<cfset stSecurityContext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = event.getArg( 'userkey' ) ) />
			
			<cfwddx input="#event.getArg( 'ORIGINALID3TAGS' )#" output="stMetaInfo" action="wddx2cfml" />
			
			<cfset stStoreInfo = application.beanFactory.getBean( 'MediaItemsComponent' ).addMediaItemMetaInfoToLibrary(
					securitycontext = stSecurityContext,
					librarykey = event.getArg( 'librarykey' ),
					metainformation = stMetaInfo,
					originalhashvalue = event.getArg( 'originalhashvalue' ),
					hashvalue = event.getArg( 'hashvalue' ),
					filename = filename = event.getArg( 'filename' ),
					source = event.getArg( 'source' )
					) />
		
			<cfset stResult = stStoreInfo />
							
			<cfif stStoreInfo.result>
			
				<!--- insert into storage counter and storage info --->
				<cfset getProperty( 'beanFactory' ).getBean( 'storageComponent' ).saveStorageMetaInfo( userkey = stSecurityContext.entrykey,
							mediaitemkey = stStoreInfo.entrykey,
							hashvalue = event.getArg( 'hashvalue' )) />
				
				<!--- automatically add to a playlist? --->
				<cfquery name="qSelectPlist" datasource="mytunesbutleruserdata">
				SELECT
					plistname
				FROM
					uploaded_autoadd_plist
				WHERE
					userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'userkey' )#">
					AND
					uploadkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getARg( 'uploadrunkey' )#">
				;
				</cfquery>
				

				
				<cfif Len( qSelectPlist.plistname ) GT 0>
					
					<!--- automatically add to a plist? --->		
					<!--- TODO: Fix routine, does not work --->				
					<cfset application.beanFactory.getBean( 'PlaylistsComponent' ).CheckAutoAddItemToPlaylistByName( securitycontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( event.getArg( 'userkey' ) ),
							librarykey = event.getArg( 'librarykey' ),
							mediaitemkey = stStoreInfo.entrykey,
							playlistname = qSelectPlist.plistname ) />
				
				
				<cfelseif Len( event.getARg( 'AUTOADDTOPLAYLIST' )) GT 0>
				
					<!--- next try ... has the AUTOADDTOPLAYLIST arg been provided? --->				
					<cfset application.beanFactory.getBean( 'PlaylistsComponent' ).CheckAutoAddItemToPlaylistByName( securitycontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( event.getArg( 'userkey' ) ),
							librarykey = event.getArg( 'librarykey' ),
							mediaitemkey = stStoreInfo.entrykey,
							playlistname = event.getARg( 'AUTOADDTOPLAYLIST' ) ) />
				</cfif>
			
			</cfif>
			
		</cfcase>
		<cfcase value="remoteanalysis.next">
			
			<!--- slave is requesting the next remote analysis job --->
			<cfset local.stJobs = getProperty( 'beanFactory' ).getBean( 'Dropbox' ).getNextItemsToAnalyze() />
			
			<cfif local.stJobs.result>
				<cfset stResult.aJobs = local.stJobs.aJobs />
				<cfset application.udf.SetReturnStructSuccessCode( stResult ) />
			</cfif>
		
		</cfcase>
		<cfcase value="remoteanalysis.result">
			
			<!--- incoming result of an analysis of a remote file --->
			<cfset local.bParseResult = event.getArg( 'result', false ) />
			<cfset local.iDropboxID = Val( event.getArg( 'iDropBox_ID' )) />
			<cfset local.jMeta = event.getArg( 'jMeta' ) />
			
			<cfif local.bParseResult>
			
				<!--- get back struct --->
				<cfset local.stMeta = DeSerializeJSON( local.jMeta ) />
				
				<!--- get job details --->
				<cfset local.qDropboxItem = getProperty( 'beanFactory' ).getBean( 'Dropbox' ).getDropboxData( local.iDropboxID ) />
				
				<cfif local.qDropboxItem.recordcount IS 1>
				
					<!--- add item to library --->
					<cfset local.stSecContext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( local.qDropboxItem.userkey ) />
			
					<!--- force the right storage type (dropbox in this case) --->
					<cfset local.stMeta.storagetype = application.const.I_STORAGE_TYPE_DROPBOX />
					<cfset local.stMeta.source = 'dp' />
					
					<cfset local.stInsert = application.beanFactory.getBean( 'MediaItemsComponent' ).addMediaItemMetaInfoToLibrary(
								securitycontext 	= local.stSecContext,
								metainformation		= local.stMeta,
								hashvalue			= local.qDropboxItem.pathhash							
								) />
				
				</cfif>
				
			</cfif>
			
			<!--- update the dropbox item status --->
			<cfquery name="local.qUpdate" datasource="mytunesbutlerlogging">
			UPDATE	dropboxdata
			SET		status = 
					
					<cfif local.bParseResult>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_ANALYZED#" />
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_FAILED_READING#" />
					</cfif>
					
					<!--- update the meta hash value of this item --->
					<cfif local.bParseResult AND StructKeyExists( local, 'stInsert' ) AND local.stInsert.result>
						,metahashvalue 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.stInsert.sMetahashValue#" />
						,mediaitemkey 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.stInsert.entrykey#" />
					</cfif>
			
			WHERE	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.iDropboxID#" />
			</cfquery> 
			
			<cfset application.udf.SetReturnStructSuccessCode( stResult ) />
		
		</cfcase>
		<cfcase value="puid.generate.request">
			
			<!--- slave is requesting a puid generation job --->
			
			<cfquery name="local.q_select_next_item" datasource="mytunesbutleruserdata">
			SELECT
				entrykey,
				hashvalue
			FROM
				mediaitems
			WHERE
				puid = ''
				AND
				puid_generated = 0
				AND
				dt_created < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'n', -5, Now() )#">
			ORDER BY
				rand()
			LIMIT
				1
			;
			</cfquery>
			
			<cfif local.q_select_next_item.recordcount GT 0>
			
				<!--- set as handled --->
				<cfquery name="q_update_item" datasource="mytunesbutleruserdata">
				UPDATE
					mediaitems
				SET
					puid_generated = 1
				WHERE
					entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.q_select_next_item.entrykey#">
				;
				</cfquery>
				
				<cfset a_link = getproperty( 'beanFactory' ).getBean( 'StorageComponent' ).GetHTTPS3LinkToObject( local.q_select_next_item.hashvalue ) />
	
				<cfset stResult.sHashvalue = local.q_select_next_item.hashvalue />
				<cfset stResult.sEntrykey = local.q_select_next_item.entrykey />
				<cfset stResult.sLink = a_link />
				
				<cfset application.udf.SetReturnStructSuccessCode( stResult ) />
	
			</cfif>
			
			
		
		</cfcase>
		<cfcase value="puid.submit.result">
			
			<cfif Len( event.getArg( 'sPUID' ) ) GT 0 AND Len( event.getArg( 'sMediaitemkey' ) ) GT 0>
			
				<!--- a file has been analyed, store the result --->
				<cfquery name="local.q_update_item" datasource="mytunesbutleruserdata">
				UPDATE
					mediaitems
				SET
					puid_generated = 1,
					puid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'sPUID' )#">
				WHERE
					entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#event.getArg( 'sMediaitemkey' )#">
				;
				</cfquery>
				
				<cfset stResult.sHint = 'Updated ' & event.getArg( 'sMediaitemkey' ) & ' with PUID ' & event.getArg( 'sPUID' ) />
				<cfset application.udf.SetReturnStructSuccessCode( stResult ) />
			</cfif>			
		
		</cfcase>
		<cfcase value="file.analyzed">
			
			<!--- analyzed --->
		
		
		</cfcase>
		<cfcase value="file.startconvert">
			
			<!--- need to convert ... converting is starting --->
		
		</cfcase>
		<cfcase value="file.converted">
			
			<!--- convert done --->
		
		
		</cfcase>
	</cfswitch>
	
	<!--- log request & result --->
	
	<cfset event.setArg( 'stResult', stResult ) />
	
</cffunction>

<cffunction access="public" name="HandleAPISyncRequest" output="false" returntype="void" hint="say hello the the quering webservice">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_request = event.getArg( 'request', '' ) />
	<cfset var a_str_securitytoken = event.getArg( 'securitytoken', '' ) />
	<!--- struct for action called --->
	<cfset var a_struct_action = StructNew() />
	<cfset var a_struct_api_request = application.udf.GenerateReturnStruct() />
	<cfset var a_str_content = '' />
	
	<!--- username / pwd --->
	<cfset var a_str_username = event.getArg( 'authusername' ) />
	<cfset var a_str_password = event.getArg( 'authpassword' ) />
	
	<!--- the entrykey of the user --->
	<cfset var a_str_userkey = '' />
	<cfset var a_struct_securitycontext = '' />
	
	<!--- quota check --->
	<cfset var a_struct_quota = 0 />
	
	<!--- perform security check ... --->
	<cfset var a_struct_securitycheck = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).CheckLoginDataWebService( username = a_str_username,
				password_md5 = a_str_password ) />
				
				
	<!--- the response of TUNESBAG concerning the status of the file ... --->
	<cfset var a_str_hash_check_server_result = event.getArg( 'CHECKHASHRESPONSE', '404' ) />	
	<cfset var a_str_upload_audio_filename = '' />
	<cfset var a_str_meta_info_filename = '' />
	<cfset var a_str_playlist_filename = '' />
				
	<!--- component --->
	<cfset var a_cmp_remote = getProperty( 'beanFactory' ).getBean( 'RemoteService' ) />
				
	<!--- error --->
	<cfif NOT a_struct_securitycheck.result>
		<cfset event.setArg( 'a_struct_api_request', a_struct_securitycheck ) />
		<cfreturn />
	</cfif>
		
	<!--- get userkey --->
	<cfset a_str_userkey = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetEntrykeyByUsername( a_str_username ) />
	<cfset a_struct_securitycontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( a_str_userkey ) />
	
	<cfswitch expression="#a_str_request#">
	
		
		<cfcase value="transmitplaylists">
		
			<!--- plist has been transmitted --->
			
			<cffile action="upload" nameconflict="makeunique" destination="#application.udf.GetTBTempDirectory()#" filefield="playlistfile">
			
			<cfset a_str_playlist_filename = cffile.ServerDirectory & '/' & cffile.ServerFile />
			
			<cffile action="read" charset="utf-8" file="#a_str_playlist_filename#" variable="a_str_content">
			
			<cfset a_struct_action = a_cmp_remote.CheckSubmittedPlaylistData( securitycontext = a_struct_securitycontext,
											playlist_xml = a_str_content ) />
				
		
		</cfcase>
		
	
	</cfswitch>
	
	<cfset event.setArg( 'a_struct_api_request', a_struct_api_request ) />

</cffunction>

<!--- 
<!--- transmit local database for analyzing --->
<cffunction access="remote" name="TransmitLocalMusicLibrary" returntype="string" output="false" hint="Webservice for ">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="data" type="binary" required="true">
	<cfargument name="type" type="string" required="true"
		hint="type of library, supported wmp (windows media player), winamp or itunes">
	<cfargument name="zipped" type="boolean" default="false">
	
	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
	<cfset var a_str_filename = '/tmp/lib_' & CreateUUID() & '.incoming' />
	<cfset var a_struct_xml_uniform = 0 />
	<cfset var a_cmp = CreateObject('component', 'james.model.content.libraryparser') />
	<cfset var a_parse = 0 />
	
	<cffile action="write" file="#a_str_filename#" output="#arguments.data#" charset="utf-8">
	
	<!--- todo: uploads are zipped --->
	
	<!--- todo: check if it is the very same file again that has been uploaded already --->
	
	<!--- 	<cfzip action="read" charset="UTF-16" variable="q_select_archive" file=""> --->
	
	<cfswitch expression="#arguments.type#">
	
		<cfcase value="itunes">
			
			<cfset a_parse = a_cmp.ParseLibrary(filename = a_str_filename, format = 'itunes') />
			
			<cfset a_struct_xml_uniform = a_cmp.CreateDefaultLibraryFormatXML(data = a_parse.data) />
			
			<!--- error occured ... --->
			<cfif NOT a_struct_xml_uniform.result>
				<cfreturn application.udf.GenerateWSXML(a_struct_xml_uniform) />
			</cfif>

			<cfset a_struct_return.uniformxml = a_struct_xml_uniform.xml />			
		</cfcase>
	</cfswitch>

	<cfreturn application.udf.GenerateWSXML(application.udf.SetReturnStructSuccessCode(a_struct_return)) />
</cffunction>


<cffunction access="remote" name="TransmitPlaylistsInformation" output="false" returntype="string" hint="Transmit XML with information of playlists and hashids of included songs">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="data" type="binary" required="true">
	<cfargument name="zipped" type="boolean" default="false" required="true">
	
	<cfset var a_struct_return = application.udf.GenerateReturnStruct() />
	<cfset var a_str_userkey = CreateObject('component', 'james.model.user.users').GetEntrykeyByUsername(arguments.username) />
	<cfset var a_cmp_parse = CreateObject('component', 'james.model.content.libraryparser') />

	<!--- incoming filename ... --->
	<cfset var a_str_filename = '/tmp/lib_playlist_' & CreateUUID() & '.incoming.xml' />
	<cfset var a_struct_result_parse = 0 />
	
	<cffile action="write" file="#a_str_filename#" output="#arguments.data#" charset="utf-8">
	
	
	<cfreturn application.udf.GenerateWSXML(application.udf.SetReturnStructSuccessCode(a_struct_return)) />
	
</cffunction> --->

</cfcomponent>