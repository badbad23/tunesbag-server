<!--- 
	
	8tracks API
	
 --->

<cfcomponent output="false" extends="james.cfc.content.providers.provider">
	
	<cfset variables.stSecContext = {} />
	
	<cffunction access="public" name="init" output="false" returntype="any">
		<cfargument name="s8TracksUserkey" type="string" default="C3CF33D8-899D-42E5-AAB2D8501845AFB7"
			hint="All plists are stored using this user" />
		
		<cfset variables.stSecContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( arguments.s8TracksUserkey ) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="get8TracksUser" output="false" returntype="struct">
		<cfreturn variables.stSecContext />
	</cffunction>
	
	<cffunction access="public" name="searchPlists" output="false" returntype="struct"
			hint="Search for playlists. Cache results">
		<cfargument name="sTag" type="string" required="false" default="" />
		<cfargument name="sQuery" type="string" required="false" default="" />
		<cfargument name="sSortBy" type="string" required="false" default="" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.stResp = performAPIRequest(
			sResource	= 'mixes',
			stParams	= { 'q' = arguments.sQuery }
			) />
		
		<cfif NOT local.stResp.result>
			<cfreturn local.stResp />
		</cfif>
		
		<cfset stReturn.aMixes = local.stResp.stData.mixes />
		
		<!--- create tunesBag items --->
		<cfloop from="1" to="#arrayLen( stReturn.aMixes )#" index="local.ii">
			
			<cfset createModifyInternalPlaylist(
				stData 			= stReturn.aMixes[ local.ii ],
				stUser			= get8TracksUser(),
				iSource_Service	= application.const.I_STORAGE_TYPE_8TRACKS
				) />
			
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="preparePlistPlayback" output="false" returntype="struct"
			hint="Launch the playback, get a play token and start">
		<cfargument name="iMix_ID" type="numeric" required="true" />
		<cfargument name="bFirstTrack" type="boolean" required="false" default="true"
			hint="Are you requesting the first track?" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- plist items --->
		<cfset local.aItems = [] />
		
		<!--- get all tracks --->
		<cfset local.stPlayToken = performAPIRequest( sResource = 'sets/new' ) />
			
		<!--- <cfset local.stPlist = performAPIRequest(
			sResource 	= 'sets/' & local.stPlayToken.stData.play_token & '/play',
			stParams	= { 'mix_id' = arguments.iMix_ID }
			) /> --->
				
				
		<cfset local.bAtTheEnd = false />
		<cfset local.iCounter = 0 />
		
		<cfloop condition="#local.bAtTheEnd# IS false">
			
			<cfset local.iCounter = local.iCounter + 1 />
			
			<cfset local.stLoadTrack = performAPIRequest(
				sResource 	= 'sets/' & local.stPlayToken.stData.play_token & '/next',
				stParams	= { 'mix_id' = arguments.iMix_ID }
				) />
	
			<!--- ok? --->		
			<cfif local.stLoadTrack.result>
				
				<cfset ArrayAppend( local.aItems, local.stLoadTrack.stData.set ) />
				<cfset local.bAtTheEnd = local.stLoadTrack.stData.set.at_end />
			
			<cfelse>
				<!--- error --->
				<cfset local.bAtTheEnd = true />
			</cfif>
			
			
			<cfif local.iCounter GT 20>
				<cfset local.bAtTheEnd = true />
			</cfif>
		</cfloop>
		
		<!--- get plist id --->
		<cfset local.sPlistKey = application.beanFactory.getBean( 'PlaylistsComponent' ).PlaylistExists(
			userkey					= get8TracksUser().entrykey,
			librarykey				= get8TracksUser().defaultlibrarykey,
			name					= '',
			iSource_Service			= application.const.I_STORAGE_TYPE_8TRACKS,
			sExternal_identifier	= arguments.iMix_ID
			)/>
		
		<cfset stReturn.aItems = local.aItems />
		
		<!--- insert as track into the database --->
		<cfloop from="1" to="#ArrayLen( local.aItems )#" index="local.ii">
			
			<cfset local.stTrack = local.aItems[ local.ii ].track />
			
			<cfset local.stMeta = {
				artist		= local.stTrack.performer,
				name		= local.stTrack.name,
				location	= local.stTrack.url,
				album		= local.stTrack.release_name,
				format		= 'AAC',
				source		= '8t',
				storagetype	= application.const.I_STORAGE_TYPE_8TRACKS,
				tracklength	= 249		
				} />
				
			<cfset local.sMediaItemKey = CreateUUID() />
				
			<cfset local.stSave = application.beanFactory.getBean( 'MediaItemsComponent' ).StoreMediaItemInformation(
				librarykey		= '',
				entrykey		= local.sMediaItemKey,
				hashvalue		= Hash( local.stMeta.location ),
				originalhashvalue	= Hash( local.stMeta.location ),
				filename		= '',
				operation		= 'CREATE',
				userkey			= get8TracksUser().entrykey,
				metainformation	= local.stMeta				
				) />
				
			<cfset stREturn.stAdd[ local.ii ] = local.stSave>
			
			<cfset application.beanFactory.getBean( 'PlaylistsComponent' ).AddItemToPlaylist(
				securitycontext		= get8TracksUser(),
				playlistkey			= local.sPlistKey,
				mediaitemkey		= local.sMediaItemKey,
				librarykey			= '',
				updateplistcount	= true
				) />
				
		</cfloop>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
	<cffunction access="private" name="performAPIRequest" output="false"
			hint="Perform API request">
		<cfargument name="sResource" type="string" required="true" />
		<cfargument name="stParams" type="struct" required="false" default="#StructNew()#"
			hint="Params to add" />
		<cfargument name="iCacheMin" type="numeric" required="false" default="0"
			hint="Cache result for some time" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cftry>
			
			<!--- build entire URL for easier logging --->
			<cfset local.sParams = '' />
			
			<cfloop collection="#arguments.stParams#" item="local.sItem">
				<cfset local.sParams = local.sParams & '&' & local.sItem & '=' & UrlEncodedFormat( arguments.stParams[ local.sItem ]) />
			</cfloop>
			
			<!--- check for cached result --->
			
			
			<!--- perform http call --->
			<cfhttp charset="utf-8" result="local.stHTTP" url="http://8tracks.com/#arguments.sResource#.json?#local.sParams#" method="get">
			</cfhttp>
			
			<cfset stReturn.sURL = "http://8tracks.com/#arguments.sResource#.json?#local.sParams#">
			
			<!--- return data --->
			<cfset stReturn.stData = DeSerializeJSON( local.stHTTP.filecontent ) />
			
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
			<cfcatch type="any">
				
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, cfcatch.Message ) />
				
			</cfcatch>
		</cftry>
				
		
	</cffunction>

</cfcomponent>