<!--- search engine optimization --->

<cfcomponent displayName="remote" hint="seo engine" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.seo" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="deletePlistURL" output="false" returntype="void">
		<cfargument name="sPlistKey" type="string" required="true" />
		
		<cfset var local = {} />
		
		<cfquery name="local.qDelete" datasource="mytunesbutlercontent">
		DELETE FROM
			seo_playlist_url_latest
		WHERE
			plist_entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sPlistKey#">
		;
		</cfquery>
		
	</cffunction>
	
	<cffunction access="public" name="getLatestPlaylistURL" output="false" returntype="struct"
			hint="return the latest valid playlist URL">
		<cfargument name="iPlaylistID" type="numeric" default="0" />
		<cfargument name="sPlaylistEntrykey" type="string" default="" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<!--- load plist info --->
		<cfset var sURL = '/playlist-' />
		<cfset var qSelect = 0 />
		
		<cfquery name="qSelect" datasource="mytunesbutlercontent">
		SELECT
			href,
			plist_entrykey AS entrykey,
			plist_ID AS id
		FROM
			seo_playlist_url_latest
		WHERE
			<cfif Val( arguments.iPlaylistID ) GT 0>
				plist_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iPlaylistID#">
			<cfelseif Len( arguments.sPlaylistEntrykey ) GT 0>
				plist_entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sPlaylistEntrykey#">
			<cfelse>
				<cfthrow message="invalid call to get plist URL" />
			</cfif>
		</cfquery>
		
		
		<cfif qSelect.recordcount IS 0>
			<!--- try to generate URL --->
			
			<cfset stReturn.stInfo = generateLatestPlaylistURL( arguments.sPlaylistEntrykey ) />
			
			<!--- ok, that worked! --->
			<cfif stReturn.stInfo.result>
			
			</cfif>
			
			<!--- generateLatestPlaylistURL --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'Plist not found' ) />
		</cfif>
		
		<cfset stReturn.sURL = qSelect.href />
		<cfset stReturn.sEntrykey = qSelect.entrykey />
		<cfset stReturn.iId = qSelect.id />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
	<cffunction access="public" name="generateLatestPlaylistURL" output="false" returntype="struct"
			hint="set the latest plist URL">
		<cfargument name="sPlistKey" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var local = {} />
		<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.readByProperty( 'seo.seo_playlist_url_latest', 'plist_entrykey', arguments.sPlistKey ) />
		
		<cfset var stInfo = application.beanFactory.getBean( 'PlaylistsComponent' ).getSimplePlaylistInfo( playlistkey = arguments.sPlistKey, loaditems = true, loaduserinfo = false ) />
		
		<!--- no hit --->
		<cfif NOT stInfo.result>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'Plist not found' ) />
		</cfif>
		
		<cfset var Q_SELECT_ITEMS = stInfo.Q_SELECT_ITEMS />
		<cfset var sURL = '/playlist-' />
		
		<!--- get number of unique items --->
		<cfquery name="local.qSelectUniqueArtists" dbtype="query" maxrows="6">
		SELECT
			artist,COUNT(entrykey) AS count_items
		FROM
			Q_SELECT_ITEMS
		WHERE
			LENGTH( artist ) > 0
		GROUP BY
			artist
		ORDER BY
			count_items DESC
		;
		</cfquery>
		
		<cfset stReturn.qSelectUniqueArtists = local.qSelectUniqueArtists />
		
		<cfloop query="local.qSelectUniqueArtists">
			<cfset sURL = sURL & friendlyUrl( local.qSelectUniqueArtists.artist ) & '-' />
		</cfloop>
		
		<!--- add plist name --->
		<cfif ListLen( sURL, '-' ) LT 7>
			<cfset sURL = sURL & friendlyUrl( stInfo.q_select_simple_plist_info.name ) & '-' />
		</cfif>
		
		<!--- remove duplicates --->
		
		<!--- add ID at the end --->
		<cfset sURL = sURL & 'p' & stInfo.q_select_simple_plist_info.id />
		
		<!--- build URL --->
		<cfset stReturn.sURL = sURL />
		
		<!--- store ... --->
		<cfset oItem.setHref( sURL ) />
		<cfset oItem.setRevision( Val( oItem.getRevision() ) + 1 ) />
		<cfset oItem.setPlist_ID( stinfo.q_select_simple_plist_info.id ) />
		<cfset oItem.setPlist_entrykey( stinfo.q_select_simple_plist_info.entrykey ) />
		<cfset oItem.setdt_lastupdate( Now() ) />
		<cfset oTransfer.save( oItem ) />
		
		<!--- <cfset stReturn.stinfo = stInfo /> --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
	
</cfcomponent>