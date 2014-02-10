<!--- 
	
	soundcloud API

 --->

<cfcomponent output="false" extends="james.cfc.content.providers.provider">
	
	<cfset variables.stSecContext = {} />
	<cfset variables.sSCClient_ID = "" />

	<cffunction access="public" name="init" returntype="any">
		<cfargument name="sSoundCloudUserkey" type="string" default="D51A8D2E-92CE-4617-B7D7D6AF797EDBA6"
			hint="All plists are stored using this user" />
		<cfargument name="sSCClient_UD" type="string" default="PQX5WshG0Fh65cO2GYQlw"
			hint="Soundcloud Client ID" />
			
		<cfset variables.stSecContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( arguments.sSoundCloudUserkey ) />
		<cfset variables.sSCClient_ID = arguments.sSCClient_UD />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="getSCUser" output="false" returntype="struct">
		<cfreturn variables.stSecContext />
	</cffunction>	
	
	<cffunction access="private" name="getSCClient_ID" output="false" returntype="string">
		<cfreturn variables.sSCClient_ID />
	</cffunction>
	
	<cffunction access="public" name="searchPlists" output="false" returntype="struct"
			hint="Search for Playlists">
		<cfargument name="sQuery" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.stResp = performAPIRequest(
			sResource	= 'playlists',
			stParams	= {
				'q' 		= arguments.sQuery,
				'filter'	= 'public',
				'limit'		= '5'}
			) />
		
		<cfif NOT local.stResp.result>
			<cfreturn local.stResp />
		</cfif>
		
		<!--- ok, store plists --->
		<cfset stReturn.aMixes = local.stResp.stData />
		
		<cfloop from="1" to="#arrayLen( stReturn.aMixes )#" index="local.ii">
			
			<cfset local.stMix = stReturn.aMixes[ local.ii ] />
			
			<cfset local.stData = {
				id				= local.stMix.id,
				duration		= local.stMix.duration,
				name			= local.stMix.title,
				description		= local.stMix.description,
				tag_list_cache	= (IsNull(local.stMix.genre) ? '' : local.stMix.genre ),
				cover_urls		= {
						original	=	(IsNull(local.stMix.artwork_url) ? '' : local.stMix.artwork_url)
					}
				}/>
			
			<!--- create plist --->
			<cftry>
				
			<cfset local.stPlist = createModifyInternalPlaylist(
				stData 			= local.stData,
				stUser			= getSCUser(),
				iSource_Service	= application.const.I_STORAGE_TYPE_SOUNDCLOUD
				) />
				
				
				<!--- clear all items --->
				
				
				<!--- create new ones --->
				<cfloop from="1" to="#ArrayLen( local.stMix.tracks )#" index="local.ii">
					
					<cfset local.stTrack = local.stMix.tracks[ local.ii ] />
					
					<cfset local.stMeta = {
						artist		= ListFirst( local.stTrack.title, '-' ),
						name		= local.stTrack.title,
						location	= local.stTrack.stream_url & '?client_id=' & UrlEncodedFormat( getSCClient_ID() ),
						album		= local.stTrack.release,
						format		= 'mp3',
						source		= 'sc',
						storagetype	= application.const.I_STORAGE_TYPE_SOUNDCLOUD,
						tracklength	= local.stTrack.duration		
						} />
						
					<!--- entrykey for the new item --->
					<cfset local.sMediaItemKey = CreateUUID() />
					
					<cfset local.stSave = application.beanFactory.getBean( 'MediaItemsComponent' ).StoreMediaItemInformation(
						librarykey		= '',
						entrykey		= local.sMediaItemKey,
						hashvalue		= Hash( local.stMeta.location ),
						originalhashvalue	= Hash( local.stMeta.location ),
						filename		= '',
						operation		= 'CREATE',
						userkey			= getSCUser().entrykey,
						metainformation	= local.stMeta				
						) />
						
					<cfset application.beanFactory.getBean( 'PlaylistsComponent' ).AddItemToPlaylist(
						securitycontext		= getSCUser(),
						playlistkey			= local.stPlist.entrykey,
						mediaitemkey		= local.sMediaItemKey,
						librarykey			= '',
						updateplistcount	= true
						) />
					
				</cfloop>
				
				
				<!--- 
					
				 --->
				
				<cfcatch type="any">
					<cfset stReturn.cfcatch = cfcatch >
				</cfcatch>
			</cftry>
			
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
		
		<cfset local.sURL = "http://api.soundcloud.com/" & arguments.sResource & "?client_id=" & UrlEncodedFormat( getSCClient_ID() ) & "&format=json" />
		
		<!--- build entire URL for easier logging --->
		<cfset local.sParams = '' />
		
		<cfloop collection="#arguments.stParams#" item="local.sItem">
			<cfset local.sParams = local.sParams & '&' & local.sItem & '=' & UrlEncodedFormat( arguments.stParams[ local.sItem ]) />
		</cfloop>
		
		<cfset local.sURL = local.sURL & local.sParams />
		
		<cftry>
		<cfhttp charset="utf-8" url="#local.sURL#" result="local.stHTTP"></cfhttp>
		
		<cfset stReturn.stData = DeSerializeJSON( local.stHTTP.FileContent ) />
		
		<cfcatch type="any">
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, cfcatch.Message ) />
		</cfcatch>
		</cftry>
		
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>

</cfcomponent>