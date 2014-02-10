<!--- 

	various playlist functions

 --->

<cfcomponent name="mediaitmes" displayname="Playlists component" output="false" hint="Handle various playlists tasks">
	
<cfprocessingdirective pageencoding="utf-8">
<cfsetting requesttimeout="2000">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.content.playlists"> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction>

<cffunction access="public" name="getPlaylistDisplayNameData" output="false" returntype="string" hint="return name of plist">
	<cfargument name="entrykey" type="string" required="true">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'playlists.playlist', arguments.entrykey ) />
	<cfset var a_str_display = a_item.getName() />
	
	<cfif Len( a_item.getDescription() ) GT 0>
		<cfset a_str_display = a_str_display & ' (' & a_item.getDescription() & ')' />
	</cfif>
	
	<cfreturn a_str_display />

</cffunction>

<cffunction access="public" name="getRecentlyPlayedPlaylists" output="false" returntype="struct" hint="return list of recently played plists">
	<cfargument name="securitycontext" type="struct" required="true" />
	<cfargument name="maxage" type="numeric" required="false" default="21" />
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var qSelectRecentlyPlayedPlists = 0 />
	
	<cfinclude template="queries/playlists/qSelectRecentlyPlayedPlists.cfm">

	<cfset stReturn.qSelectRecentlyPlayedPlists = qSelectRecentlyPlayedPlists />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<cffunction access="public" name="SearchForPlaylists" output="false" returntype="struct" hint="search for playlists">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="search" type="string" required="true">
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#">
	<cfargument name="artist_ids" type="string" required="false" default=""
		hint="comma separated list of artists which should/can be search for (OR - clause)">
	<cfargument name="track_ids" type="string" required="false" default=""
		hint="comma separated list of tracks which can occur in the playlists">
	<cfargument name="options" type="string" required="false" default=""
		hint="options for this call">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_search_plists = 0 />
	<cfset var q_select_search_plists_artists = 0 />
	<cfset var q_select_search_plists_tracks = 0 />
	<cfset var a_friends_access_lib_keys = application.beanFactory.getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( arguments.securitycontext ) />
	
	<cfif ListLen( arguments.artist_ids ) GT 0>
		<cfinclude template="queries/playlists/q_select_search_plists_artists.cfm">
		
		<cfset stReturn.q_select_search_plists_artists = q_select_search_plists_artists />
	</cfif>
	
	<cfif ListLen( arguments.track_ids ) GT 0>
		<cfinclude template="queries/playlists/q_select_search_plists_tracks.cfm">
	</cfif>

	<cfinclude template="queries/playlists/q_select_search_plists.cfm">
	
	<cfset stReturn.q_select_search_plists = q_select_search_plists />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="GetAllPlayablePlaylistForUser" output="false" returntype="struct" hint="return all plists available to the user">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="options" type="string" default="" required="false"
		hint="options for this call">
	<cfargument name="calculateitems" type="boolean" default="true" required="false"
		hint="calculate the number of items?">
	<cfargument name="orderby" type="string" default="" required="false"
		hint="order by which col?">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_cmp_items = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	<cfset var a_str_librarykeys = a_cmp_items.GetAllPossibleLibrarykeysForLibraryAccess( arguments.securitycontext ) />
	<cfset var a_prop_map = StructNew() />
	<cfset var a_data = 0 />
	<cfset var a_filter = StructNew() />
	
	<cfif ListFindNoCase( arguments.options, 'includetemporary' )>
		<cfset a_filter.includetemporary = true />
	</cfif>
	
	<cfset a_data = a_cmp_items.GetUserContentData( type = 'playlists',
								securitycontext = arguments.securitycontext,
								librarykeys = a_str_librarykeys,
								filter = a_filter,
								calculateitems = arguments.calculateitems ) />
	
	<cfset stReturn.q_select_all_accessable_playlists_for_user = a_data.q_select_items />
	
	<cfquery name="stReturn.q_select_all_accessable_playlists_for_user" dbtype="query">
	SELECT
		*,UPPER(name) AS uppername
	FROM
		stReturn.q_select_all_accessable_playlists_for_user
	WHERE
		(
			(itemcount > 0)
			OR
			(dynamic = 1)
		) 
	ORDER BY
		weight,
		lasttime DESC,
		uppername
	;
	</cfquery>
	
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

</cffunction>

<cffunction access="public" name="AddItemToPlaylist" output="false" returntype="struct"
		hint="add an item to the given playlist and return the new entrykey">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="playlistkey" type="string" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="dupcheck" type="boolean" required="false" default="false"
		hint="make a dup check?">
	<cfargument name="updateplistcount" type="boolean" required="false" default="true"
		hint="update playlist count">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_new_item = oTransfer.new( 'playlists.playlist_item' ) />
	<cfset var q_select_max_playlist_orderno = 0 />
	<cfset var a_bol_check = (Len(arguments.playlistkey) GT 0 AND Len(arguments.mediaitemkey) GT 0) />
	<cfset var a_entrykey = CreateUUID() />
	<cfset var a_str_plist_ownerkey = GetOwnerUserkeyOfPlaylist( arguments.playlistkey ) />
	<cfset var a_cmp_media = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	<cfset var a_mediaitem = a_cmp_media.GetSimpleMediaItemInfo( arguments.mediaitemkey ) />
	
	<cfif NOT a_bol_check>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<!--- perform a security check --->
	<cfif arguments.securitycontext.entrykey NEQ a_str_plist_ownerkey>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<!--- make sure librarykey is given --->
	<cfif Len( arguments.librarykey ) IS 0>
		<cfset arguments.librarykey = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- check for a duplicate? --->
	<cfif arguments.dupcheck>
		<cfinclude template="queries/playlists/q_select_playlist_item_already_exists.cfm">
		
		<cfif q_select_playlist_item_already_exists.count_exists NEQ 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
		</cfif>
	</cfif>
	
	<!--- get max no --->
	<cfinclude template="queries/playlists/q_select_max_playlist_orderno.cfm">

	<cfset a_new_item.setLibrarykey( arguments.librarykey ) />
	<cfset a_new_item.setMediaItemkey( arguments.mediaitemkey ) />
	<cfset a_new_item.setplaylistkey( arguments.playlistkey ) />
	<cfset a_new_item.setEntrykey( a_entrykey ) />
	<cfset a_new_item.setorderno( Val( q_select_max_playlist_orderno.max_orderno ) + 1 ) />
	<cfset a_new_item.setdt_added( Now() ) />
	
	<cfset a_new_item.setMediaItemId( a_cmp_media.getMediaItemIDByEntrykey( arguments.mediaitemkey )) />
	<cfset a_new_item.setPlaylistId( getPlaylistIdByEntrykey( arguments.playlistkey ) ) />
	
	<cfset oTransfer.save( a_new_item ) />
	
	<!--- update plist count? --->
	<cfif arguments.updateplistcount>
		<cfset UpdatePlaylistItemsCount( entrykey = arguments.playlistkey ) />
		
	</cfif>
	<!--- <cfset a_cmp_log.LogAction( securitycontext = arguments.securitycontext,
						action = 101,
						linked_objectkey = arguments.playlistkey,
						objecttitle = arguments.name,
						private = 0) /> --->
						
	<!--- fire strands event --->
	<!--- <cfset application.beanFactory.getBean( 'MyStrandsComponent' ).InsertStrandsEvent( mediaitemkey = arguments.mediaitemkey,
					action = 3,
					itemtype = 0,
					dt_action = Now(),
					username = arguments.securitycontext.username,
					unique_identifier = getHashValueArtistTrack( a_mediaitem.getArtist(), a_mediaitem.getName()) ) />	 --->					
	
	<cfset stReturn.entrykey = a_entrykey />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="getPlaylistIdByEntrykey" output="false" returntype="numeric">
	<cfargument name="entrykey" type="string" required="true" />
	
	<cfset var qSelect = 0 />
	
	<cfquery name="qSelect" datasource="mytunesbutleruserdata">
	SELECT	id
	FROM	playlists
	WHERE	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#" />
			;
	</cfquery>
	
	<cfreturn Val( qSelect.id ) />
	
</cffunction>


<cffunction access="public" name="DeletePlaylistitems" output="false" returntype="struct"
		hint="delete an item of a playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykeys" type="string" required="true"
		hint="entrykey of items in the playlist (NOT the mediaitemkey, one item might be stored several times!)">		
	<cfargument name="playlistkey" type="string" required="true"
		hint="entrykey of playlist">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_delete_playlist_items = 0 />
	<cfset var a_str_plist_ownerkey = GetOwnerUserkeyOfPlaylist( arguments.playlistkey ) />
	
	<cfif a_str_plist_ownerkey NEQ arguments.securitycontext.entrykey>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<cfinclude template="queries/playlists/q_delete_playlist_items.cfm">
	
	<!--- update item counter --->
	<cfset UpdatePlaylistItemsCount( entrykey = arguments.playlistkey ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="UpdatePlaylistItemsCount" output="false" returntype="void"
		hint="Update number of items of a given playlist">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of playlist">
	<cfargument name="bUpdateSEOURL" type="boolean" default="true" required="false"
		hint="update the SEO friendly URL of this plist as well?" />
			
	<cfset var q_update_plist_item_count_totaltime = 0 />
	<cfset var q_select_playlist_items = 0 />
	<cfset var q_select_playlist_items_1 = 0 />
	<cfset var q_select_playlist_items_own = 0 />
	<cfset var q_select_sum = 0 />
	
	<cfinclude template="queries/playlists/q_update_plist_item_count_totaltime.cfm">
	
	<!--- update SEO URL --->
	<cfif arguments.bUpdateSEOURL>
		<cfset application.beanFactory.getBean( 'SEO' ).generateLatestPlaylistURL( sPlistKey = arguments.entrykey ) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="DeletePlaylist" output="false" returntype="struct"
		hint="delete a playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey if edit operation">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_delete_playlist = 0 />
	<cfset var a_cmp_media = application.beanFactory.getBean( 'MediaitemsComponent' ) />
	
	<cfinclude template="queries/q_delete_playlist.cfm">
	
	<cfset a_cmp_media.UpdateCountInformation( userkey = arguments.securitycontext.entrykey, type = 'playlists' ) />
	
	<!--- delete SEO --->
	<cfset application.beanFactory.getBean( 'SEO' ).deletePlistURL( arguments.entrykey ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="ClearPlaylistItems" output="false" returntype="struct"
		hint="delete all items from a given playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="playlistkey" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_plist = getSimplePlaylistInfo( playlistkey = arguments.playlistkey ) />
	<cfset var q_delete_clean_playlist_items = 0 />
	
	<cfif NOT a_struct_plist.result>
		<cfreturn a_struct_plist />
	</cfif>
	
	<!--- sec check --->
	<cfif NOT a_struct_plist.q_select_simple_plist_info.userkey IS arguments.securitycontext.entrykey>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<!--- call delete query --->
	<cfinclude template="queries/playlists/q_delete_clean_playlist_items.cfm">
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="getSimplePlaylistInfo" output="false" returntype="struct"
		hint="Return simple plist information without any further checks">
	<cfargument name="playlistkey" type="string" required="true" />
	<cfargument name="loaditems" type="boolean" default="true" required="false"
		hint="load playlist items as well">
	<cfargument name="loaduserinfo" type="boolean" default="false" required="false"
		hint="load playlist items as well" />
	<cfargument name="bIgnoreUnIdentifiedTracks" type="boolean" default="false" required="false"
		hint="ignore tracks which cannot be identified (e.g. no musicbrainz ID)" />
	<cfargument name="bReplaceTrackinfoWithMBInfo" type="boolean" default="false" required="false"
		hint="use the musicbrainz information instead of the information by the user" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_items = 0 />
	<cfset var q_select_simple_plist_items = 0 />
	<cfset var q_select_simple_plist_items_collect = 0 />
	<cfset var q_select_simple_plist_info = 0 />
	
	<cfinclude template="queries/playlists/q_select_simple_plist_info.cfm">
	
	<!--- does not exist --->
	<cfif q_select_simple_plist_info.recordcount IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002) />
	</cfif>
	
	<!--- return plist --->
	<cfset stReturn.q_select_simple_plist_info = q_select_simple_plist_info />
	
	<!--- return user info --->
	<cfif arguments.loaduserinfo>
		<cfset stReturn.a_user_info = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = q_select_simple_plist_info.userkey ) />
	</cfif>
	
	<!--- return items --->
	<cfif arguments.loaditems>
		<cfinclude template="queries/playlists/q_select_simple_plist_items.cfm">
		
		<cfset stReturn.q_select_items = q_select_simple_plist_items />
	</cfif>

	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn) />

</cffunction>

<cffunction access="public" name="ReturnPlaylistItems" output="false" returntype="struct"
		hint="return the playlist items for the given playlist">
	<cfargument name="securitycontext" type="struct" required="true" />
	<cfargument name="playlistkey" type="string" required="true" />
	<cfargument name="maxrows" type="numeric" default="0" required="false"
		hint="max number of items to return, 0 = all" />
	<cfargument name="options" type="string" required="false" default=""
		hint="comma separated list of options" />
	<cfargument name="preview" type="boolean" required="false" default="false"
		hint="generate a preview version of this file?" />

	<cfset var stFilter = StructNew() />
	<cfset var a_check_access = 0 />
	<cfset var q_select_items = 0 />
	<cfset var a_struct_get_data = 0 />
	<cfset var a_struct_playlist = 0 />
	<cfset var a_str_orderby = '' />
	<cfset var a_struct_security_context = arguments.securitycontext />
	<cfset var a_bol_access_allowed = false />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = 0 />
	<cfset var a_plist = 0 />
	<cfset var a_str_plist_ownerkey = '' />
	<cfset var a_cmp_mediaitems = application.beanFactory.getBean( 'MediaitemsComponent' ) />
	<cfset var a_bol_is_virtual_plist = application.udf.IsVirtualPlaylist( arguments.playlistkey) />
	<cfset var a_str_options = '' />
	<cfset var stDynamicItems = {} />
	
	<!--- check for existance --->
	<cfif NOT a_bol_is_virtual_plist>
	
		<cfset oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset a_plist = oTransfer.get( 'playlists.playlist', arguments.playlistkey ) />
		<cfset a_str_plist_ownerkey = a_plist.getUserkey() />
		
		<!--- does not exist? --->
		<cfif NOT a_plist.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002 ) />
		</cfif>
		
	</cfif>
	
	<!--- filter by the given playlist entrykey and maybe by the userkey (e.g. every user has a virtual playlist called "TOPRATED" )--->
	<cfset stFilter.entrykeys = arguments.playlistkey />
	
	<!--- include temporary items as well (so called ad hoc playlists) --->
	<cfset stFilter.includetemporary = true />
	
	<!--- we have to load a different security context for this request ... check if everything is OK --->
	<cfif NOT a_bol_is_virtual_plist AND (arguments.securitycontext.entrykey NEQ a_str_plist_ownerkey)>
		
		<!--- check access 
		
			we have several possibilites:
			
			- playlist is private
			- user has set privacy to a mode that does not allow this
			- user is in the wrong country (IP)
		
		--->
		<cfset a_check_access = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(entrykey = arguments.playlistkey,
							securitycontext = arguments.securitycontext,
							type = 'playlist',
							action = 'play',
							ip = cgi.REMOTE_ADDR ) />
							
		<cfif NOT a_check_access.result>
			<cfreturn a_check_access />
		</cfif>
							
		<cfset stReturn.a_check_access = a_check_access />
		
		<!--- option: only allow identified tracks --->
		<cfset a_str_options = 'identifiedtracksonly' />
		
		<!--- perform loading ... load securitycontext of the playlist owner --->
		<cfset a_struct_security_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = a_str_plist_ownerkey ) />
	</cfif>
	
	<cfset a_str_options = ListAppend( a_str_options, 'notimesaccessed,norating' ) />
	
	<!--- load data --->
	<cfset a_struct_playlist = a_cmp_mediaitems.GetUserContentData(
				securitycontext = a_struct_security_context,
				librarykeys 	= '',
				filter 			= stFilter,
				type 			= 'playlists',
				options 		= a_str_options
				) />
										
	<cfif NOT a_struct_playlist.result OR a_struct_playlist.q_select_items.recordcount IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- return the playlist --->
	<cfset stReturn.plist_info = a_struct_playlist />
	
	<!--- load meta info only or the whole data (items?) --->
	<cfif ListFindNoCase( arguments.options, 'metainfoonly' ) IS 0>
	
		<!--- get all items from this playlist --->
		<cfset StructClear( stFilter ) />
		
		<!--- IDs of this playlist (list of IDs of mediaitems, useless for dynamic playlists) --->
		<cfset stFilter.ids = a_struct_playlist.q_select_items.items />
		
		<!--- dynamic items? --->
		<cfif a_struct_playlist.q_select_items.dynamic IS 1>
		
			<!--- check the source ... is it a local source or remote source? --->
			<cfswitch expression="#a_struct_playlist.q_select_items.source_service#">
				<cfcase value="#application.const.I_STORAGE_TYPE_SOUNDCLOUD#">
					
					<!--- load tracks from soundcloud --->
					
					<!--- check cache first --->
					
				</cfcase>
			</cfswitch>

			<cfset stDynamicItems = a_cmp_mediaitems.GetDynamicPlaylistItems( securitycontext = arguments.securitycontext,
						playlistkey = arguments.playlistkey,
						criteria = a_struct_playlist.q_select_items.dynamic_criteria,
						order = '1' ) />
						
			<!--- filter for the given ids --->
			<cfif stDynamicItems.result>
				<cfset stFilter.ids = ValueList( stDynamicItems.q_select_dynamic_playlist_items.id ) />
			</cfif>
		
		</cfif>
		
		<!--- order by ... --->
		<cfswitch expression="#arguments.playlistkey#">
			<cfcase value="toprated">
				<!--- rating --->
				<cfset a_str_orderby = 'RATING' />
			</cfcase>
			<cfcase value="recentlyadded">
				<!--- created --->
				<cfset a_str_orderby = 'CREATED' />
			</cfcase>
			<cfcase value="recentlyplayed">
				<cfset a_str_orderby = 'RECENTLYPLAYED' />
			</cfcase>
			<cfcase value="followstream">
				<cfset a_str_orderby = 'RECENTLYPLAYED' />
			</cfcase>
			<cfdefaultcase>
				
				<!--- default case ... dynamic = randomize --->
				<cfif a_struct_playlist.q_select_items.dynamic IS 1>					
					<cfset a_str_orderby = 'RANDOMIZE' />					
				<cfelse>							
					<!--- order by the order the user has set --->
					<cfset a_str_orderby = 'ORDERBYPLAYLISTORDER' />
					<cfset stFilter.iOrderPlistID = a_plist.getID() />				
				</cfif>
				
			</cfdefaultcase>
		</cfswitch>
		
		<!--- deliver the playlistkey as info to the request --->
		<cfset stFilter.info_playlistkey = arguments.playlistkey />
		<cfset stFilter.fields = 'id,entrykey,userkey,album,artist,genre,name,yr,librarykey,totaltime,rating,tracknumber,mb_albumid,mb_artistid,mb_trackid,customartwork' />

		<!--- get content (using the securitycontext of the owner of the plist) --->
		<cfset a_struct_get_data = a_cmp_mediaitems.GetUserContentData( securitycontext = a_struct_security_context,
														librarykeys = a_cmp_mediaitems.GetAllPossibleLibrarykeys( a_struct_security_context ),
														type = 'mediaitems',
														filter = stFilter,
														orderby = a_str_orderby,
														maxrows = arguments.maxrows,
														options = 'notimesaccessed,norating') />

		<cfset q_select_items = a_struct_get_data.q_select_items />
			
		<!--- set the items --->
		<cfset stReturn.q_select_items = a_struct_get_data.q_select_items  />
		
		<!---
			define ownDataOnly: if we've loaded it from a different user, that's not true, apply false!
			
			TRUE is true only for the user owning the playlist but not for the current user
			calling for action
			--->
		<cfif a_struct_security_context.entrykey NEQ arguments.securitycontext.entrykey>
			<cfset a_struct_get_data.bOnlyOwnItems = false />
		</cfif>
		
		<!--- ownership control ... do we have only items only? --->
		<cfset stReturn.bOnlyOwnItems = a_struct_get_data.bOnlyOwnItems />
		
		<!--- generate licencing permission information for this playlist ... for the requesting user --->
		<cfset stReturn.stLicencePermissions = application.beanFactory.getBean( 'LicenceComponent' ).applyLicencePermissionsToRequest(
					 securitycontext = arguments.securitycontext,
					 sRequest = 'PLAYLIST',
					 bOwnDataOnly = a_struct_get_data.bOnlyOwnItems  ) />
				
				
		<!--- log this access? --->
		<cfif ListFindNoCase( arguments.options, 'logaccess' ) GT 0>
			<cfset application.beanFactory.getBean( 'LogComponent' ).LogMediaItemLastAccess( securitycontext = arguments.securitycontext, itemkey = arguments.playlistkey, itemtype = 1 ) />
		</cfif>
		
		
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="RemovePlaylistLink" output="false" returntype="struct"
		hint="remove a linked plist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="playlistkey" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_map = { playlistkey = arguments.playlistkey, createdbyuserkey = arguments.securitycontext.entrykey } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'playlists.linked_playlists', a_map ) />
	
	<cfif a_item.getIsPersisted()>
		<cfset oTransfer.delete( a_item ) />
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="LinkPlaylisttoLibrary" output="false" returntype="struct"
		hint="create a link to a playlist">
	<cfargument name="playlistkey" type="string" required="true">
	<cfargument name="playlistuserkey" type="string" required="true">
	<cfargument name="securitycontext" type="struct" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_map = { playlistkey = arguments.playlistkey, createdbyuserkey = arguments.securitycontext.entrykey } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'playlists.linked_playlists', a_map ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var a_playlist = oTransfer.get( 'playlists.playlist', arguments.playlistkey ) />
	
	<!--- already linked? --->
	<cfif a_item.getIsPersisted() OR NOT a_playlist.getispersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>

	<cfset a_item.setEntrykey( a_str_entrykey ) />
	<cfset a_item.setcreatedByUserkey( arguments.securitycontext.entrykey ) />
	<cfset a_item.setPlaylistKey( arguments.playlistkey ) />
	<cfset a_item.setPlaylist_ID( a_playlist.getID() ) />
	<cfset a_item.setPlaylistUserKey( arguments.playlistuserkey ) />
	<cfset a_item.setdt_created( Now() ) />
	<cfset oTransfer.save( a_item ) />
	
	<!--- log this action --->
	<cfset application.beanFactory.getBean( 'LogComponent' ).LogAction( securitycontext = arguments.securitycontext,
					action = 110,
					linked_objectkey = arguments.playlistkey,
					objecttitle = a_playlist.getName(),
					private = 0) />	

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="getLinkedPlaylists" output="false" returntype="query"
		hint="return the linked playlists">
	<cfargument name="securitycontext" type="struct" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var q_select_linked_playlists = oTransfer.listByProperty( 'playlists.linked_playlists', 'createdbyuserkey', arguments.securitycontext.entrykey ) />
	
	<cfreturn q_select_linked_playlists />

</cffunction>


<cffunction access="public" name="GetOwnerUserkeyOfPlaylist" output="false" returntype="string">
	<cfargument name="playlistkey" type="string" required="true">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item =  oTransfer.get( 'playlists.playlist', arguments.playlistkey ) />
	
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn '' />
	<cfelse>
		<cfreturn a_item.getUserkey() />
	</cfif>
	
</cffunction>

<cffunction access="public" name="SimplePlaylistEdit" output="false" returntype="struct"
		hint="simple update feature">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" required="true">
	<cfargument name="data" type="struct" required="true"
		hint="update data">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_map = { userkey = arguments.securitycontext.entrykey, entrykey = arguments.entrykey } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'playlists.playlist', a_map ) />
	
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<!--- always update lastmodified --->
	<cfset a_item.setdt_lastmodified( Now() ) />
	
	<cfif StructKeyExists( arguments.data, 'imageset' )>
		<cfset a_item.setimageset( Val(arguments.data.imageset) ) />
	</cfif>
	
	<!--- licence type of image --->
	<cfif StructKeyExists( arguments.data, 'licence_type_image' )>
		<cfset a_item.setlicence_type_image( Val(arguments.data.licence_type_image) ) />
	</cfif>
	
	<!--- link to original source --->
	<cfif StructKeyExists( arguments.data, 'licence_image_link' )>
		<cfset a_item.setlicence_image_link( Trim(arguments.data.licence_image_link) ) />
	</cfif>		
	
	<cfset oTransfer.save( a_item ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

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
	<cfargument name="public" type="numeric" default="0" required="false"
		hint="Is this playlist public or not?">
	<cfargument name="additems" type="string" default="" required="false"
		hint="list of entrykeys to add to this new playlist">
	<cfargument name="iSource_Service" type="numeric" default="#application.const.I_STORAGE_TYPE_TB_CLOUD#" required="false"
		hint="The source of this playlist" />
	<cfargument name="sExternal_identifier" type="string" default="" required="false"
		hint="The identifier on the other service" />

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_bol_already_exists = false />
	<cfset var a_str_existing_entrykey = '' />
	<cfset var a_new_item = oTransfer.get( 'playlists.playlist', arguments.entrykey ) />
	<cfset var a_cmp_log = application.beanfactory.getBean( 'LogComponent' ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var a_cmp_media = application.beanFactory.getBean( 'MediaitemsComponent' ) />
	<!--- create OR edit? --->
	<cfset var a_bol_create_operation = NOT a_new_item.getIsPersisted() />
	<cfset var a_str_mediaitemkey = '' />
	
	<cfif Len( arguments.librarykey ) IS 0>
		<cfset arguments.librarykey = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- in case of create, check if a playlist with the same name exists --->
	<cfif a_bol_create_operation>
		
		<!--- do not allow a list with empty names --->
		<cfif Len( arguments.name ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
		</cfif>
		
		<!--- does a plist with the same name already exist? --->
		<cfset a_str_existing_entrykey = PlaylistExists(
				userkey 				= arguments.securitycontext.entrykey,
				name 					= arguments.name,
				librarykey 				= arguments.librarykey,
				iSource_Service			= arguments.iSource_Service,
				sExternal_identifier	= arguments.sExternal_identifier
				) />
										
		<cfset a_bol_already_exists = Len( a_str_existing_entrykey ) GT 0 />
	<cfelse>
		<cfset a_str_entrykey = arguments.entrykey />
	</cfif>
										
	<cfif a_bol_already_exists>
		<cfset stReturn.entrykey = a_str_existing_entrykey />
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 500) />
	</cfif>
	
	<!--- set properties --->
	<cfset a_new_item.setname( arguments.name ) />
	<cfset a_new_item.setdescription( Left( arguments.description, 250) ) />
	<cfset a_new_item.settags( arguments.tags ) />
	<cfset a_new_item.setpublic( arguments.public ) />
	<cfset a_new_item.setspecialtype( arguments.specialtype ) />
	
	<!--- create item --->
	<cfif NOT a_new_item.getIspersisted()>
		<cfset a_new_item.setentrykey( a_str_entrykey ) />
		<cfset a_new_item.setdt_created( Now() ) />
		<cfset a_new_item.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset a_new_item.setuserid( arguments.securitycontext.userid ) />
		<cfset a_new_item.setusername( arguments.securitycontext.username ) />
		<cfset a_new_item.setlibrarykey( arguments.librarykey ) />
	</cfif>
	
	<cfset a_new_item.setdt_lastmodified( Now() ) />
	<cfset a_new_item.setdynamic( arguments.dynamic ) />
	<cfset a_new_item.setistemporary( arguments.temporary ) />
	<cfset a_new_item.setsource_service( arguments.iSource_Service ) />
	<cfset a_new_item.setexternal_identifier( arguments.sexternal_identifier ) />
	
	<!--- simple key/ value paris, one by line ... --->
	<cfset a_new_item.setdynamic_criteria( arguments.dynamic_criteria ) />	
	
	<cfset oTransfer.save(a_new_item) />
	
	<!--- create log item if not temporary --->
	<cfif arguments.temporary IS 0>
		<cfset a_cmp_log.LogAction( securitycontext = arguments.securitycontext,
						action = 100,
						linked_objectkey = a_str_entrykey,
						objecttitle = arguments.name,
						private = 0) />
	</cfif>
	
	<!--- auto add items? --->
	<cfif Len( arguments.additems ) GT 0>
		
		<cfloop list="#arguments.additems#" index="a_str_mediaitemkey">
		
			<cfset AddItemToPlaylist( securitycontext = arguments.securitycontext,
							playlistkey = a_str_entrykey,
							mediaitemkey = a_str_mediaitemkey,
							librarykey = arguments.librarykey ) />
							
		</cfloop>
		
	</cfif>
	
	<cfset a_cmp_media.UpdateCountInformation( userkey = arguments.securitycontext.entrykey, type = 'playlists' ) />
	<cfset UpdatePlaylistItemsCount( entrykey = arguments.entrykey ) />
	
	<!--- update SEO URL --->
	<cfset application.beanFactory.getBean( 'SEO' ).generateLatestPlaylistURL( sPlistKey = a_str_entrykey ) />

	<!--- set the entrykey and return --->
	<cfset stReturn.entrykey = a_str_entrykey />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<cffunction access="public" name="CheckAutoAddItemToPlaylist" output="false" returntype="void"
		hint="check if we shoudl automatically add this item to a playlist, this is a feature of our uploader">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="hashvalue" type="string" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_struct_map_get_items = { userkey = arguments.securitycontext.entrykey, hashvalue = arguments.hashvalue } />
	<cfset var q_select_items = 0 />
	<cfset var q_select_old_items = 0 />
	
	<cfset q_select_items = oTransfer.listByPropertyMap( 'playlists.autoaddplist', a_struct_map_get_items ) />
	
	<!--- add the item to the really existing playlist --->
	<cfloop query="q_select_items">
		<cfset AddItemToPlaylist( securitycontext = arguments.securitycontext,
						playlistkey = q_select_items.playlistkey,
						mediaitemkey = arguments.mediaitemkey,
						librarykey = arguments.librarykey,
						dupcheck = true) />
	</cfloop>

	<!--- delete now old items --->	
	<cfquery name="q_select_old_items" datasource="mytunesbutleruserdata">
	DELETE FROM
		autoaddplist
	WHERE
		(userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
		AND
		(hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">)
	</cfquery>

</cffunction>


<cffunction access="public" name="CheckAutoAddItemToPlaylistByName" output="false" returntype="void"
		hint="check if we shoudl automatically add this item to a playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="playlistname" type="string" required="true">
	
	<cfset var a_str_playlistkey = PlaylistExists( userkey = arguments.securitycontext.entrykey,
									librarykey = arguments.librarykey,
									name = arguments.playlistname ) />
	<cfset var a_struct_create_plist = 0 />
	<!--- item not found ... create plist --->
	<cfif Len( a_str_playlistkey ) IS 0>
		
		<cfset a_struct_create_plist = CreateEditPlaylist( securitycontext = arguments.securitycontext,
						entrykey = '',
						librarykey = arguments.librarykey,
						name = arguments.playlistname,
						description = '',
						temporary = 0,
						public = 1 ) />
						
		<cfif NOT a_struct_create_plist.result>
			<cfreturn />
		</cfif>
		
		<!--- use the new entrykey --->
		<cfset a_str_playlistkey = a_struct_create_plist.entrykey />
		
	</cfif>
	
	<!--- add item --->
	<cfset AddItemToPlaylist( securitycontext = arguments.securitycontext,
					playlistkey = a_str_playlistkey,
					mediaitemkey = arguments.mediaitemkey,
					librarykey = arguments.librarykey,
					dupcheck = true) />

</cffunction>


<cffunction access="public" name="PlaylistExists" output="false" returntype="string"
		hint="Check if a playlist with this name exists - returns the UUID if found">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="name" type="string" required="true"
		hint="the name to check" />
	<cfargument name="iSource_Service" type="numeric" required="false" default="#application.const.I_STORAGE_TYPE_TB_CLOUD#"
		hint="What's the source of this plist?" />
	<cfargument name="sExternal_identifier" type="string" default="" required="false"
		hint="When doing a lookup against an external identifier" />
		
	<cfquery name="local.qPlist" datasource="mytunesbutleruserdata">
	SELECT	p.entrykey
	FROM	playlists AS p
	WHERE	p.userkey				= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#" />
			AND
			p.librarykey			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykey#" />
			AND
			p.source_service		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iSource_Service#" />
			
			<cfif Len( arguments.name ) AND Len( arguments.sExternal_identifier ) IS 0>
			AND
			p.name					= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" />
			</cfif>
			
			<cfif Len( arguments.sExternal_identifier )>
			AND
			p.external_identifier	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sExternal_identifier#" />
			</cfif>
			
	</cfquery>
		
	<cfreturn local.qPlist.entrykey />
</cffunction>

</cfcomponent>