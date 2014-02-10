<!--- 

	base class for external sources

 --->

<cfcomponent output="false">
	
	<cffunction access="public" name="init" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="setSourceState" output="false" returntype="void"
			hint="Update the source state (do not sync several times at the same time)">
		<cfargument name="stContext" type="struct" required="true"
			hint="Owner context" />
		<cfargument name="sServiceName" type="string" required="true" />
		<!--- 
			todo: source id
		 --->
		<cfargument name="iStatus" type="numeric" required="true"
		 	hint="A valid status, see consts for more details" />
		 <cfargument name="bUpdateLastUpdate" type="boolean" required="false" default="false"
		 	hint="Update the lastupdate property as well" />
		 
		<cfquery name="local.qStatusUpdate" datasource="mytunesbutlercontent">
		UPDATE	sourcessyncstate
		SET		status 		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iStatus#" />
				
				<cfif arguments.bUpdateLastUpdate>
					,dt_lastupdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#" />
					/* update sync counter */
					,times = (times + 1)
				</cfif>
		
		WHERE	user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
				AND
				servicename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sServiceName#" />
				;
		</cfquery>
		
		<!--- update access data to non-working? --->
		<cfif arguments.iStatus IS application.const.I_SYNC_SOURCE_STATUS_ERROR>
			
			<cfquery name="local.qDisableService" datasource="mytunesbutleruserdata">
			UPDATE	3rdparty_ids
			SET		isworking 	= 0
			WHERE	userkey		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stContext.entrykey#" />
					AND
					servicename	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sServiceName#" />
					;
			</cfquery>
			
			<!--- disable tracks --->
			
			
			<!--- remove from dropbox list --->
		
		</cfif>
		
		<!--- update number of items --->
		<!--- <cfquery name="local.qUpdate" datasource="mytunesbutlercontent">
		UPDATE	sourcessyncstate
		SET		itemscount	= (
			SELECT COUNT(c.)
			)
		WHERE	user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
				AND
				servicename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sServiceName#" />
				;
		</cfquery> --->
		
	</cffunction>
	
	<!--- <cffunction access="public" name="analyzeRemoteFile" output="false" returntype="struct"
			hint="Generic routine for analyzing remote files">
		<cfargument name="stContext" type="struct" required="true"
			hint="User context" />
		<cfargument name="iAudio_Format" type="numeric" required="true"
			hint="The audio format of the source" />
		<cfargument name="iStoreType_ID" type="numeric" required="true"
			hint="Which service?" />
		<cfargument name="sHTTPLocation" type="string" required="false" default=""
			hint="Information about the location (http?)" />
		<cfargument name="iHTTPRange" type="numeric" required="false" default="0"
			hint="Only get a certain piece of the file for the analysis" />
		<cfargument name="bAlternativeTry" type="boolean" required="false" default="false"
			hint="Is this already an alternative try using more data?" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfif Len( arguments.sHTTPLocation ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'Invalid HTTP Path' ) />
		</cfif>
		
		<cflog application="false" file="tb_parse_remote_file" text="#arguments.stContext.userid# Parsing storage type: #iStoreType_ID# alt try: #arguments.bAlternativeTry# format: #arguments.iAudio_Format# src: #arguments.shttplocation#" />
		
		<cfset local.sTempFile = getTempDirectory() & 'ext_analysis_' & CreateUUID() & '.mp3' />
	
		<cftry>
			
			<cfhttp url="#arguments.sHTTPLocation#" charset="utf-8" method="get" result="local.stHTTP">
				
				<!--- read from the beginning --->
				<cfif Val( arguments.iHTTPRange ) GT 0>
					<cfhttpparam type="Header" name="Range" value="bytes=0-#arguments.iHTTPRange#" />
				</cfif>
				
			</cfhttp>
		
			<cfcatch type="any">
				
				<cflog application="false" file="tb_parse_remote_file" log="Application" type="information" text="#arguments.stContext.userid#: REMOTE CALL FAILED #arguments.sHTTPLocation# #cfcatch.toString()#" />
				
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Could not load file, invalid result' ) />

			</cfcatch>
		</cftry>
		
		<!--- write to disk --->
		<cffile action="write" output="#local.stHTTP.FileContent#" file="#local.sTempFile#" />
		
		<!---
			
			try to analyze
			
			use the appropriate analyzer for each format
			
			- mp3
			- ogg
			- wma
			- m4a
			- flac
			
			--->
		<cfswitch expression="#arguments.iAudio_Format#">
			<cfcase value="#application.const.I_AUDIO_FORMAT_MP3#">
				
				<!--- parse this mp3 --->
				<cfset local.stParse = application.beanFactory.getBean( 'MP3ID3Parser' ).ParseMP3File( local.sTempFile ) />
				
				<cfset stReturn.stParse = local.stParse />
				
				<cfif NOT local.stParse.result>
					
					<!--- error while parsing file? give it one more try using more data ... only if not already done --->
					<cfif local.stParse.error IS application.err.AUDIO_UNABLE_TO_PARSE_FILE AND NOT arguments.bAlternativeTry>
						
						<!--- read 300 kb ... reason might be a photo or something like that which is too big for the first read --->
						<cfset arguments.iHTTPRange = 300000 />						
						<cfset arguments.bAlternativeTry = true />
						
						<cflog application="false" file="tb_parse_remote_file" text="#arguments.stContext.userid# Failed. Trying to re-run the call with more data" />
						
						<!--- run the call one more time --->
						<cfreturn analyzeRemoteFile( argumentCollection = arguments ) />
					
					<cfelse>
						
						<!--- return the error --->
						<cfreturn local.stParse />
						
					</cfif>
				
				<cfelse>
					
					<!--- success! --->
				
				</cfif>
			
			</cfcase>
			<!--- <cfcase value="#application.const.I_AUDIO_FORMAT_M4A#">
			
				<!--- try to read the WMA file --->
				<cfset local.stParse = application.beanFactory.getBean( 'M4AParser' ).ParseM4aFile( local.sTempFile ) />
				
				<cfmail from="post@hansjoergposch.com" to="office@tunesBag.com" subject="parse wma" type="html">
				<cfdump var="#local.stParse#">
				</cfmail>
				
			</cfcase> --->
			<cfdefaultcase>
				<!--- TODO: Handle --->
				<cfset stReturn.unknown = arguments.iAudio_Format />
			</cfdefaultcase>
		</cfswitch>
		
		<!--- invalid file? --->
		<cfif IsNull( stReturn.stParse )>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Could not load file, invalid result' ) />
		</cfif>
		
		<!--- fix the track length ... if below 10, use 0 --->
		<cfif Val( stReturn.stParse.METAINFORMATION.TRACKLENGTH ) LTE 10>
			<cfset stReturn.stParse.METAINFORMATION.TRACKLENGTH = 0 />
		</cfif>
		
		<!--- remove the tmp file --->
		<cffile action="delete" file="#local.sTempFile#" />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction> --->
	
	
	<cffunction access="private" name="createModifyInternalPlaylist" output="false" returntype="struct"
			hint="Every remote plist is stored internally ... for the corrensponding user (8tracks, soundcloud etc) or the personal user account (eg rdio)">
		<cfargument name="stData" type="struct" required="true"
			hint="The plist data" />
		<cfargument name="stUser" type="struct" required="true"
			hint="The user data (plist will be created for this user)" />
		<cfargument name="iSource_Service" type="numeric" required="true"
			hint="Source service" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- quick check! --->
		<cfset local.sPlistKey = application.beanFactory.getBean( 'PlaylistsComponent' ).PlaylistExists(
			userkey					= arguments.stUser.entrykey,
			librarykey				= arguments.stUser.defaultlibrarykey,
			name					= '',
			iSource_Service			= arguments.iSource_Service,
			sExternal_identifier	= arguments.stData.id
			)/>
		
		<cfif Len( local.sPlistKey )>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 202, 'Nothing changed' ) />
		</cfif>
		
		<!--- ok, let's create the plist for real --->
		<cfset local.stPlist = application.beanFactory.getBean( 'PlaylistsComponent' ).CreateEditPlaylist(
			securitycontext			= arguments.stUser,
			entrykey				= '',
			librarykey				= '',
			specialtype				= 0,
			name					= arguments.stData.name,
			description				= arguments.stData.description,
			tags					= arguments.stData.tag_list_cache,
			dynamic					= 1,
			dynamic_criteria		= 'source_service?value=#arguments.iSource_Service#&mix_id=#arguments.stData.id#',
			public					= 1,
			iSource_Service			= arguments.iSource_Service,
			sExternal_identifier	= arguments.stData.id
			)/>
		
		<!--- add image --->	
		<cfif local.stPlist.result AND Len( arguments.stData.cover_urls.original ) GT 0>
			
			<cfset local.sCoverFile = getTempDirectory() & 'remote_plist_' & arguments.stData.id & '.jpg' />
			
			<cfhttp url="#arguments.stData.cover_urls.original#" method="get" result="local.stHTTP" />
			
			<cffile action="write" output="#local.stHTTP.fileContent#" file="#local.sCoverFile#" />
			
			<cfset application.beanFactory.getBean( 'ContentComponent' ).StoreCustomUserImage(
				securitycontext = arguments.stUser,
				image_type		= 'PLAYLIST',
				identifier 		= local.stPlist.entrykey,
				imgsoure 		= local.sCoverFile
				) />
			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	
</cfcomponent>