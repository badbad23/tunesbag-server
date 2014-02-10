<!--- 

	The dropbox connector

 --->

<cfsetting RequestTimeout="6000" />

<cfcomponent output="false" extends="james.cfc.content.providers.provider">
	
	<cfset variables.oDP = 0 />
	<cfset variables.stUserTrackFoundItems = {} />

	<cffunction access="public" name="init" returntype="any" output="false"
			hint="Constructor">

		<!--- init the dropbox component --->
		<cfset variables.oDP = createObject('component','james.cfc.tools.dropbox.uk.co.redgiraffes.dropBox.dropBox').init(
				consumerKey		= application.beanFactory.getBean( 'Environments' ).getProperty( 'DropBoxConsumerKey' ),
				consumerToken	= application.beanFactory.getBean( 'Environments' ).getProperty( 'DropBoxConsumerToken' )
				)/>
		
		<cfreturn this />
	</cffunction>
	
	<!--- getDP ... time for some serious porn --->
	<cffunction access="private" name="getDP" output="false" returntype="any"
			hint="Return the DP component">
		<cfreturn variables.oDP />
	</cffunction>
	
	<cffunction access="private" name="getFoundTracksStruct" returntype="struct"
			hint="Return the struct containing the known items of the user ">
		<cfargument name="stContext" required="true" />

		<!--- if the struct exists, return it otherwise an empty struct --->
		<cfreturn (StructKeyExists( variables.stUserTrackFoundItems, arguments.stContext.userid ) ? variables.stUserTrackFoundItems[ arguments.stContext.userid ] : {} ) />
		
	</cffunction>
	
	<cffunction access="private" name="appendFoundTracks" returntype="void"
			hint="Add hits to stored items">
		<cfargument name="stContext" required="true" />
		<cfargument name="stTrackFoundItems" type="struct" required="false" default="#StructNew()#"
			hint="Tracks found during our scans" />
			
			
		<cfif NOT StructKeyExists( variables.stUserTrackFoundItems, arguments.stContext.userid )>
			<cfset variables.stUserTrackFoundItems[ arguments.stContext.userid ] = {} />
		</cfif>
			
		<cfset StructAppend( variables.stUserTrackFoundItems[ arguments.stContext.userid ], arguments.stTrackFoundItems ) />
		
	</cffunction>
	
	<cffunction access="public" name="getKnownData" output="false" returntype="struct">
		<cfargument name="stContext" type="struct" required="true" />
	
		<cfquery name="local.qData" datasource="mytunesbutlerlogging">
		SELECT	path,revision
		FROM	dropboxdata
		WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userID#" />
		</cfquery>
		
		<cfset local.stData = {} />
		
		<!--- build a simple structure with the path as key in order to check the revision and existing files much easier --->
		<cfloop query="local.qData">
			<cfset local.stData[ local.qData.path ]  = local.qData.revision />
		</cfloop>
		
		<cfreturn local.stData />
		
	</cffunction>
	
	<cffunction access="public" name="getAccessData" output="false" returntype="struct"
			hint="Check if the data for a certain user exists at all">
		<cfargument name="stContext" type="struct" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- get access data --->
		<cfset local.stAccessData = application.beanFactory.getBean( 'UserComponent' ).GetExternalSiteID(
				securitycontext = arguments.stContext,
				servicename 	= application.const.S_SERVICE_DROPBOX ) />

		<!--- nothing found --->
		<cfif NOT local.stAccessData.result>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404 ) />
		</cfif>
		
		<cfset stReturn.oItem = local.stAccessData.a_item />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="performSync" output="false" returntype="struct"
			hint="List the entire content of an account">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="bIgnoreUnchangedDirectories" required="false" default="false"
			hint="Do not scan directories which have not changed" />
		<cfargument name="bIgnoreExistingFiles" required="false" default="false"
			hint="Ignore any files which have already been scanned (exist + revision is the same + published)" />
		<cfargument name="bReturnDataFound" required="false" default="false"
			hint="Return a list of files during the scan" />
		<cfargument name="bRecursive" type="boolean" required="false" default="true"
			hint="Scan folders recursively" />
		<cfargument name="bForceSync" required="false" default="false" type="boolean"
			hint="Ignore any -nothing changed- notification, always scan the directories" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- set status ... --->
		<cfset super.setSourceState(
			stContext 		= arguments.stContext,
			sServicename	= application.const.S_SERVICE_DROPBOX,
			iStatus			= application.const.I_SYNC_SOURCE_STATUS_IN_SYNC
			) />
		
		<!--- load access data --->
		<cfset local.stAccessData = getAccessData( arguments.stContext ) />
		
		<cfif NOT local.stAccessData.result>
			
			<cfset super.setSourceState(
				stContext 		= arguments.stContext,
				sServicename	= application.const.S_SERVICE_DROPBOX,
				iStatus			= application.const.I_SYNC_SOURCE_STATUS_ERROR
				) />
			
			<cfreturn local.stAccessData />
		</cfif>
		
		<cfset local.oAccess = local.stAccessData.oItem />
		
		<!--- load account info --->
		<cfset local.stAccount = getAccountInfo( stContext = arguments.stContext ) />
		
		<cfset stReturn.stAccount = local.stAccount />
		
		<!--- error? --->
		<cfif NOT StructKeyExists( local.stAccount.stAccount, 'quota_info' )>
			
			<cfset super.setSourceState(
				stContext 		= arguments.stContext,
				sServicename	= application.const.S_SERVICE_DROPBOX,
				iStatus			= application.const.I_SYNC_SOURCE_STATUS_ERROR
				) />
				
			<cfmail from="support@tunesBag.com" to="support@tunesBag.com" subject="[Error] Dropbox Sync error" type="html">
			<cfdump var="#local.stAccount#">
			</cfmail>
				
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'An error has occured with this access data' ) />
			
		</cfif>
		
		<!--- check if anything has changed at all --->
		<cfset local.stSyncInfo = application.beanFactory.getBean( 'Sync' ).getSyncInfo(
			stContext		= arguments.stContext,
			sServicename	= application.const.S_SERVICE_DROPBOX
			) />
			
		<cfset stReturn.stSyncInfo = local.stSyncInfo />
		
		<!--- compare data ... any changes at all? --->
		<cfif local.stSyncInfo.result>
			
			<cfif !IsNull( local.stSyncInfo.stinfo.quota_normal ) AND
				!IsNull( local.stSyncInfo.stinfo.quota_shared )>
			
				<cfif local.stAccount.stAccount.quota_info.normal IS local.stSyncInfo.stinfo.quota_normal AND
					local.stAccount.stAccount.quota_info.shared IS local.stSyncInfo.stinfo.quota_shared AND NOT
					arguments.bForceSync>
						
					<!--- set default status ... --->
					<cfset super.setSourceState(
						stContext 			= arguments.stContext,
						sServicename		= application.const.S_SERVICE_DROPBOX,
						iStatus				= application.const.I_SYNC_SOURCE_STATUS_DEFAULT,
						bUpdateLastUpdate	= true
						) />		
						
					<cfset stReturn.bStatusReset = true />
					
					<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 302, 'Nothing has changed so far.' ) />
					
				</cfif>
			
			</cfif>
			
		</cfif>
		
		<!--- make sure our special dropbox plist exists --->
		<cfset createDropboxPlist( arguments.stContext ) />
		
		<!--- track which data from our last run is missing --->	
		<cfset local.stOriginallyKnownData = getKnownData( arguments.stContext ) />
		
		<!--- start with the set root directory --->
		<!--- <cfset local.stContent = analyzeDirectory(
				stContext				= arguments.stContext,
				stAccessData			= {	accessToken = local.oAccess.getUsername(), accessSecret = local.oAccess.getPwd() },
				sPath					= ( IsNull(local.oAccess.getParam1()) ? '' : local.oAccess.getParam1() ),
				bRecursive				= arguments.bRecursive,
				bIgnoreExistingFiles	= true,
				stKnownData				= local.stOriginallyKnownData
				) />	 --->
				
		<cfset stReturn.stSearch	= searchDropboxAccount(
			stContext		= arguments.stContext,
			stAccessData	= {	accessToken = local.oAccess.getUsername(), accessSecret = local.oAccess.getPwd() },
			sPath			= ( IsNull(local.oAccess.getParam1()) ? '' : local.oAccess.getParam1() ),
			stKnownData		= local.stOriginallyKnownData
			) />
				
		<!--- <cfset local.stContent = runAnalyzeDirectoryThreads(
			stContext				= arguments.stContext,
			aDirectories = [
					{
					stContext				= arguments.stContext,
					stAccessData			= {	accessToken = local.oAccess.getUsername(), accessSecret = local.oAccess.getPwd() },
					sPath					= ( IsNull(local.oAccess.getParam1()) ? '' : local.oAccess.getParam1() ),
					bRecursive				= arguments.bRecursive,
					bIgnoreExistingFiles	= true,
					stKnownData				= local.stOriginallyKnownData				
					}
				]) />
				
		<cfif NOT local.stContent.result>
			
			<!--- set default status ... --->
			<cfset super.setSourceState(
				stContext 			= arguments.stContext,
				sServicename		= application.const.S_SERVICE_DROPBOX,
				iStatus				= application.const.I_SYNC_SOURCE_STATUS_DEFAULT,
				bUpdateLastUpdate	= true
				) />		
			
			<cfreturn local.stContent />
		</cfif> --->
		
		<!--- get found data --->
		<cfset local.stTrackFoundItems = getFoundTracksStruct( arguments.stContext ) />
		
		<!--- compare the originally known data with the data available now --->
		
		<cfset local.stDataUpdate = removeNonExistingData(
			stContext				= arguments.stContext,
			stOriginallyKnownData	= local.stOriginallyKnownData,
			stUpdatedKnownData		= local.stTrackFoundItems
			) />
			
		<cfset stReturn.stDataUpdate = local.stDataUpdate />
		
		<!--- store the quota as sync indiciator for our service --->
		<cfset local.stSyncInfo = {
			quota_normal	= local.stAccount.stAccount.quota_info.normal,
			quota_shared	= local.stAccount.stAccount.quota_info.shared
			} />
		
		<!--- store gained sync data --->
		<cfset application.beanFactory.getBean( 'Sync' ).storeSyncInfo(
			stContext		= arguments.stContext,
			sServicename	= application.const.S_SERVICE_DROPBOX,
			stSyncInfo		= local.stSyncInfo
			) />
		
		<!--- return the data found --->	
		<cfif arguments.bReturnDataFound>
			
			<cfset stReturn.stKnownData = getKnownData( arguments.stContext ) />
			
		</cfif>
		
		<!--- set default status ... --->
		<cfset super.setSourceState(
			stContext 			= arguments.stContext,
			sServicename		= application.const.S_SERVICE_DROPBOX,
			iStatus				= application.const.I_SYNC_SOURCE_STATUS_DEFAULT,
			bUpdateLastUpdate	= true
			) />		
			
		<cfset stReturn.bFullScan = true />
		
		<!--- reset known data --->
		<cfset StructClear( getFoundTracksStruct( arguments.stContext ) ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<!--- get the number of directories of a certain user and stop at 500 --->
	<cffunction access="public" name="getDirectoriesCount" output="false" returntype="numeric">
		<cfargument name="stContext" type="struct" required="true" />
		
		<cfquery name="local.qCountDirectories" datasource="mytunesbutlerlogging">
		SELECT	COUNT(d.id) AS count_directories
		FROM	dropboxdata AS d
		WHERE	d.itemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_DIRECTORY#" />
				AND
				d.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
		</cfquery>
		
		<cfreturn Val( local.qCountDirectories.count_directories ) />
		
	</cffunction>
	
	<cffunction access="public" name="getDPTracksCount" output="false" returntype="numeric"
			hint="Return the number of tracks stored for a user with the source dropbox">
		<cfargument name="stContext" type="struct" required="true" />
		
		<cfquery name="local.qCountTracks" datasource="mytunesbutlerlogging">
		SELECT	COUNT(d.id) AS count_tracks
		FROM	dropboxdata AS d
		WHERE	d.itemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_FILE#" />
				AND
				d.user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
		</cfquery>
		
		<cfreturn Val( local.qCountTracks.count_tracks ) />
	</cffunction>
	
	<!--- create the default dropbox plist --->
	<cffunction access="public" name="createDropboxPlist" output="false" returntype="struct"
			hint="Create a playlist including all tracks stored on dropbox">
		<cfargument name="stContext" type="struct" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.stPlist = application.beanFactory.getBean( 'PlaylistsComponent' ).CreateEditPlaylist(
			securitycontext		= arguments.stContext,
			entrykey			= '',
			librarykey			= '',
			name				= 'Dropbox Tracks',
			description			= 'Tracks stored in your Dropbox account',
			dynamic				= 1,
			dynamic_criteria	= 'source?value=dp'
			) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
		<!--- 
		
<cffunction access="public" name="CreateEditPlaylist" output="false" returntype="struct"
		hint="Create a new playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" default="" required="false"
		hint="entrykey if edit operation">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="specialtype" type="numeric" required="false" default="0"
		hint="0 = default, 1 = soml" />
	<cfargument name="name" type="string" required="true">
	<cfargument name="description" type="string" required="true">
	<cfargument name="tags" type="string" required="false" default="">
	<cfargument name="temporary" type="numeric" default="0" required="false"
		hint="A temporary playlist?">
	<cfargument name="dynamic" type="numeric" default="0" required="false"
		hint="is this a dynamic playlist?">
	<cfargument name="dynamic_criteria" type="string" default="" required="false"
		hint="criteria of the dynamic playlist">
		 --->
			
	</cffunction>
	
	<cffunction access="public" name="removeNonExistingData" output="false" returntype="struct"
			hint="Remove data from tunesBag which does not exist any more on dp">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="stOriginallyKnownData" type="struct" required="true"
			hint="The known data before running the update" />
		<cfargument name="stUpdatedKnownData" type="struct" required="true"
			hint="The data known AFTEr the update" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.aDeleteItems = ArrayNew(1) />
		
		<cflog
					application	= "false"
					file		= "tb_dropbox_scan"
					log			= "Application"
					type		= "information"
					text		= "#arguments.stContext.userid#: Detecting invalid old items"
					/>
		
		<cfloop collection="#arguments.stOriginallyKnownData#" item="local.s">
			
			<cfif NOT StructKeyExists( arguments.stUpdatedKnownData, local.s)>
				
				<!--- item does not exist any more, add to delete list --->
				<cfset ArrayAppend( local.aDeleteItems, local.s ) />
				
			</cfif>
		
		</cfloop>
			
		<cfset stReturn.aDeleteItems = local.aDeleteItems>
		
		<!--- remove these items now --->
		<cfif ArrayLen( local.aDeleteItems ) GT 0>
			
			<cfquery name="local.qSelectDelete" datasource="mytunesbutlerlogging">
			SELECT	mediaitemkey,
					id
			FROM	dropboxdata
			WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
					AND
					
					(
						<cfloop from="1" to="#ArrayLen( local.aDeleteItems )#" index="local.ii">
							(path = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.aDeleteItems[ local.ii ]#">)
							OR
						</cfloop>
						
						(1=0)
						
					)
					
<!--- 					path IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ArrayToList( local.aDeleteItems )#" list="true" />) --->
			</cfquery>
			
			<cfset streturn.qSelectDelete = local.qSelectDelete />
			
			<!--- delete from mediaitems --->
			<cfloop query="local.qSelectDelete">
				<cfset stReturn.stDelete[ local.qSelectDelete.mediaitemkey ] = application.beanFactory.getBean( 'MediaItemsComponent' ).RemoveItemFromLibrary(
					securitycontext = arguments.stContext,
					entrykey		= local.qSelectDelete.mediaitemkey ) />
			</cfloop>
			
			<!--- delete from dropboxdata --->
			<cfquery name="local.qDeleteDPItems" datasource="mytunesbutlerlogging" result="local.stDelete">
			DELETE FROM	dropboxdata
			WHERE		user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
						AND
						id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( local.qSelectDelete.id )#" list="true" />)
			</cfquery>
			
			<cfset streturn.stDelete = local.stDelete />
			
		</cfif>
		
		<cflog
			application	= "false"
			file		= "tb_dropbox_scan"
			log			= "Application"
			type		= "information"
			text		= "#arguments.stContext.userid#: #ArrayLen( local.aDeleteItems )# items removed."
			/>

		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<!--- get very basic account info in order to check if anything has changed at all --->
	<cffunction access="public" name="getAccountInfo" output="false" returntype="struct"
			hint="Get very basic account info">
		<cfargument name="stContext" type="struct" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- load access data (oauth) --->
		<cfset local.stAccessData = getAccessData( arguments.stContext ) />
		<cfset local.oAccess = local.stAccessData.oItem />
		
		<cfset local.stAccount = getDP().getAccountInfo(
					accessToken 	= local.oAccess.getUsername(),
					accessSecret 	= local.oAccess.getPwd()
					) />
		
		<cfset stReturn.stAccount = local.stAccount />
		
		<!--- check if anything has changed
		
			we perform this check by adding normal + shared size and if anything is different, there has
			something changed.
			
			
		 --->
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="getDeliveryInformation" output="false" returntype="struct"
			hint="Return the delivery information">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="sMetaHashValue" type="string" required="false" default=""
			hint="Meta hash value of the file (see docs for specs)" />
		<cfargument name="iId" type="numeric" required="false" default="0"
			hint="ID to filter for" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- load access data (oauth) --->
		<cfset local.stAccessData = getAccessData( arguments.stContext ) />
		<cfset local.oAccess = local.stAccessData.oItem />
		
		<cfquery name="local.qPath" datasource="mytunesbutlerlogging">
		SELECT	path
		FROM	dropboxdata
		WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
				AND
				itemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_FILE#" />
				AND
				
				<cfif Len( arguments.sMetaHashValue )>
					MetaHashValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sMetaHashValue#" />				
				<cfelse>
					/* default search */
					id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iID#" />
				</cfif>
		
		LIMIT	1
		</cfquery>
		
		<!--- TODO: handle errors --->
		
		<cfset local.sURL = getDP().getDBFile(
					accessToken 	= local.oAccess.getUsername(),
					accessSecret 	= local.oAccess.getPwd(),
					path			= local.qPath.path
					) />
		
		<cfset stReturn.sURL = local.sURL.url />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="collectThreadOutput" output="false" returntype="struct"
			hint="Join the given threads and wait for the results and send back combined ... don't create thousands of threads at one time">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="lThreadNames" type="string" required="true"
			hint="Names of the threads to collect" />
		<!--- this argument is passed to all calls in order to collect the found tracks properly --->
		<!--- <cfargument name="stTrackFoundItems" type="struct" required="false" default="#StructNew()#"
			hint="Tracks found during our scans" /> --->
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- directories to scan in the next round --->
		<cfset local.aDirectoriesToScan = ArrayNew( 1 ) />
		
		<!--- join all threads ... 5 min timeout --->
		<cfthread action="join" name="#arguments.lThreadNames#" timeout="#( 10 * 60 * 1000 )#"></cfthread>
		
		<!--- get list of directories found during scanning the directories and launch new threads for them --->
		<cfloop from="1" to="#ListLen( arguments.lThreadNames )#" index="local.iThreadIndex">
		
			<cfset local.oThread = cfThread[ ListGetAt( arguments.lThreadNames, local.iThreadIndex ) ] />
		
			<cfif StructKeyExists( local.oThread, 'stScanResult' )>
			
				<cfif StructKeyExists( local.oThread.stScanResult, 'iDuration' )>
					<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="--- Thread #local.iThreadIndex# status: #local.oThread.status# (Runtime: #local.oThread.stScanResult.iDuration#))" />
				</cfif>
				
				<!--- get the thread and the result of the scan --->
				<cfset local.stDirResult = local.oThread.stScanResult />
	
				<!--- did it work? --->
				<cfif local.stDirResult.result>
					
					<cfset local.aDirectoriesFound = local.stDirResult.aDirectoriesFound />
					
					<!--- combine results ... --->
					<cfloop from="1" to="#arrayLen( local.stDirResult.aDirectoriesFound )#" index="local.ii">
						<cfset ArrayAppend( local.aDirectoriesToScan, local.stDirResult.aDirectoriesFound[ local.ii ] ) />
					</cfloop>
					
					<!--- merge structs of known items --->
					<cfset appendFoundTracks(
						stContext 			= arguments.stContext,
						stTrackFoundItems	= local.stDirResult.stTrackFoundItems
						) />
					<!--- <cfset StructAppend( arguments.stTrackFoundItems, local.stDirResult.STTRACKFOUNDITEMS ) /> --->
			
				</cfif>
				
			<cfelse>
				<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="!!!! No Scan Result found, exception?" />
			</cfif>
			
		</cfloop>
		
		<!--- return the directories found in this round --->
		<cfset stReturn.aDirectoriesToScan = local.aDirectoriesToScan />
		
		<!--- items found --->
		<!--- <cfset stReturn.stTrackFoundItems = arguments.stTrackFoundItems /> --->
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<!--- 
		analyze multiple directories at once, run the analysis for a single directory within a thread
		
		pass the entire argumentCollection to the analyzeDirectory call
	 --->
	<!--- <cffunction access="public" name="runAnalyzeDirectoryThreads" output="false" returntype="struct">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="aDirectories" type="array" required="true"
			hint="Array of Directories to scan" />
			
		<!--- this argument is passed to all calls in order to collect the found tracks properly --->
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- collect thread names --->
		<cfset local.lThreadNames = '' />
		
		<!--- directories to scan in the next round --->
		<cfset local.aDirectoriesToScan = ArrayNew( 1 ) />
		
		<cfset local.iDirCount = ArrayLen( arguments.aDirectories ) />
				
		<!--- scan max 50 directories at once, move the others to the next round --->
		<cfset local.iMaxDirsAtOnce = 50 />
		
		<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="///// Dir counter for this round: #local.iDirCount#" />
		
		<!--- packages of 50 --->
		<cfloop from="1" to="#local.iDirCount#" step="#local.iMaxDirsAtOnce#" index="local.ii">
		
			<!--- check out from/ to  ... 1 to 50 for this term --->
			<cfset local.iTo = ( local.ii + local.iMaxDirsAtOnce ) - 1 />
			
			<cfif local.iTo GT local.iDirCount>
				<cfset local.iTo = local.iDirCount />
			</cfif>
			
			<!--- reset thread name list (important, otherwise we would scan the same files again and again) --->
			<cfset local.lThreadNames = '' />
		
			<cfloop from="#local.ii#" to="#local.iTo#" index="local.iThreadIndex">
				
				<!--- use the args for the given directory and pass it to the thread --->
				<cfset local.stArgs = arguments.aDirectories[ local.iThreadIndex ] />
								
				<cfset local.sThreadName = "dp_analyze_#local.stArgs.stContext.userid#_#local.iThreadIndex#_#Hash( local.stArgs.sPath )#" />
				<cfset local.lThreadNames = ListAppend( local.lThreadNames, local.sThreadName ) />
				
				<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="///// Launching Thread #local.sThreadName# (#local.iThreadIndex# / #local.iDirCount#) for directory #local.stArgs.sPath#" />
				
				<cfthread action="run" name="#local.sThreadName#" priority="low" stArgs="#local.stArgs#">
					
					<cfsetting RequestTimeout="6000" />
					
					<!--- <cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="///// Starting Thread for #local.stArgs.sPath#" /> --->
					
					<!--- return directories found while scanning this directory --->
					<cfset thread.stScanResult = analyzeDirectory( argumentCollection = attributes.stArgs ) />
					
				</cfthread>
				
				<!--- sleep 500 msec --->
				<cfset sleep( RandRange( 50, 200 ) ) />
				
			</cfloop>
			
			<!--- collect! --->
			<cfset local.stCollect = collectThreadOutput( arguments.stContext, local.lThreadNames ) />
			
			<!--- directories to scan in the next round --->
			<cfset local.aDirectoriesFound = local.stCollect.aDirectoriesToScan />
			
			<!--- combine results ... --->
			<cfloop from="1" to="#arrayLen( local.aDirectoriesFound )#" index="local.ii">
				<cfset ArrayAppend( local.aDirectoriesToScan, local.aDirectoriesFound[ local.ii ] ) />
			</cfloop>
			
			<!--- merge structs of known items --->
			<!--- <cfset StructAppend( arguments.stTrackFoundItems, local.stCollect.stTrackFoundItems ) /> --->
			
		
		</cfloop>
		
		<!--- directories to scan --->
		
		<!--- <cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="///// Waiting for Threads to join ..." />
		<cfset local.iTc = GetTickcount() />
		
		<!--- join all threads ... 5 min timeout --->
		<cfthread action="join" name="#local.lThreadNames#" timeout="#( 10 * 60 * 1000 )#"></cfthread>
		
		<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="////// Done! #( GetTickCount() - local.iTC )#" />		
			
		<!--- get list of directories found during scanning the directories and launch new threads for them --->
		<cfloop from="1" to="#ListLen( local.lThreadNames )#" index="local.iThreadIndex">
		
			<cfset local.oThread = cfThread[ ListGetAt( local.lThreadNames, local.iThreadIndex ) ] />
		
			
			
			<cfif StructKeyExists( local.oThread, 'stScanResult' )>
			
				<cfif StructKeyExists( local.oThread, 'iDuration' )>
					<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="--- Thread status: #local.oThread.status# (Runtime: #local.oThread.iDuration#))" />
				</cfif>
				
				<!--- get the thread and the result of the scan --->
				<cfset local.stDirResult = local.oThread.stScanResult />
	
				<!--- did it work? --->
				<cfif local.stDirResult.result>
					
					<cfset local.aDirectoriesFound = local.stDirResult.aDirectoriesFound />
					
					<!--- combine results ... --->
					<cfloop from="1" to="#arrayLen( local.stDirResult.aDirectoriesFound )#" index="local.ii">
						<cfset ArrayAppend( local.aDirectoriesToScan, local.stDirResult.aDirectoriesFound[ local.ii ] ) />
					</cfloop>
					
					<!--- merge structs of known items --->
					<cfset StructAppend( arguments.stTrackFoundItems, local.stDirResult.STTRACKFOUNDITEMS ) />
			
				</cfif>
				
			<cfelse>
				<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="!!!! No Scan Result found, exception?" />
			</cfif>
			
		</cfloop> --->
		
		<!--- any sub directories? --->
		<cfif ArrayLen( local.aDirectoriesToScan ) GT 0>
		
			<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="\\\\\ launching next threads" />
			
			<!--- start new scans for the next level --->
			
			<!--- compose arguments --->
			<cfset local.stArgs = {} />
			<cfset StructAppend( local.stArgs, arguments ) />
			
			<!--- overwrite unique properties --->
			<cfset local.stArgs.aDirectories = local.aDirectoriesToScan />
			<!--- <cfset local.stArgs.stTrackFoundItems = arguments.stTrackFoundItems /> --->
			
			<cfset runAnalyzeDirectoryThreads( argumentCollection = local.stArgs ) />
			
		</cfif>
		
		<!--- return the tracks found --->
		<!--- <cfset stReturn.stTrackFoundItems = arguments.stTrackFoundItems /> --->
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction> --->
	
	<!---<cffunction access="public" name="analyzeDirectory" output="false" returntype="struct"
			hint="List the content of a folder">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="stAccessData" type="struct" required="true"
			hint="oAuth information for dropbox" />
		<cfargument name="sPath" type="string" required="false" default=""
			hint="The path to start with" />
		<cfargument name="bRecursive" type="boolean" required="false" default="false"
			hint="List the items of a folder" />
		<cfargument name="stKnownData" type="struct" required="false" default="#StructNew()#"
			hint="Information about the existing data, needed in case the data should be ignored in this case" />
		<cfargument name="bIgnoreUnchangedDirectories" required="false" default="false"
			hint="Do not scan directories which have not changed" />
		<cfargument name="bIgnoreExistingFiles" required="false" default="false"
			hint="Ignore any files which have already been scanned (exist + revision is the same + published)" />
		<!--- <cfargument name="stTrackFoundItems" type="struct" default="#StructNew()#"
			hint="Track the items found in our scan" />	 --->	
		<cfargument name="bIgnoreFiles" type="boolean" required="false" default="false"
			hint="Directories only, no files" />
			
		<cfsetting requesttimeout="1200" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.stTrackFoundItems = {} />
		<cfset local.aDirectoriesFound = ArrayNew(1) />
		<cfset local.iTC = GetTickcount() />
		
		<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#arguments.stContext.userid#: ||||| Scanning folder #arguments.sPath# |||||" />
		
		<!--- not more than 6 directory levels --->
		<cfif ListLen( arguments.sPath, '/' ) GT application.const.I_DROPBOX_MAX_DIRECTORY_LEVEL>
			<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#arguments.stContext.userid#: Stopped, that's too deep" />
			
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Directory level is too deep' ) />
		</cfif>
		
		<cftry>
			
			<!--- 
			
				get meta information for the given folder
			
			 --->
			<cftry>
			<cfset local.stGetMetaData = getDP().getDBMetaData(
				accessToken		= arguments.stAccessData.accessToken,
				accessSecret	= arguments.stAccessData.accessSecret,
				path			= arguments.sPath
				) />
				
			<cfcatch type="any">
				<!--- dont't raise an exception on that one ... it will fail automativally --->
				
				<cflog application="false" file="tb_dropbox_failure" log="Application" type="information" text="EXCEPTION: #cfcatch.Message#" />
				
			</cfcatch>
			</cftry>
			
			<!--- did an error occur? --->	
			<cfif NOT StructKeyExists( local.stGetMetaData, 'contents' )>
				
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Error while scanning dropbox folder' ) />
				
			</cfif>
				
			<!---
				add root dir (or the the directory of the current path)
				--->
			<cfset local.aContent = local.stGetMetaData.contents />
			
			<!--- 
				revision might be 0 for some folders or not exist at all
			 --->
			<cfif StructKeyExists( local.stGetMetaData, 'revision' )>
				<cfset local.iPathRevision = local.stGetMetaData.revision />
			<cfelse>
				<cfset local.iPathRevision = 0 />
			</cfif>
			
			<!--- 
				add the same way the other content looks like
			 --->
			<cfset ArrayPrepend(
					local.aContent,
					{
						hash 		= local.stGetMetaData.hash,
						path		= local.stGetMetaData.path,
						is_dir		= true,
						revision	= local.iPathRevision
						
					}		
					) />
			
			<!--- 
			
				loop over all items, check if it is a file or a directory,
				recursively take a look at the other files and fill up the
				array
			
			 --->
			<cfloop from="1" to="#ArrayLen( local.aContent )#" index="local.ii">
				
				<cfset local.aItem = local.aContent[ local.ii ] />
				
				<!--- directory? --->
				<cfif local.aItem.is_dir>
					<cfset local.iItemType = application.const.I_DROPBOX_ITEM_DIRECTORY />
				<cfelse>
					<cfset local.iItemtype = application.const.I_DROPBOX_ITEM_FILE />
				</cfif>
				
				<!--- <cflog
					application	= "false"
					file		= "tb_dropbox_scan"
					log			= "Application"
					type		= "information"
					text		= "#arguments.stContext.userid#: next item: #local.aItem.path# (#local.iItemtype#)"
					/> --->
					
				<!--- simple tracker for later comparision if the file or directory exists --->
				<cfset local.stTrackFoundItems[ local.aItem.path ] = local.aItem.revision />
				
				<!--- file --->
				<cfif local.iItemType IS application.const.I_DROPBOX_ITEM_FILE AND NOT arguments.bIgnoreFiles>
					
					<!--- check if the item is supported at all (file extension check)
					
						mp3 is the only format at the moment --->
					<cfif ListFindNoCase( 'mp3,m4a,wma,ogg', ListLast( local.aItem.path, '.')) GT 0>
					
						<cflog
						application	= "false"
						file		= "tb_dropbox_scan"
						log			= "Application"
						type		= "information"
						text		= "#arguments.stContext.userid#: item: #local.aItem.path# (#local.iItemtype#)"
						/>
						
						<!---
							does the file already exist in our database?
						--->
						
						<cfset local.bScanFile = true />
						
						<cfif arguments.bIgnoreExistingFiles AND StructCount( arguments.stKnownData )>
							
							<!---
								item exists and rev is the same?
							 --->
							<cfif StructKeyExists( arguments.stKnownData, local.aItem.path )>
								<cfset local.bScanFile = false />
							</cfif>
							
						
						</cfif>
						
						<!---  scan the file, add it to the local content cache with the status NEW --->
						<cfif local.bScanFile>
							
							
							<cftry>
							<cfquery name="local.qInsert" datasource="mytunesbutlerlogging">
							INSERT INTO	dropboxdata
							SET			user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userID#" />,
										path		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.aItem.path#" />,
										revision	= <cfqueryparam cfsqltype="cf_sql_integer" value="#Val( local.aItem.revision )#" />,
										itemtype	= <cfqueryparam cfsqltype="cf_sql_integer" value="#local.iItemtype#" />,
										pathhash	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Hash( local.aItem.path,"SHA")#" />,
										dt_created	= CURRENT_TIMESTAMP
							</cfquery>
							
							<cfcatch type="any">
								<!--- TODO: check reason for exception --->
								<cflog
									application	= "false"
									file		= "tb_dropbox_scan"
									log			= "Application"
									type		= "information"
									text		= "#arguments.stContext.userid#: Adding failed: #cfcatch.Message#"
									/>
							</cfcatch>
							</cftry>
							
							<cflog
									application	= "false"
									file		= "tb_dropbox_scan"
									log			= "Application"
									type		= "information"
									text		= "#arguments.stContext.userid#: NEW, added"
									/>
							
						</cfif>						
						
					</cfif>
				
				<cfelse>
					
					<!---
						a directory
						
						should we inspect it as well?
						
						make sure the path is not invalid
					 --->
					
					<cftry>
						
						<!--- check if the directory exists, otherwise ignore the item --->
						<cfquery name="local.qDirExists" datasource="mytunesbutlerlogging">
						SELECT	id AS dp_id,
								revision
						FROM	dropboxdata
						WHERE	user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userID#" />
								AND
								pathhash	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Hash( local.aItem.path,"SHA")#" />
								AND
								itemtype	= <cfqueryparam cfsqltype="cf_sql_integer" value="#local.iItemtype#" />
								;
						</cfquery>
						
						<!--- do we have to update anything?
						
							if the item is not new and the revision is the same, ignore it
							 --->

						<cfset local.bDirectoryNoChanges = (local.qDirExists.recordcount IS 1) AND (local.qDirExists.revision IS local.aItem.revision) />
						
						<cfif NOT local.bDirectoryNoChanges>
							
							<!--- new or something has changed --->
							<cfquery name="local.qInsertUpdate" datasource="mytunesbutlerlogging">
								
							<cfif local.qDirExists.recordcount IS 0>
								INSERT INTO	dropboxdata
							<cfelse>
								UPDATE dropboxdata
							</cfif>
							
							SET			
										revision	= <cfqueryparam cfsqltype="cf_sql_integer" value="#Val( local.aItem.revision )#" />
										
										<cfif local.qDirExists.recordcount IS 0>
	
											,pathhash	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Hash( local.aItem.path,"SHA")#" />,
											itemtype	= <cfqueryparam cfsqltype="cf_sql_integer" value="#local.iItemtype#" />,
											status		= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_NEW#" />,
											user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userID#" />,
											path		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.aItem.path#" />,
											dt_created	= CURRENT_TIMESTAMP
											
										<cfelse>
											WHERE	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qDirExists.dp_id#" />
										</cfif>
							</cfquery>
						
						</cfif>
						
					<cfcatch type="any">
						<!--- the directory might already exist ... --->
					</cfcatch>
					</cftry>
					
					<!--- scan next directory? --->					 
					<cfif arguments.bRecursive AND
						Len( local.aItem.path ) GT 1 AND
						(local.aItem.path NEQ arguments.sPath)>
						
						<!--- continue scanning? --->
						<cfset local.bContinueScanning = true />

						<!--- check against total directory count --->
						<cfset local.iDirectoriesCount = getDirectoriesCount( stContext = arguments.stContext ) />
						
						<!--- get files count --->
						<cfset local.iTracksCount = getDPTracksCount( stContext = arguments.stContext ) />
						
						<!--- too many tracks? abort --->
						<cfif local.iTracksCount GT application.const.I_DROPBOX_MAX_FILES_TO_HOLD>
							<cfset local.bContinueScanning = false />
							<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#arguments.stContext.userid#: Stopped, too many files (#local.iTracksCount# vs #application.const.I_DROPBOX_MAX_FILES_TO_HOLD#). #local.aItem.path# is ignored" />							
						</cfif>
						
						<!--- test --->
						<!--- <cfset local.iDirectoriesCount = 0 /> --->
							
						<!--- to many directories --->
						<cfif local.iDirectoriesCount GT application.const.I_DROPBOX_MAX_DIRECTORIES_TO_SCAN>
							<cfset local.bContinueScanning = false />
							<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#arguments.stContext.userid#: Stopped, too many directories (#local.iDirectoriesCount# vs #application.const.I_DROPBOX_MAX_DIRECTORIES_TO_SCAN#). #local.aItem.path# is ignored" />
						</cfif>
						
						<!--- continue! --->
						<cfif local.bContinueScanning>
								
							<!--- add to list of found directories --->	
							<cfset local.aDirectoriesFound[
								ArrayLen( local.aDirectoriesFound ) + 1 ] = {
									stContext 					= arguments.stContext,
									stAccessData 				= arguments.stAccessData,
									sPath 						= local.aItem.path,
									bRecursive					= true,
									bIgnoreExistingFiles		= arguments.bIgnoreExistingFiles,
									stKnownData					= arguments.stKnownData,
									bIgnoreUnchangedDirectories	= arguments.bIgnoreUnchangedDirectories
									} />
						</cfif>
								
					</cfif>
					
				</cfif>
					
			</cfloop>
				
			<cfcatch type="any">
				<!--- error --->
				<cfset stReturn.stCatch = cfcatch />
				
				<cflog application="false" file="tb_dropbox_scan_exception" log="Application" type="information" text="#arguments.stContext.userid#: exception: #cfcatch.messsage#" />
				
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, cfcatch.Message ) />
			</cfcatch>
		</cftry>
		
		<!--- return the directories found --->
		<cfset stReturn.aDirectoriesFound = local.aDirectoriesFound />
				
		<!--- return the tracked items --->
		<cfset stReturn.stTrackFoundItems = local.stTrackFoundItems />
		
		<!--- duration --->
		<cfset stReturn.iDuration = (GetTickcount() - local.iTC ) />
				
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction> --->
	
	<cffunction access="public" name="searchDropboxAccount" output="false" returntype="struct"
			hint="Perform global search for media files">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="stAccessData" type="struct" required="true"
			hint="oAuth information for dropbox" />
		<cfargument name="sPath" type="string" default="/" required="false"
			hint="Root folder for search" />
		<cfargument name="stKnownData" type="struct" required="false" default="#StructNew()#"
			hint="Information about the existing data, needed in case the data should be ignored in this case" />			
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var file = 0 />
		
		<cfset local.stTrackFoundItems = {} />
		<cfset local.aFiles = [] />
		
		<cfset local.aFiles.addAll( getDP().getDBSearchResult(
				accessToken		= arguments.stAccessData.accessToken,
				accessSecret	= arguments.stAccessData.accessSecret,
				path			= arguments.sPath,
				query			= '.mp3'
				)) />
		
		<cfset local.aFiles.addAll( getDP().getDBSearchResult(
				accessToken		= arguments.stAccessData.accessToken,
				accessSecret	= arguments.stAccessData.accessSecret,
				path			= arguments.sPath,
				query			= '.m4a'
				)) />
				
		<cfset local.aFiles.addAll( getDP().getDBSearchResult(
				accessToken		= arguments.stAccessData.accessToken,
				accessSecret	= arguments.stAccessData.accessSecret,
				path			= arguments.sPath,
				query			= '.wma'
				)) />			
				
		<cfset local.aFiles.addAll( getDP().getDBSearchResult(
				accessToken		= arguments.stAccessData.accessToken,
				accessSecret	= arguments.stAccessData.accessSecret,
				path			= arguments.sPath,
				query			= '.ogg'
				)) />						
		
		<!--- handle the files --->
		<cfloop from="1" to="#ArrayLen( local.aFiles )#" index="local.ii">
		
			<cfset file = local.aFiles[ local.ii ] />
			
			<!--- an audio file? --->
			<cfif ListFindNoCase( 'mp3,m4a,wma,ogg', ListLast( file.path, '.')) GT 0>
			
				<!--- a new file? --->
				<cfset local.bScanFile = true />
			
				<cfif StructCount( arguments.stKnownData ) && StructKeyExists( arguments.stKnownData, file.path )>
					<cfset local.bScanFile = false />
				</cfif>
							
			
				<cfset local.stTrackFoundItems[ file.path ] = file.revision />
				
				<!---  scan the file, add it to the local content cache with the status NEW --->
				<cfif local.bScanFile>
							
							
					<cftry>
						
					<cfquery name="local.qInsert" datasource="mytunesbutlerlogging">
					INSERT INTO	dropboxdata
					SET			user_ID 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userID#" />,
								path		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#file.path#" />,
								revision	= <cfqueryparam cfsqltype="cf_sql_integer" value="#Val( file.revision )#" />,
								itemtype	= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_FILE#" />,
								pathhash	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#Hash( file.path,"SHA")#" />,
								dt_created	= CURRENT_TIMESTAMP
					</cfquery>
					
					<cfcatch type="any">
						<!--- TODO: check reason for exception --->
						<cflog
							application	= "false"
							file		= "tb_dropbox_scan"
							log			= "Application"
							type		= "information"
							text		= "#arguments.stContext.userid#: Adding failed: #cfcatch.Message#"
							/>
					</cfcatch>
					</cftry>
					
			</cfif>
	
			</cfif>
		
		</cfloop>
		
		<!--- <cfset stReturn.aFiles = local.aFiles /> --->
		
		<cfset stReturn.stTrackFoundItems = local.stTrackFoundItems />
		
		<!--- merge structs of known items (THIS IS LEGACY STYLE because of the way it worked before)--->
		<cfset appendFoundTracks(
			stContext 			= arguments.stContext,
			stTrackFoundItems	= local.stTrackFoundItems
			) />

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="getDropboxData" output="false" returntype="query">
		<cfargument name="iDropbox_ID" type="numeric" required="true" />
		
		<cfquery name="local.qItem" datasource="mytunesbutlerlogging">
		SELECT		d.user_ID,
					d.id AS dp_id,
					d.path,
					d.pathhash,
					d.status,
					u.entrykey AS userkey
		FROM		dropboxdata AS d
		LEFT JOIN	mytunesbutleruserdata.users AS u ON (u.id = d.user_ID)
		WHERE		d.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iDropbox_ID#" />
		LIMIT		1
		</cfquery>
		
		<cfreturn local.qItem />
		
	</cffunction>
	
	<cffunction access="public" name="getNextItemsToAnalyze" output="false" returntype="struct"
			hint="Next item to analyze">
		<cfargument name="iMaxRows" type="numeric" required="false" default="10"
			hint="How many items to return at one time?" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- array of jobs --->
		<cfset stReturn.aJobs = ArrayNew(1) />
		
		<!--- holding the security context of the the user(s) --->
		<cfset local.stSecContext = {} />
		
		<cfquery name="local.qDummy" datasource="mytunesbutlerlogging">
		SET  @dp_rownumber = 0;
		</cfquery>
		
		<cfquery name="local.qNext" datasource="mytunesbutlerlogging">
		SELECT * FROM (
		SELECT		d.user_ID,
					d.id AS dp_id,
					d.path,
					d.pathhash,
					d.status,
					u.entrykey AS userkey,
					
					/* 
		 
					 make sure that we receive items of various users and not just one. otherwise there might be 50 items but just of user A and
					 users B, C, D would have to wait until data of user A has been analyzed alltogether. 
					  
					 */
					CASE
	                 WHEN @dp_userid != d.user_ID THEN @dp_rownumber := 1 
	                 ELSE @dp_rownumber := @dp_rownumber + 1
	               END AS rank,
	               @dp_userid := d.user_ID
					
		FROM		dropboxdata AS d
		LEFT JOIN	mytunesbutleruserdata.users AS u ON (u.id = d.user_ID)
		LEFT JOIN	mytunesbutlercontent.sourcessyncstate AS state ON (state.user_ID = d.user_ID AND state.servicename = '#application.const.S_SERVICE_DROPBOX#')
		LEFT JOIN	mytunesbutleruserdata.3rdparty_ids AS accessdata ON (accessdata.userkey = u.entrykey AND accessdata.servicename = '#application.const.S_SERVICE_DROPBOX#')
		WHERE		d.status 		= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_NEW#" />
					AND
					d.itemtype 		= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_FILE#" />
					AND
					/* source is working! */
					accessdata.isworking = 1
					AND NOT
					u.id IS NULL
					AND NOT
					state.id IS NULL
					AND NOT
					/* make sure source is ok */
					state.status	= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_SYNC_SOURCE_STATUS_ERROR#" />
		ORDER BY	d.id

		/* max 10 tracks per user */
		) AS t WHERE rank <= 10
		ORDER BY	dp_id
		LIMIT		#arguments.iMaxRows#
		</cfquery>
		
		<cfif local.qNext.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'Nothing to do' ) />
		</cfif>
		
		<!--- update the status of the file ... --->
		<cfquery name="local.qUpdate" datasource="mytunesbutlerlogging">
		UPDATE	dropboxdata
		SET		status 	= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_ANALYZE_IN_PROGRESS#" />
		WHERE	id		IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( local.qNext.dp_id )#" list="true" />)
		</cfquery>
		
		<!--- loop over the items --->
		<cfloop query="local.qNext">
			
			<!--- get delviery information using the security context of the owner --->
			<cfset local.stSecContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( local.qNext.userkey ) />	
			
			<!--- get delivery information from dropbox --->
			<cfset local.stDPinfo = getDeliveryInformation(
					stContext	= local.stSecContext,
					iID 		= local.qNext.dp_id
					) />
					
			<!--- generate a second URL as re-requesting the URL with dropbox will not work (token expired)
			  this is necessary for getting the entire file in case the first 20kb do not work --->
			<cfset local.stDPinfo2 = getDeliveryInformation(
					stContext	= local.stSecContext,
					iID 		= local.qNext.dp_id
					) />
			
			<!--- alright? --->
			<cfif local.stDPinfo.result>
			
				<!--- which audio file type? --->
				<cfset local.iAudio_Format = application.udf.getAudioFormatByExt( ListLast( local.qNext.path, '.' )) />		
				
				<!--- return location etc --->
				<cfset stReturn.aJobs[ ArrayLen( stReturn.aJobs ) + 1 ] = {
					iUser_ID			= local.qNext.user_ID,
					iDropBox_ID			= local.qNext.dp_id,
					iAudio_Format		= local.iAudio_Format,
					iStoreType_ID 		= application.const.I_STORAGE_TYPE_DROPBOX,
					sHTTPLocation		= local.stDPInfo.sURL,
					sHTTPLocationAlt	= local.stDPinfo2.sURL
					} />
			
			</cfif>
		
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
		
	<!--- <cffunction access="public" name="analyzeItems" output="false" returntype="struct"
			hint="Handle new items and analyze tags">
				
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- holding the security context of the the user(s) --->
		<cfset local.stSecContext = {} />
		
		<cfquery name="local.qFiles" datasource="mytunesbutlerlogging">
		SELECT		d.user_ID,
					d.id AS dp_id,
					d.path,
					d.pathhash,
					d.status,
					u.entrykey AS userkey
		FROM		dropboxdata AS d
		LEFT JOIN	mytunesbutleruserdata.users AS u ON (u.id = d.user_ID)
		WHERE		d.status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_NEW#" />
					AND
					d.itemtype = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_ITEM_FILE#" />
					AND NOT
					u.id IS NULL
		ORDER BY	d.id
		LIMIT		50
		</cfquery>
		
		<cfif local.qFiles.recordcount IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'Nothing to do' ) />
		</cfif>
		
		<cfquery name="local.qUpdateStatus" datasource="mytunesbutlerlogging">
		UPDATE	dropboxdata
		SET		status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_ANALYZING#" />
				WHERE
				id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( local.qFiles.dp_id )#" list="true" />)
		</cfquery>
		
		<cfloop query="local.qFiles">
			
			<!--- get securitycontext --->
			<cfif NOT StructKeyExists( local.stSecContext, local.qFiles.user_ID)>
				<cfset local.stSecContext[ local.qFiles.user_ID ] = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( local.qFiles.userkey ) />				
			</cfif>
			
			<!--- now we've the delivery information --->
			<cfset local.stDPinfo = getDeliveryInformation(
					stContext	= local.stSecContext[ local.qFiles.user_ID ],
					iID 		= qFiles.dp_id
					) />
					
			<cfif local.stDPInfo.result>
				
				<cfset local.iAudio_Format = application.udf.getAudioFormatByExt( ListLast( local.qFiles.path, '.' )) />
				
				<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#local.qFiles.user_id#: scanning: #local.qFiles.path#" />
				
				<!--- call fn of the parent component --->
				<cfset local.stAnalyze = analyzeRemoteFile(
					stContext		= local.stSecContext[ local.qFiles.user_ID ],
					iAudio_Format	= local.iAudio_Format,
					iStoreType_ID 	= application.const.I_STORAGE_TYPE_DROPBOX,
					sHTTPLocation	= local.stDPInfo.sURL,
					iHTTPRange		= 20000
					) />
				
				<cfset stReturn.stAnalyze[ local.qFiles.dp_id ] = local.stAnalyze />
				
				<!--- add to the mediaitems library ... --->
				<cfif local.stAnalyze.result>
					
					<!---
						
						add as mediaitem library item ...
						set the primary source to dropbox
						
						--->
						
					<cfset local.stMetainfo = local.stAnalyze.stParse.metainformation />
					
					<!--- primary source = dp --->
					<cfset local.stMetainfo.storagetype = application.const.I_STORAGE_TYPE_DROPBOX />
					<cfset local.stMetainfo.source = 'dp' />
						
					<cfset local.stInsert = application.beanFactory.getBean( 'MediaItemsComponent' ).addMediaItemMetaInfoToLibrary(
							securitycontext 	= local.stSecContext[ local.qFiles.user_ID ],
							metainformation		= local.stMetainfo,
							hashvalue			= local.qFiles.pathhash							
							) />
							
					<cfset stReturn.stInsert[ local.qFiles.dp_id ] = local.stInsert />
					
				<cfelse>
				
					<cflog application="false" file="tb_dropbox_scan" log="Application" type="information" text="#local.qFiles.user_id#: FAILURE (#local.stAnalyze.error#): #local.qFiles.path#" />
						
				</cfif>				
				
				<!--- update the status --->
				<cfquery name="local.qUpdate" datasource="mytunesbutlerlogging">
				UPDATE	dropboxdata
				SET		status = 
						
						<cfif local.stAnalyze.result>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_ANALYZED#" />
						<cfelse>
							<cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_DROPBOX_FILE_STATUS_FAILED_READING#" />
						</cfif>
						
						<!--- update the meta hash value of this item --->
						<cfif local.stAnalyze.result AND local.stInsert.result>
							,metahashvalue 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.stInsert.sMetahashValue#" />
							,mediaitemkey 	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.stInsert.entrykey#" />
						</cfif>
				
				WHERE	id = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qFiles.dp_id#" />
				</cfquery>
				
			<cfelse>
				<!--- failed --->
			</cfif>
					
			
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction> --->

	<cffunction access="public" name="connectUserAccount" output="false" returntype="struct"
			hint="Return the auth URL">
		<cfargument name="stContext" type="struct" required="true" />	
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.sCallbackURL = 'http://' & cgi.SERVER_NAME & '/james/?event=service.dropbox.linkaccount.callback' />
		
		<cftry>
			<cfset local.stOauth = getDP().getAuthorisation(callBackURL = local.sCallbackURL) />
			
			<cfset stReturn.stOauth = local.stoAuth />
			
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
		<cfcatch>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, cfcatch.Message ) />
		</cfcatch>		
		</cftry>
		
	</cffunction>
	
	<cffunction access="public" name="handleDPAuthFeedback" output="false" returntype="struct"
			hint="Handle the feedback coming from dropbox">
		<cfargument name="stContext" type="struct" required="true" />
		<cfargument name="sAuthToken" type="string" required="true" />
		<cfargument name="sAuthTokenSecret" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset stReturn.stAccess = getDP().getAccessToken(
			requestToken 	= arguments.sAuthToken,
			requestSecret	= arguments.sAuthTokenSecret
			) />
			
		<cfif stReturn.stAccess.success>
			
			<cfset application.beanFactory.getBean( 'UserComponent' ).StoreExternalSiteID(
				securitycontext	= arguments.stContext,
				servicename		= application.const.S_SERVICE_DROPBOX,
				username		= stReturn.stAccess.token,
				password		= stReturn.stAccess.token_secret,
				enabled			= 0 
				) />
			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>

	<!--- clean restart --->
	<cffunction access="public" name="removeAllDropBoxData" output="false" returntype="struct"
			hint="Delete all Dropbox information (including mediaitems) for a clean restart or in case the account has been removed">
		<cfargument name="stContext" type="struct" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qSelectDelete" datasource="mytunesbutlerlogging">
		SELECT	mediaitemkey
		FROM	dropboxdata
		WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
		</cfquery>
		
		<!--- delete from mediaitems --->
		<cfloop query="local.qSelectDelete">
			
			<cfset application.beanFactory.getBean( 'MediaItemsComponent' ).RemoveItemFromLibrary(
				securitycontext = arguments.stContext,
				entrykey		= local.qSelectDelete.mediaitemkey ) />
				
		</cfloop>
		
		<!--- delete from dropboxdata --->
		<cfquery name="local.qDeleteDPItems" datasource="mytunesbutlerlogging">
		DELETE FROM	dropboxdata
		WHERE		user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
		</cfquery>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
</cfcomponent>