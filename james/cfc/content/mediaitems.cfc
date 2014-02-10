<!--- //

	Module:		Handle media items of user
	Description:These are the internal core routines called by the mach-ii components
	
// --->

<cfcomponent name="mediaitmes" displayname="Media items component" output="false" hint="Handle media items">
	
<cfprocessingdirective pageencoding="utf-8">
<cfsetting requesttimeout="2000">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.content.mediaitems"> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction>

<cffunction access="public" name="SetAnalyzeMBDataForTrack" output="false" returntype="void">
	<cfargument name="mbArtistID" type="numeric" required="true">
	<cfargument name="mbAlbumID" type="numeric" required="true">
	<cfargument name="mbTrackID" type="numeric" required="true">
	<cfargument name="mbMatchlevel" type="numeric" required="false" default="0"
		hint="100 = perfect match, 90 = some seconds (plus/minus 3)..., 80 = plus/minus 10, 70 = plus/min 15, 50 = names, but not length, 0 = no match (default)">
	<cfargument name="item" type="any" hint="database item" required="true">
	<cfargument name="transfer" type="any" required="true" hint="transfer object">
	
	<cfset item.setmb_artistid( arguments.mbartistid ) />
	<cfset item.setmb_albumid( arguments.mbAlbumID ) />
	<cfset item.setmb_trackid( arguments.mbTrackID ) />
	<cfset item.setmb_matchlevel( arguments.mbMatchlevel ) />
	
	<!--- analyzed! --->
	<cfset item.setanalyzed( 1 ) />
	
	<cfset transfer.save( item ) />
	<cfset transfer.discardAll() />
	
</cffunction>

<cffunction access="public" name="GetLibrariesLastKeys" output="false" returntype="query">
	<cfargument name="librarykeys" type="string" required="true">
	
	<cfset var q_select_lastkeys = 0 />

	<cfinclude template="queries/libraries/q_select_lastkeys.cfm">
	
	<cfreturn q_select_lastkeys />
</cffunction>

<cffunction access="public" name="GetLibraryLastkey" output="false" returntype="string">
	<cfargument name="librarykey" type="string" required="true">
	
	<cfreturn GetLibrariesLastKeys( librarykeys = arguments.librarykey ).lastkey />
	
</cffunction>

<cffunction access="public" name="cleanUpLibraryAfterSyncSourceRemoval" output="false" returntype="struct"
		hint="A sync source has been removed, so clean up data">
	<cfargument name="stContext" type="struct" required="true" />	
	<cfargument name="sServicename" type="string" required="true" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<cfswitch expression="#arguments.sServicename#">
		<cfcase value="#application.const.S_SERVICE_DROPBOX#">
			
			<!--- remove all items with source = dp --->
			
			<cfquery name="local.qDPItems" datasource="mytunesbutleruserdata">
			SELECT	id,entrykey
			FROM	mediaitems
			WHERE	userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
					AND
					source = 'dp'
					;
			</cfquery>
			
			<!--- delete relations --->
			<cfquery name="local.qDeleteRel" datasource="mytunesbutleruserdata">
			DELETE FROM	rel_library_mediaitem
			WHERE		mediaitem_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( local.qDPItems.id )#" list="true" />)
			</cfquery>
			
			<!--- delete mediaitems --->
			<cfquery name="local.qDeleteMediaitems" datasource="mytunesbutleruserdata">
			DELETE FROM	mediaitems
			WHERE		userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
						AND
						source = 'dp'
					;
			</cfquery>			
			
			<!--- remove sync data --->
			<cfquery name="local.qDeleteDPData" datasource="mytunesbutlerlogging">
			DELETE FROM	dropboxdata
			WHERE		user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
			</cfquery>
		
		</cfcase>
	</cfswitch>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="SetLibraryLastkey" output="false" returntype="void">
	<cfargument name="librarykey" type="string" required="true">
	<cfargument name="lastkey" type="string" required="true"
		hint="the lastkey (for sync operations)">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'libraries.library', arguments.librarykey ) />
	
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn />
	</cfif>
	
	<cfset a_item.setlastkey( arguments.lastkey ) />
	<cfset oTransfer.save( a_item ) />

</cffunction>


<cffunction access="public" name="GetSimpleMediaItemInfo" output="false" returntype="any"
		hint="return simple info about media item by it's entrykey">
	<cfargument name="entrykey" type="string" required="true" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfreturn oTransfer.readByProperty( 'mediaitems.mediaitem', 'entrykey', arguments.entrykey ) />
	
</cffunction>

<cffunction access="public" name="UpdateCountInformation" output="false" returntype="void"
		hint="update counter for mediaitems or playlists">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="type" type="string" required="true" hint="library or playlists">
	
	<cfset var q_select_items_count = 0 />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.readByProperty( 'users.user', 'entrykey', arguments.userkey ) />
	<cfset var qSelectSize = 0 />
	
	<cfinclude template="queries/stat/q_select_items_count.cfm">
	
	<cfif a_item.getisPersisted()>
	
		<cfif arguments.type IS 'library'>
			<cfset a_item.setlibraryitemscount( q_select_items_count.count_items ) />
		<cfelse>
			<cfset a_item.setplaylistscount( q_select_items_count.count_items ) />
		</cfif>	
		
		<cfset a_item.setlibraryitemstotalsize( Val( qSelectSize.size_total )) />
		<cfset oTransfer.save( a_item ) />	
	
	</cfif>

</cffunction>

<cffunction access="public" name="GetDistinctAvailableGenres" output="false" returntype="struct" hint="return all distinct genres a user has access to">
	<cfargument name="securitycontext" type="struct" required="true">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_librarykeys = GetAllPossibleLibrarykeysForLibraryAccess( arguments.securitycontext ) />
	<cfset var q_select_distinct_available_genres = 0 />
	
	<cfinclude template="queries/q_select_distinct_available_genres.cfm">
	
	<cfset stReturn.q_select_distinct_available_genres = q_select_distinct_available_genres />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction name="GetLibraryInformation" access="public" output="false" returntype="struct" hint="Return a certain library (query)">
	<cfargument name="librarykey" type="string" required="true"
		hint="entrykey of the library">
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = 0 />
	
	<cfif Len( arguments.librarykey ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 999 ) />
	</cfif>
	
	<cfset a_item = oTransfer.get( 'libraries.library', arguments.librarykey ) />
	
	<cfif Len(a_item.getName()) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 999 ) />
	</cfif>
	
	<!--- return the item --->
	<cfset stReturn.a_item = a_item />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>


<cffunction access="public" name="GetUserContentData" output="false" returntype="struct" hint="internal function to load data">
	<cfargument name="librarykeys" type="string" required="true">
	<cfargument name="lastkey" type="string" required="false" default="">
	<cfargument name="type" type="string" default="mediaitems"
		hint="what kind of data should we return?">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#"
		hint="various filter expressions">
	<cfargument name="orderby" type="string" default="" required="false"
		hint="order by ...">
	<cfargument name="calculateitems" type="boolean" required="false" default="true"
		hint="receive the detailled data, e.g. the number of items of a playlist">
	<cfargument name="maxrows" type="numeric" default="0" required="false"
		hint="max number of items to return">
	<cfargument name="options" type="string" required="false" default=""
		hint="various options to pass to this function">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
	<!--- librarykey provided? --->
	<cfif Len( arguments.librarykeys ) IS 0>
		<cfset arguments.librarykeys = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="playlists">
			
			<cfreturn GetUserContentDataPlaylists( securitycontext = arguments.securitycontext,
								filter = arguments.filter,
								librarykeys = arguments.librarykeys,
								calculateitems = arguments.calculateitems,
								orderby = arguments.orderby,
								maxitems = arguments.maxrows,
								options = arguments.options ) />
		</cfcase>
		<cfcase value="mediaitems">
			<cfreturn GetUserContentDataMediaItems(securitycontext = arguments.securitycontext,
								librarykeys = arguments.librarykeys,
								lastkey = arguments.lastkey,
								filter = arguments.filter,
								orderby = arguments.orderby,
								maxrows = arguments.maxrows,
								options = arguments.options ) />
		</cfcase>
	</cfswitch>
	
</cffunction>

<!--- <cffunction access="public" name="AddTemporaryItemToOwnLibrary" output="false" returntype="struct"
		hint="add a temporary item to the own library">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="librarykey" type="string" required="false" default="">
	<cfargument name="temporarykey" type="string" required="true">
	<cfargument name="source" type="string" required="true" default="yt"
		hint="where does the item come from? yt = YouTube">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_yt_item = 0 />
	<cfset var a_yt_item = 0 />
	<cfset var a_cmp_yt = application.beanFactory.getBean( 'YouTubeComponent' ) />
	<cfset var a_struct_add_item = 0 />
	<cfset var stMetaInfo = 0 />
	
	<cfif Len( arguments.librarykey ) IS 0>
		<cfset arguments.librarykey = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- check where the temporary item does come from ... --->
	<cfswitch expression="#arguments.source#">
		<cfcase value="yt">
				<!--- load temporary information --->
			<cfset a_struct_yt_item = a_cmp_yt.GetTemporaryYTItemInformation( entrykey = arguments.temporarykey,
													securitycontext = arguments.securitycontext ) />
			
			<cfif a_struct_yt_item.result>
			
				<!--- return structure --->
				<cfset a_yt_item = a_struct_yt_item.a_yt_item />
				
				<cfset stMetaInfo = StructNew() />
				<cfset stMetaInfo.artist = a_yt_item.GetArtist() />
				<cfset stMetaInfo.name = a_yt_item.GetName() />
				<cfset stMetaInfo.genre = 'MusicVideo' />
				<cfset stMetaInfo.album = 'MusicVideo' />
				
				<!--- store the --->
				<cfset stMetaInfo.location = a_yt_item.GetPageLink() />
				<cfset stMetaInfo.yr = Year( a_yt_item.Getdt_created() ) />
				<cfset stMetaInfo.size = 0 />
				
				<!--- link only ... --->
				<cfset stMetaInfo.storagetype = 2 />
				
				<!--- source = youtube --->
				<cfset stMetaInfo.source = 'yt' />
				
				<cfset a_struct_add_item = AddMediaLibraryItem( securitycontext = arguments.securitycontext,
												librarykey = arguments.librarykey,
												filename = '',
												metainformation = stMetaInfo,
												type = 1) />
												
			</cfif>
			
		</cfcase>
	</cfswitch>
	
	<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
</cffunction> --->

<cffunction access="public" name="GetAllPossibleUseridsForLibraryAccess" output="false" returntype="string"
		hint="return list of userkeys for which the user has access to the libraries, including the own one!">
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var sReturn = arguments.securitycontext.userid />
	<cfset var ii = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
		<cfif arguments.securitycontext.friends[ ii ].accesslibrary IS 1>
			<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].userid ) />
		</cfif>
	</cfloop>
	
	<cfreturn sReturn />
</cffunction>



<cffunction access="public" name="GetAllFriendUserkeys" output="false" returntype="string"
		hint="return list of userkeys for which the user has access to the libraries, including the own one!">
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var sReturn = arguments.securitycontext.entrykey />
	<cfset var ii = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
		<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].userkey ) />
	</cfloop>
	
	<cfreturn sReturn />
</cffunction>

<cffunction access="public" name="GetAllPossibleUserkeysForLibraryAccess" output="false" returntype="string"
		hint="return list of userkeys for which the user has access to the libraries, including the own one!">
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var sReturn = arguments.securitycontext.entrykey />
	<cfset var ii = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
		<cfif arguments.securitycontext.friends[ ii ].accesslibrary IS 1>
			<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].userkey ) />
		</cfif>
	</cfloop>
	
	<cfreturn sReturn />
</cffunction>

<cffunction access="public" name="GetAllPossibleLibrarykeys" output="false" returntype="string"
		hint="return all possible lib keys of people where the user is a friend of">
	<cfargument name="securitycontext" type="struct" required="true" />

	<cfset var sReturn = arguments.securitycontext.defaultlibrarykey />
	<cfset var ii = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
		<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].librarykey ) />
	</cfloop>
	
	<cfreturn sReturn />
</cffunction>

<cffunction access="public" name="GetAllPossibleLibrarykeysForLibraryAccess" output="false" returntype="string"
		hint="return list of lib keys for which the user has access to the libraries, including the own one!">
	<cfargument name="securitycontext" type="struct" required="true">
	
	<cfset var sReturn = arguments.securitycontext.defaultlibrarykey />
	<cfset var ii = 0 />
	
	<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
		<cfif arguments.securitycontext.friends[ ii ].accesslibrary IS 1>
			<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].librarykey ) />
		</cfif>
	</cfloop>
	
	<cfreturn sReturn />
</cffunction>

<cffunction access="public" name="GetUserContentDataPlaylists" output="false" returntype="struct" hint="return the playlists of a library">
	<cfargument name="librarykeys" type="string" required="true"
		hint="entrykeys of the librarykeys">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#"
		hint="various filter">
	<cfargument name="calculateitems" type="boolean" required="false" default="true"
		hint="calculate the detailled item data (items)">
	<cfargument name="maxitems" type="numeric" default="300" required="false"
		hint="max number of items to return when calculating the items" />
	<cfargument name="options" type="string" required="false" default=""
		hint="options to pass to this call" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_items = 0 />
	<cfset var oTransfer = application.beanFactory.getbean( 'ContentTransfer' ).getTransfer() />
	<cfset var tmp = 0 />
	<!--- filter out temporary items? --->
	<cfset var bIncludeTemporary = StructKeyExists( arguments.filter, 'includetemporary') AND arguments.filter.includetemporary />
	<!--- own items only? --->
	<cfset var a_bol_own_items_only = StructKeyExists( arguments.filter, 'ownonly') AND (arguments.filter.ownonly IS TRUE) />
	<!--- get public profiles only? --->
	<cfset var a_bol_filter_out_private = StructKeyExists( arguments.filter, 'public_only') AND (arguments.filter.public_only IS TRUE) />
	<!--- filter for certain entrykeys? --->
	<cfset var a_bol_filter_entrykeys = StructKeyExists( arguments.filter , 'entrykeys' ) />
	<cfset var a_arr_tmp = ArrayNew( 1 ) />
	<cfset var a_bol_add_toprated = false />
	<cfset var a_bol_add_lastplayed = false />
	<cfset var a_bol_add_recentlyadded = false />
	<cfset var a_bol_add_followstream = false />
	<cfset var a_bol_add_recommendations = false />
	<cfset var a_bol_add_bag = false />
	<cfset var q_select_dynamic_playlist_items = 0 />
	<cfset var a_str_basic_sql = '' />
	<cfset var a_tsql_query = '' />
	<cfset var q_select_playlist_items = 0 />
	<cfset var a_str_default_librarykey = arguments.securitycontext.defaultlibrarykey />
	<cfset var qSelectCollect = 0 />
	
	<!--- not even RADIO allowed? reset to own librarykey only --->
	<cfif arguments.securitycontext.rights.playlist.RADIO IS 0>
		<cfset a_bol_own_items_only = true />			
	</cfif>
	
	<cfif a_bol_own_items_only>
		<cfset arguments.librarykeys = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- call qry --->
	<cfinclude template="queries/playlists/q_select_items.cfm">
	
	<!--- now add special playlists ... TOP RATED, LAST ADDED and RECENTPLY PLAYED ... check for possible filters --->
	<cfset a_bol_add_toprated = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'toprated', arguments.filter.entrykeys) GT 0)) />
	
	<cfif a_bol_add_toprated>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'plist_id', application.const.I_DEFAULT_PLIST_TOPRATED, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'toprated', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_ph_playlist_top_rated' ), q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'totaltime', 0, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'public', 0, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'systemplist', 1, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', 'Top rated items', q_select_items.recordcount) />		
	</cfif>
	
	<!--- these playlists are *not* public - they are private ... so check for the filter --->
	<cfset a_bol_add_recentlyadded = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'recentlyplayed', arguments.filter.entrykeys) GT 0)) />
	
	<cfif a_bol_add_recentlyadded>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'recentlyplayed', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'plist_id', application.const.I_DEFAULT_PLIST_RECENTLYPLAYED, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' ), q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'public', 0, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'totaltime', 0, q_select_items.recordcount) />					
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'systemplist', 1, q_select_items.recordcount) />			
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' ), q_select_items.recordcount) />		
	</cfif>
	
	<!--- add follow stream radio? --->
	<cfset a_bol_add_followstream = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'followstream', arguments.filter.entrykeys) GT 0)) />
	
	<cfif a_bol_add_followstream>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'plist_id', application.const.I_DEFAULT_PLIST_FOLLOWSTREAM, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'followstream', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_ph_playlist_followstream' ), q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'public', 0, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'systemplist', 1, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'totaltime', 0, q_select_items.recordcount) />			
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', application.udf.GetLangValSec( 'cm_ph_playlist_followstream_description' ), q_select_items.recordcount) />
	</cfif>		

	<!--- recently played --->
	<cfset a_bol_add_lastplayed = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'recentlyadded', arguments.filter.entrykeys) GT 0)) />
	
	<cfif a_bol_add_lastplayed>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'plist_id', application.const.I_DEFAULT_PLIST_RECENTLYADDED, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'recentlyadded', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_ph_playlist_recently_added' ), q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'public', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'systemplist', 1, q_select_items.recordcount) />			
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'totaltime', 0, q_select_items.recordcount) />			
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', application.udf.GetLangValSec( 'cm_ph_playlist_recently_added' ), q_select_items.recordcount) />
	</cfif>	
	
	<cfset a_bol_add_lastplayed = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'bag', arguments.filter.entrykeys) GT 0)) />
	
	<!--- <cfif a_bol_add_bag>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'bag', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_ph_playlist_bag' ), q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'weight', 1, q_select_items.recordcount) />
		<!--- this one is *not* dynamic ... --->	
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', 'Enqued items in your bag', q_select_items.recordcount) />		
	</cfif>		 --->
	
	<!--- add recomemndations? --->
	<cfset a_bol_add_recommendations = a_bol_filter_out_private IS FALSE AND ((NOT a_bol_filter_entrykeys) OR (a_bol_filter_entrykeys AND FindNoCase( 'recommendations', arguments.filter.entrykeys) GT 0)) />
	
	<cfif a_bol_add_recommendations>
		<cfset QueryAddRow(q_select_items, 1) />
		<cfset QuerySetCell(q_select_items, 'plist_id', application.const.I_DEFAULT_PLIST_RECOMMENDATIONS, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'entrykey', 'recommendations', q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'name', application.udf.GetLangValSec( 'cm_wd_recommendations' ), q_select_items.recordcount) />
		<!--- this one is *not* dynamic ... --->	
		<cfset QuerySetCell(q_select_items, 'dynamic', 1, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'itemcount', 0, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'totaltime', 0, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'systemplist', 1, q_select_items.recordcount) />		
		<cfset QuerySetCell(q_select_items, 'istemporary', 0, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'librarykey', a_str_default_librarykey, q_select_items.recordcount) />	
		<cfset QuerySetCell(q_select_items, 'userkey', arguments.securitycontext.entrykey, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'username', arguments.securitycontext.username, q_select_items.recordcount) />
		<cfset QuerySetCell(q_select_items, 'description', 'Recommendations received by friends', q_select_items.recordcount) />		
	</cfif>
	
	<!--- if needed, calculate the detailled items data ... --->
	<cfif arguments.calculateitems>
		<cfloop query="q_select_items">
			
			<!--- dynamic critera? --->
			<cfif q_select_items.dynamic IS 1>
			
				<!--- load them using our new and cool engine! --->
				<cfset q_select_dynamic_playlist_items = GetDynamicPlaylistItems( securitycontext = arguments.securitycontext,
							playlistkey = q_select_items.entrykey,
							criteria = q_select_items.dynamic_criteria ).q_select_dynamic_playlist_items />
							
				
				<!--- list all IDs --->
				<cfset QuerySetCell(q_select_items, 'items', ValueList( q_select_dynamic_playlist_items.id ), q_select_items.currentrow ) />
				
			</cfif>
				
		</cfloop>
	</cfif>
	
	<!--- re-select properly if more than 1 record --->
	<cfif q_select_items.recordcount GT 1>
		<cfquery name="q_select_items" dbtype="query">
		SELECT
			plist_ID,entrykey,name,description,weight,dt_created,librarykey,items,itemcount,imageset,dynamic,totaltime,
			dynamic_criteria,istemporary,userkey,username,tags,[public],rating,times,lasttime,lasttimedays,avgrating,
			UPPER(name) AS uppername,num_lastmodified,mb_trackidlist,systemplist,img_revision,external_identifier,source_service
		FROM
			q_select_items
		ORDER BY
			weight,
			uppername
		;
		</cfquery>
	</cfif>
		
	<!--- set return query --->
	<cfset stReturn.q_select_items = q_select_items />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>


<cffunction access="public" name="GetDynamicPlaylistItems" output="false" returntype="struct" hint="return items of a dynamic playlist">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="playlistkey" type="string" required="true">
	<cfargument name="criteria" type="string" required="true">
	<cfargument name="maxrows" type="numeric" required="false" default="300"
		hint="number of items to return">
	<cfargument name="order" type="string" required="false" default="RANDOM"
		hint="order of items" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_dynamic_playlist_items = 0 />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var sUserIds = '' />
	<cfset var a_struct_load_data = StructNew() />
	<cfset var a_str_basic_sql = '' />
	<cfset var a_tsql_query = 0 />
	<cfset var q_select_dynamic_playlists_recentlyadded = 0 />
	<cfset var qSelectUserids = 0 />
	<cfset var qCollect = 0 />
	
	<cfswitch expression="#arguments.playlistkey#">
		<cfcase value="recentlyadded">
		
			<!--- recently added --->			
			<cfinclude template="queries/playlists/q_select_dynamic_playlists_recentlyadded.cfm">
			
		</cfcase>
		<cfcase value="toprated">
						
			<!--- select top rated items ... --->
			<cfinclude template="queries/playlists/q_select_dynamic_playlists_toprated.cfm">		
			
		</cfcase>
		<cfcase value="recentlyplayed">
			
			<!--- select last played items items ... --->
			<cfinclude template="queries/playlists/q_select_dynamic_playlists_recentlyplayed.cfm">
						
		</cfcase>
		<cfcase value="followstream">
			
			<!--- get all userkeys of friends --->
			<cfset sUserIds = GetAllPossibleUseridsForLibraryAccess( arguments.securitycontext ) />
		
			<!--- follow friends stream --->
			<cfinclude template="queries/playlists/q_select_dynamic_playlists_followstream.cfm">
		
		</cfcase>
		<cfcase value="recommendations">
		
			<!--- received recommendations --->
			<cfinclude template="queries/playlists/q_select_dynamic_playlists_shared.cfm">
		
		</cfcase>
		
		<cfdefaultcase>
			
			<!--- use our new default way for loading data ... --->
			<cfset a_struct_load_data = QueryLibraryWithGivenCriteria(
				securitycontext = arguments.securitycontext,
				criteria 		= arguments.criteria,
				order 			= arguments.order
				) />
								
			<cfset q_select_dynamic_playlist_items = a_struct_load_data.q_select_items_based_on_criteria />
		
		</cfdefaultcase>
	</cfswitch>
	
	<cfset stReturn.q_select_dynamic_playlist_items = q_select_dynamic_playlist_items />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="QueryLibraryWithGivenCriteria" output="false" returntype="struct"
		hint="start a search process on the library using the given criteria and return the entrykeys of the hits">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="criteria" type="string" required="true"
		hint="criteria following the default criteria schema">
	<cfargument name="options" type="struct" default="#StructNew()#"
		hint="various options">
	<cfargument name="order" type="string" default="" required="false"
		hint="order by which field?">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_items_based_on_criteria = 0 />
	<cfset var a_int_max_rows = 999 />
	<cfset var a_bol_surprise_criteria_exists = false />
	<cfset var a_struct_criteria = StructNew() />
	<cfset var a_str_criteria_name = '' />
	<cfset var a_str_criteria_data = '' />
	<cfset var a_str_item = '' />
	<cfset var a_str_data = '' />
	
	<!--- get entrykeys of all possible libraries we can search through --->
	<cfset var a_str_librarykeys = GetAllPossibleLibrarykeysForLibraryAccess( arguments.securitycontext )/>
	
	<cfif StructKeyExists( arguments.options, 'maxrows' )>
		<cfset a_int_max_rows = val( arguments.options.maxrows ) />
	</cfif>
	
	<!--- create structure --->
	<cfloop list="#arguments.criteria#" delimiters="|" index="a_str_item">
		
		<!--- get the criteria name --->
		<cfset a_str_criteria_name = Trim( ListFirst( a_str_item, '?') ) />
		<cfset a_str_criteria_data = Trim( Mid( a_str_item, FindNoCase( '?', a_str_item) + 1, Len( a_str_item) ) ) />
		
		<cfset a_struct_criteria[ a_str_criteria_name ] = StructNew() />
		
		<!--- create the basic data --->
		<cfset a_struct_criteria[ a_str_criteria_name ].value = '' />
		<cfset a_struct_criteria[ a_str_criteria_name ].compare = '=' />
		<cfset a_struct_criteria[ a_str_criteria_name ].list = false />	
		
		<!--- get the data out of the strings --->
		<cfloop list="#a_str_criteria_data#" delimiters="&" index="a_str_data">
			<cfset a_struct_criteria[ a_str_criteria_name ][ ListFirst( a_str_data, '=' ) ] = Trim( ListLast( a_str_data, '=' ) ) />
		</cfloop>
		
	</cfloop>
	
	<!--- <cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="a_struct_criteria" type="html">
	<cfdump var="#a_struct_criteria#">
	</cfmail> --->
	
	<cfinclude template="queries/q_select_items_based_on_criteria.cfm">
	
	<cfset stReturn.q_select_items_based_on_criteria = q_select_items_based_on_criteria />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="GetUserContentDataMediaItems" output="false" returntype="struct" hint="return the playlists of a library">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="librarykeys" type="string" required="true">
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#"
		hint="various SIMPLE filter expressions">
	<cfargument name="orderby" type="string" required="true" default="mediaitem.artist"
		hint="order by ...">
	<cfargument name="search_criteria" type="string" required="false" default=""
		hint="search criteria in the default CRITERIA expression way we can handle">
	<cfargument name="maxrows" type="numeric" default="0" required="false"
		hint="max number of items to return, 0 = all">
	<cfargument name="options" type="string" required="false" default=""
		hint="options to pass to this function">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<!--- all other search operations are executed through our common search CRITERIA system --->
	<cfset var a_struct_criteria_search_result = StructNew() />
	<cfset var q_select_items_based_on_criteria = 0 />
	<cfset var qSelectLibIDs = 0 />
	<cfset var q_select_mediaitems = 0 />
	<cfset var qSelectAllOwnTracks = 0 />
	<cfset var sSQLVarOwnTracks = application.udf.returnMySQLVariableName() />
	<cfset var local = {} />

	<!--- entrykey filter given? --->
	<cfset var a_bol_filter_entrykeys = StructKeyExists( arguments.filter, 'entrykeys' ) />
	<cfset var bFilterMediaitemIDs = StructKeyExists( arguments.filter, 'ids' ) />
	<cfset var a_bol_filter_librarykey = Len( arguments.librarykeys ) GT 0 />
	<cfset var bOrderByPlistID = StructKeyExists( arguments.filter, 'iOrderPlistID' ) />
	
	<!--- only return certain fields? --->
	<cfset var a_bol_field_filter_active = StructKeyExists( arguments.filter, 'fields' ) AND (Len(arguments.filter.fields) GT 0) />
	
	<!--- return all fields by default --->
	<cfset var a_str_fields_to_return = '' />
	
	<!--- info about playlist available? --->
	<cfset var a_bol_plist_request = StructKeyExists( arguments.filter, 'info_playlistkey' ) AND ( Len( arguments.filter.info_playlistkey ) GT 0 ) />
	<cfset var a_str_info_plistkey = '' />
		
	<!--- calculate IDs --->
	<cfset var a_struct_genres = {} />
	<cfset var a_struct_artists = {} />
	<cfset var a_struct_albums = {} />
	<cfset var q_select_distinct_albums = 0 />
	<cfset var q_select_distinct_artists = 0 />
	<cfset var q_select_distinct_genres = 0 />
	<cfset var q_select_distinct_librarykeys = 0 />
	<cfset var a_struct_unique_table = {} />
	<!--- create those information about linked elements? --->
	<cfset var a_bol_create_link_tables = (ListFindNoCase( arguments.options, 'generatelinktables' ) GT 0) />
	<!--- create unique information --->
	<cfset var a_bol_create_uniquetable = (ListFindNoCase( arguments.options, 'uniquetable' ) GT 0) />
	<!--- remove items from return query --->
	<cfset var a_str_remove_cols_from_return_qry = '' />
	<cfset var a_str_data = 0 />
	<cfset var a_str_unique_genres_list = '' />
	<cfset var a_str_col_list = '' />
	<cfset var a_str_temp_cols_remove_later = '' />
	
	<!---
		not even RADIO allowed for playlists? reset to own librarykey only
	 --->
	 
	<cfif a_bol_plist_request AND arguments.securitycontext.rights.playlist.RADIO IS 0>
		<cfset arguments.librarykeys = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- the same for library ... in case it's not playlist request --->
	<cfif NOT a_bol_plist_request AND arguments.securitycontext.rights.library.RADIO IS 0>
		<cfset arguments.librarykeys = arguments.securitycontext.defaultlibrarykey />	
	</cfif>
	
	<!--- return only certain fields --->
	<cfif a_bol_field_filter_active>
		<cfset a_str_fields_to_return = arguments.filter.fields />
	</cfif>
	
	<!--- create unique table? make sure we're including certain fields ... --->
	<cfif a_bol_create_uniquetable>
	
		<!--- make sure the librarykeyindex is calculated! --->
		<cfif Len( a_str_fields_to_return ) GT 0>
		
			<cfif ListFindNoCase( a_str_fields_to_return, 'librarykeyindex') IS 0>
				<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'librarykeyindex' ) />
			</cfif>
			
			<cfif ListFindNoCase( a_str_fields_to_return, 'genreindex') IS 0>
				<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'genreindex' ) />
			</cfif>
		
		</cfif> 
		
	</cfif>
	
	<!--- this is a plist item request --->
	<cfif a_bol_plist_request>
		<cfset a_str_info_plistkey = arguments.filter.info_playlistkey />
		
		<!--- order by followstream order --->
		<cfif a_str_info_plistkey IS 'followstream'>
			
			<cfset arguments.orderby = 'followstream' />
		</cfif>
		
		<!--- order by recommendations --->
		<cfif a_str_info_plistkey IS 'recommendations'>
		
			<cfset arguments.orderby = 'recommendations' />
		
		</cfif>
		
		<!--- recently played --->
		<cfif a_str_info_plistkey IS 'recentlyplayed'>
			<cfset a_str_fields_to_return = ListAppend( a_str_fields_to_return, 'lasttime' ) />
		</cfif>
		
	</cfif>
	
	<!--- we have custom filter criteria given ...
		  get back the entrykeys which match to these search queries ... --->
		  
	<cfif Len( arguments.search_criteria ) GT 0>
		
		<!--- get entrykeys for this criteria --->
		<cfset a_struct_criteria_search_result = QueryLibraryWithGivenCriteria( securitycontext = arguments.securitycontext,
								criteria = arguments.search_criteria ) />
								
		<cfset q_select_items_based_on_criteria = a_struct_criteria_search_result.q_select_items_based_on_criteria />
		
		<!--- true ... use given entrykeys --->
		<cfset a_bol_filter_entrykeys = true />
		<cfset arguments.filter.entrykeys = ValueList( q_select_items_based_on_criteria.entrykey ) &  ',doesnotexist' />
		
		<!--- <cfset stReturn.dynamic_criteria = a_struct_criteria_search_result /> --->
		
	</cfif>
	
	<cfif bOrderByPlistID>
		<cfset arguments.orderby = 'ORDERBYPLAYLISTORDER' />
	</cfif>
	
	<!--- custom ORDER BY --->
	<cfif Len( arguments.orderby ) IS 0>
		<cfset arguments.orderby = 'mediaitem.artist' />
	</cfif>
	
	<!--- filter for entrykeys --->
	<cfif a_bol_filter_entrykeys>
		<cfquery name="local.qs" datasource="mytunesbutleruserdata">
		SELECT	mediaitems.id
		FROM	mediaitems
		WHERE	entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.entrykeys#" list="true" />)
		</cfquery>
		
		<cfset arguments.filter.ids = ValueList( local.qs.id ) />
		<cfset bFilterMediaitemIDs = true />
	</cfif>
	
	<cfinclude template="queries/q_select_mediaitems.cfm">
		
	<!--- return the items --->
	<cfset stReturn.q_select_items = q_select_mediaitems />
	
	<cfif a_bol_create_link_tables>
		<cfset stReturn.a_struct_unique_genres = a_struct_genres />
	</cfif>
	
	<!--- unique table? --->
	<cfif a_bol_create_uniquetable>
		<cfset stReturn.uniqueData = a_struct_unique_table />
	</cfif>
	
	<!--- only own items --->
	<!--- <cfset stReturn.bOnlyOwnItems = (local.qSelectNumberOwnTracks.iOwnTracksCount IS q_select_mediaitems.recordcount ) /> --->
	<cfset stReturn.bOnlyOwnItems = true />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="SaveMediaItemInformation" output="false" returntype="struct" hint="Store Meta Information about media item">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of the media item">
	<cfargument name="newvalues" type="struct" required="true"
		hint="structure holding new properties">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_bol_check_access = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(
			entrykey 		= arguments.entrykey,
			securitycontext = arguments.securitycontext,
			type			= 'mediaitem',
			action 			= 'edit',
			ip 				= cgi.REMOTE_ADDR ).result />
			
	<cfset var a_cmp_log = application.beanfactory.getBean( 'LogComponent' ) />
	<cfset var a_struct_item = 0 />
	<cfset var a_bol_db_operation = false />
	
	<cfif NOT a_bol_check_access>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001, 'Access to item denied') />
	</cfif>
	
	<cfset a_struct_item = oTransfer.get('mediaitems.mediaitem', arguments.entrykey) />
	
	<!--- sorry, item not found --->
	<cfif NOT a_struct_item.getisPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002) />
	</cfif>
		
	<!--- call internal meta data update --->
	<cfset a_bol_db_operation = StoreMediaItemInformation( operation = 'UPDATE',
					metainformation = arguments.newvalues,
					userkey = arguments.securitycontext.entrykey,
					librarykey = a_struct_item.getLibrarykey(),
					entrykey = arguments.entrykey,
					hashvalue = a_struct_item.gethashValue(),
					filename = '',
					originalhashvalue = '' ) />
		
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="GetMediaItemDisplayNameByEntrykey" output="false" returntype="string"
		hint="return display string of item">
	<cfargument name="entrykey" type="string" required="true"
		hint="the entrykey of the media item">
		
	<cfreturn GetMediaItemDisplayName( GetSimpleMediaItemInfo( arguments.entrykey )) />

</cffunction>

<cffunction access="public" name="GetMediaItemDisplayName" output="false" returntype="string"
		hint="build display name from item">
	<cfargument name="item" type="any" required="true">
	
	<cfset var a_str_return = '' />
		
	<cfset a_str_return = arguments.item.getName() />
	
	<cfif Len( arguments.item.getArtist() ) GT 0>
		<cfset a_str_return = arguments.item.getArtist() & ' - ' & a_str_return />
	</cfif>
	
	<!--- make it simplier - no album
	
	<cfif Len( arguments.item.getAlbum() ) GT 0>
		<cfset a_str_return = a_str_return & ' (' & arguments.item.getAlbum() & ')' />
	</cfif> --->
		
	<cfreturn a_str_return />
</cffunction>

<cffunction access="public" name="IsTemporaryMediaItem" output="false" returntype="boolean"
		hint="Check if an item is a temporary one or not">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of the media item">
	<cfargument name="source" type="string" required="true"
		hint="source (e.g. yt = YouTube)">
	
	<cfset var a_bol_result = false />
	<cfset var a_cmp_yt = application.beanfactory.getBean( 'YouTubeComponent' ) />
	
	<cfswitch expression="#arguments.source#">
		<cfcase value="yt">
			<cfreturn a_cmp_yt.IsTemporaryYouTubeClip( entrykey = arguments.entrykey ) />
		</cfcase>
	</cfswitch>
	
	<cfreturn a_bol_result />

</cffunction>

<cffunction name="GetMediaItem" access="public" output="false" returntype="struct"
		hint="Return information about a certain item">
	<cfargument name="applicationkey" type="string" required="false" default=""
		hint="the entrykey of the application making this request">
	<cfargument name="sessionkey" type="string" required="false" default=""
		hint="the session key ... important for e.g. widget embeddings" />
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of the media item">
	<cfargument name="deliver_mode" type="boolean" default="false"
		hint="should we perform some checks only needed for delivery?">
	<cfargument name="type" type="string" default="0" required="false"
		hint="0 = music (default), 1 = video (trying youtube)">
	<cfargument name="operation_reason" type="string" default="read" required="false"
		hint="reason for requesting this item ... READ or EDIT">
	<cfargument name="source" type="string" required="false" default="tb"
		hint="if provided, we try to lookup information in the youtube temp mapping database ...">
	<cfargument name="operation" type="string" default="PLAY" required="false"
		hint="in case we have a delivery mode ... what do we do? We only log PLAY requests to the infostream">
	<cfargument name="targetformat" type="string" required="false" default=""
		hint="deliver in a certain format - supported: mp3, 3gp, aac or swf">
	<cfargument name="targetbitrate" type="numeric" default="0" required="false"
		hint="request the file in a certain bitrate - supported: 32, 48, 64, 96, 128, 192, 320; 0 = default bitrate of file">
	<cfargument name="preview" type="boolean" default="false" required="false"
		hint="generate a preview version?">
	<cfargument name="context" type="numeric" default="0" required="false"
		hint="context in which this item has been requested (see transfer.xml)">
	<cfargument name="options" type="string" required="false" default=""
		hint="various options">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_cmp_storage = application.beanfactory.getBean( 'StorageComponent' ) />
	<cfset var a_cmp_log = application.beanfactory.getBean( 'LogComponent' ) />
	<cfset var a_str_entrykey = arguments.entrykey />
	<cfset var a_check_access = 0 />
	<cfset var a_struct_item = 0 />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_bol_lookup_meta_info = false />
	<cfset var a_struct_yt_item = StructNew() />
	<cfset var a_struct_log = StructNew() />
	<cfset var a_struct_audioconvert = 0 />
	<cfset var q_select_access = 0 />
	<cfset var a_int_seconds = 0 />
	<cfset var a_int_preview = 0 />
	<cfset var local = {} />
	
	<!--- get the item the ordinary way --->
	<cfset a_struct_item = oTransfer.get('mediaitems.mediaitem',  a_str_entrykey) />
		
	<!--- item found?  --->
	<cfif NOT a_struct_item.getisPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1002 ) />
	</cfif>
	
	<!--- need to perform a security check? --->
	<cfif a_struct_item.getUserkey() IS NOT arguments.securitycontext.entrykey>
	
		<!--- perform security check? --->
		<cfset a_check_access = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(entrykey = a_str_entrykey,
				securitycontext = arguments.securitycontext,
				type= 'mediaitem',
				operation_reason = arguments.operation_reason,
				source = arguments.source,
				ip = cgi.REMOTE_ADDR,
				context = arguments.context ) />
				
		<cfif NOT a_check_access.result>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001) />
		</cfif>
		
		<cfset stReturn.a_check_access = a_check_access />
	
	</cfif>			
		
	<cfset stReturn.item = a_struct_item />
	
	<!--- deliver several meta information as well, e.g. lastaccess etc --->
	<cfif NOT arguments.deliver_mode>
		
		<cfinclude template="queries/q_select_access.cfm">		
		<cfset stReturn.q_select_access = q_select_access />	
		
	</cfif>
	
	<!--- preview? --->	
	<cfif arguments.preview>
		<!--- return 30 sec --->
		<cfset a_struct_item.settotaltime( 30 ) />
	</cfif>
	
	<!--- we want to deliver the file to the customer, so let's have a look ... --->
	<cfif arguments.deliver_mode>
	
		<cfset stReturn.deliver_info = StructNew() />
		<!--- We have to return the location of the file ... either as URL or as FILE location --->
		
		<!--- first check: is it only a simple redirector to a web resource ... (e.g. a podcast)? --->
		<cfif a_struct_item.getstoragetype() IS application.const.I_STORAGE_TYPE_HTTP_RAW>
		
			<!--- return the URL (is the case e.g. when playing podcasts) ... RAW --->
			<cfset stReturn.deliver_info.type = 'http' />
			<cfset stReturn.deliver_info.location = a_struct_item.getLocation() />
		
		<cfelse>
			
			<!--- deliver from real storage ... log this --->
			<cfset stReturn.deliver_info.type = 'http' />

			<!--- return the URL --->
			<cfif a_struct_item.getStorageType() IS application.const.I_STORAGE_TYPE_DROPBOX>
				
				<cfset local.stDPinfo = application.beanFactory.getBean( 'Dropbox' ).getDeliveryInformation(
						stContext = arguments.securitycontext,
						sMetaHashValue = a_struct_item.getMetaHashValue() ) />
				
				<!--- return from dropbox --->
				<!--- <cfmail from="post@hansjoergposch.com" to="hansjoerg@tunesBag.com" subject="dropbox deliver" type="html">
				<cfdump var="#arguments#" label="arguments">
				<cfdump var="#local.stDPinfo#">
				</cfmail> --->
				
				<!--- TODO: error handling --->
				
				<cfset stReturn.deliver_info.location = local.stDPInfo.sURL />
				<!--- <cfset arguments.targetbitrate = 0 />
				<cfset stReturn.deliver_info.contenttype = '' />
				<cfset arguments.options= ''> --->
				
				<!--- testing with local location --->
				<!--- <cfset stReturn.deliver_info.location = 'http://192.168.224.128:4444/?mediahashvalue=#Hash( "abc", "sha" )#&userkey=#CreateUUID()#&nocache=#CreateUUID()#' /> --->
			
			<cfelseif ListFindNoCase( application.const.I_STORAGE_TYPE_8TRACKS & ',' & application.const.I_STORAGE_TYPE_SOUNDCLOUD, a_struct_item.getstoragetype()) GT 0>
				
				<cfquery name="local.qLocation" datasource="mytunesbutleruserdata">
				SELECT	meta.location
				FROM	mediaitems_metainformation AS meta
				WHERE	meta.mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#" />
				</cfquery>
				
				<cfset stReturn.deliver_info.location = local.qLocation.location />
			
			<cfelseif a_struct_item.getStorageType() IS application.const.I_STORAGE_TYPE_MP3TUNES>
				
				<!--- mp3tunes is the source of this file --->
				<cfset local.stMP3TunesInfo = application.beanFactory.getBean( 'MP3Tunes' ).getDeliveryInformation(
						stContext = arguments.securitycontext,
						sMetaHashValue = a_struct_item.getMetaHashValue() ) />
				
				<!--- TODO: error handling --->
				<cfset stReturn.deliver_info.location = local.stMP3TunesInfo.sURL />
				<!--- <cfset arguments.targetbitrate = 0 />
				<cfset stReturn.deliver_info.contenttype = '' />
				<cfset arguments.options= ''> --->
			
			<cfelse>
				
				<!--- tunesbag storage --->
				<cfset stReturn.deliver_info.location = a_cmp_storage.GetHTTPS3LinkToObject( a_struct_item.getHashValue() ) />
				<cfset stReturn.deliver_info.contentlength = a_struct_item.getSize() />
				
				<!--- set the general content - type --->
				<cfset stReturn.deliver_info.contenttype = 'audio/mpeg' />
				
			</cfif>
			
			
			
			
			
			
			<!--- we have to deliver a converted version of this item ... only perform this action if
			
				a) format is given
				b) bitrate is given AND target bitrate is lower than original bitrate OR
				c) we've to create a preview version --->
				
			<cfif ((Len( arguments.targetformat ) GT 0) OR
				  (
				  	(Val( arguments.targetbitrate ) GT 0)
				  	AND
				  	(arguments.targetbitrate LT a_struct_item.getbitrate() )
				  )
				  OR arguments.preview
				  OR ListFindNoCase( arguments.options, 'forcestreamingdeliver' )
				  )
				  >
				  
				 <!--- AND NOT
				  
				  (a_struct_item.getstoragetype() IS application.const.I_STORAGE_TYPE_8TRACKS) --->
			
				<!--- get the first 30 secs --->
				<cfif arguments.preview>
					<cfset a_int_seconds = 20 />
				</cfif>
						
				<!--- try to get the data needed for conversions --->
				<cfset a_struct_audioconvert = application.beanFactory.getBean( 'AudioConverter' ).getMediaItemAsCertainFormat( securitycontext = arguments.securitycontext,
												mediaitem = a_struct_item,
												deliver_info = stReturn.deliver_info,
												format = arguments.targetformat,
												bitrate = arguments.targetbitrate,
												seconds = a_int_seconds ) />
				
				<!--- worked perfectly, return the new values --->								
				<cfif a_struct_audioconvert.result>
					<cfset stReturn.deliver_info.location = a_struct_audioconvert.location />
					<cfset stReturn.deliver_info.contenttype = a_struct_audioconvert.contenttype />
					<cfset stReturn.deliver_info.type = a_struct_audioconvert.type />
					<cfset stReturn.deliver_info.contentlength = a_struct_audioconvert.contentlength />
					
					<!--- especially for the squeezebox, return an invalid filesize (doesn't matter, will stream the entire track nevertheless) --->
					<cfif ListFindNoCase( arguments.options, application.const.S_PLAY_PARAM_FORCE_RETURN_FILESIZE)>
						<cfset stReturn.deliver_info.location = stReturn.deliver_info.location & '&returnfilesize=true' />
					</cfif>
					
				<cfelse>
					<!--- error! --->
					<cfreturn a_struct_audioconvert />									
				</cfif>
			
			</cfif>
		
		</cfif>
		
		<!--- log delivery as "played" --->
		<cfif arguments.operation IS 'PLAY'>
			
			<cfif arguments.preview>
				<cfset a_int_preview = 1 />
			</cfif>
			
			<!--- set the time to the full track length in case of the squeezebox as this device does not provide any feedback on the playback status
			
				in any other cases, use 0 --->
			<cfif arguments.applicationkey IS application.const.S_APPKEY_SQUEEZENETWORK>
				<cfset local.isecondsplayed = a_struct_item.getTotalTime() />
			<cfelse>
				<cfset local.isecondsplayed = 0 />
			</cfif>
			
			<!--- perform logging --->
			<cfset a_struct_log = application.beanFactory.getBean( 'LogComponent' ).LogMediaItemPlayed( securitycontext = arguments.securitycontext,
									ip = cgi.REMOTE_ADDR,
									applicationkey = arguments.applicationkey,
									mediaitemkey = arguments.entrykey,
									sessionkey = arguments.sessionkey,
									item = a_struct_item,
									preview = a_int_preview,
									context = arguments.context,
									secondsplayed = local.isecondsplayed ) />
		
			<!--- return the logging key --->							
			<cfset stReturn.logkey = a_struct_log.entrykey />
		</cfif>		
		
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
</cffunction>

<cffunction access="public" name="GetDefautLibraryEntrykey" output="false" returntype="string"
		hint="return the entrykey of the default library of an user">
	<cfargument name="userkey" type="string" required="true">
	
	<cfset var q_select_user_default_librarykey = 0 />
	<cfset var a_str_librarykey = '' />
	
	<cfinclude template="queries/libraries/q_select_user_default_librarykey.cfm">
	<cfset a_str_librarykey = q_select_user_default_librarykey.entrykey />
	
	<cfif Len( a_str_librarykey ) IS 0>
		
		<!--- has no default entrykey ... create a new one and return the new entrykey --->
		<cfset a_str_librarykey = CreateDefaultLibrary( userkey = arguments.userkey ).entrykey />
		
	</cfif>
		
	<cfreturn a_str_librarykey />
	
</cffunction>

<cffunction access="public" name="CreateDefaultLibrary" output="false" returntype="struct" hint="Make sure the default library exists">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of the user">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_new_lib = oTransfer.new('libraries.library') />
	
	<cfscript>
	a_new_lib.setentrykey(a_str_entrykey);
	a_new_lib.setname( 'default' );
	a_new_lib.setuserkey( arguments.userkey );
	oTransfer.save( a_new_lib );
	</cfscript>
	
	<cfset stReturn.entrykey = a_str_entrykey />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>


<!--- <cffunction access="private" name="CalculateFileHashInformation" output="false" returntype="string"
		hint="Calculate the default hash value for our system">
	<cfargument name="metainformation" type="struct" required="true"
		hint="structure holding the basic information">	

	<cfset var a_str_2_hash = arguments.metainformation.artist &
								arguments.metainformation.album &
								arguments.metainformation.name &
								arguments.metainformation.year &
								arguments.metainformation.size />

	<cfset var a_str_hash_value = 'hash_' & lCase( Hash( lCase( a_str_2_hash ))) />
	
	<cflog application="false" file="tb_hash_gen" log="Application" type="information" text="#a_str_2_hash#: #a_str_hash_value#">

	<cfreturn a_str_hash_value />
</cffunction> --->

<cffunction access="public" name="UnifyGenre" returntype="string" output="false"
		hint="take the genre as argument and modify if necessary">
	<cfargument name="genre" type="string" required="true">
	
	<cfset var a_str_return = arguments.genre />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_get_item = 0 />
	<cfset var a_int_ii = 0 />
	<cfset var a_str_original_value = '' />
	
	<cfset a_str_return = ReReplaceNoCase(a_str_return, '[^A-Z,a-z,0-9,(,), ,&]*', '', 'ALL') />
	
	<cfif Len(a_str_return) IS 0>
		<cfreturn '' />
	</cfif>
	
	<!--- genre list: http://www.linuxselfhelp.com/HOWTO/MP3-HOWTO-13.html#ss13.3 --->
	
	<!--- example: (24) Soundtrack --->
	<cfif Left(a_str_return, 1) IS '('>
		
		<cfset a_str_return = ReplaceNoCase(a_str_return, '(', '') />
		<cfset a_str_return = Val(a_str_return) />
		
		<cflog application="false" file="ib_set_genre" text="genre replaced ( |#a_str_return#|" type="information">
		
		<cfset a_get_item = oTransfer.readByProperty( 'mediaitems.genrelist' , 'id3id', Val(a_str_return)) />
		
		<cfset a_str_return = a_get_item.getName() />
		
	</cfif>
	
	<!--- example: (24) --->
	<cfif Right(a_str_return, 1) IS ')'>
		
		<!--- replace all chars which are not 0 - 9 --->
		<cfset a_str_return = ReReplaceNoCase(a_str_return, '[^0-9]*', '', 'ALL') />
		
		<cflog application="false" file="ib_set_genre" text="genre replaced ) |#a_str_return#|" type="information">
		
		<cfset a_get_item = oTransfer.readByProperty( 'mediaitems.genrelist' , 'id3id', Val(a_str_return)) />
		
		<cfset a_str_return = a_get_item.getName() />
		
	</cfif>
	
	
	<cfreturn a_str_return />

</cffunction>

<cffunction access="public" name="GetFullGenreList" output="false" returntype="query"
		hint="return the full list of known genres">
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		
	<cfreturn oTransfer.list( 'mediaitems.genrelist', 'name' ) />

</cffunction>

<cffunction access="public" name="getValidLibrarykeysOfUser" output="false" returntype="string"
		hint="return a list of valid library keys">
	<cfargument name="sUserkey" type="string" required="true" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var qLibraries = oTransfer.listByProperty( 'libraries.library', 'userkey', arguments.sUserkey ) />
	
	<cfreturn ValueList( qLibraries.entrykey ) />

</cffunction>

<cffunction access="public" name="StoreMediaItemInformation" output="false" returntype="struct"
		hint="internal routine to store meta data about a piece of media item in the database">
	<cfargument name="operation" type="string" required="true"
		hint="CREATE or UPDATE">
	<cfargument name="metainformation" type="struct" required="true"
		hint="structure with items / information">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of user">
	<cfargument name="librarykey" type="string" required="true"
		hint="entrykey of library">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of item">
	<cfargument name="hashvalue" type="string" required="true"
		hint="unique hash value in the lib">
	<cfargument name="originalhashvalue" type="string" required="true"
		hint="original hashvalue before any converting stuff etc">
	<cfargument name="filename" type="string" required="true"
		hint="the name of the file">
	<cfargument name="source" type="string" required="false" default=""
		hint="source of this update">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_db_item = 0 />
	<cfset var local = {} />
	<cfset var a_int_track_no = 0 />
	<cfset var q_select_existing_item = 0 />
	<cfset var oMetaItem = 0 />
	<cfset var iUserid = application.beanFactory.getBean( 'UserComponent' ).GetUseridByEntrykey( arguments.userkey ) />
	<cfset var qDeleteOldItem = 0 />
	<cfset var sArtworkFileName = 0 />
	
	<!--- always return the entrykey --->
	<cfset stReturn.entrykey = arguments.entrykey />
	
	<cfset local.sMetaHashValue = '' />
	
	<!--- get or update? --->
	<cfif arguments.operation IS 'CREATE'>
		
		<!--- check if all necessary parameters have been provided --->
		<cfif Len( arguments.hashvalue ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'hash value is empty') />
		</cfif>
		
		<cfif Len( arguments.originalhashvalue ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'hash value is empty') />
		</cfif>
		
		<!--- no librarykey provided? use default one --->
		<cfif Len( arguments.librarykey ) IS 0>
			<cfset arguments.librarykey = GetDefautLibraryEntrykey( arguments.userkey )/>
		</cfif>
		
		<!--- valid librarykey? --->
		<cfif ListFindNoCase( getValidLibrarykeysOfUser(arguments.userkey ), arguments.librarykey ) IS 0>
			<cfset arguments.librarykey = GetDefautLibraryEntrykey( arguments.userkey )/>
		</cfif>
		
		<!--- maybe an old item exists (unlikely but who knows ...) --->
		<cfquery name="qDeleteOldItem" datasource="mytunesbutleruserdata" result="qDeleteOldItem">
		DELETE FROM
			mediaitems
		WHERE
			userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
			AND
			librarykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykey#">
			AND
			hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">
		;
		</cfquery>
		
		<cfset a_db_item = oTransfer.new( 'mediaitems.mediaitem' ) />
		
		<!--- set original hash value only when we create this item --->
		<cfset a_db_item.setoriginalfilehashvalue( Trim( arguments.originalhashvalue )) />		
		
	<cfelse>
		<cfset a_db_item = oTransfer.get( 'mediaitems.mediaitem', arguments.entrykey) />
		
		<!--- store copy of original data ... --->
		<cfset q_select_existing_item = oTransfer.listByProperty( 'mediaitems.mediaitem', 'entrykey', arguments.entrykey ) />
		
		<cfset application.beanFactory.getBean( 'LogComponent' ).StoreMediaItemOldMetaData( userkey = arguments.userkey,
										mediaitemkey = arguments.entrykey,
										data = q_select_existing_item,
										source = arguments.source ) />
	</cfif>
		
	<!--- set mandatory properties --->
	<cfset a_db_item.sethashvalue( Trim( arguments.hashvalue ) ) />
	<cfset a_db_item.setentrykey( Trim( arguments.entrykey ) ) />
	<cfset a_db_item.setuserkey( Trim( arguments.userkey ) ) />	
	<cfset a_db_item.setuserid( iUserid ) />
	
	<cfif NOT a_db_item.getIsPersisted()>
		<cfset a_db_item.setdt_created( Now() ) />
	</cfif>
	
	<cfset a_db_item.setLibraryKey( Trim(arguments.librarykey) ) />
	
	<!--- get / set meta item --->
	<cfset oMetaItem = oTransfer.get( 'mediaitems.mediaitems_metainformation', arguments.entrykey ) />
	<cfset oMetaItem.setMediaitemkey( arguments.entrykey ) />
	
	<!--- free fields ... starting with artist --->
	<cfif StructKeyExists(arguments.metainformation, 'artist') AND Len( arguments.metainformation.artist ) GT 0>
		<cfset a_db_item.setartist( Left( Trim(arguments.metainformation.artist), 150) ) />
	</cfif>
	
	<!--- use the given name or use the filename --->

	<cfif StructKeyExists(arguments.metainformation, 'name')>
	
		<!--- length of name > 0? --->
		<cfif (Len(arguments.metainformation.name) GT 0)>
			<cfset a_db_item.setName( Left( Trim(arguments.metainformation.name), 255) ) />
		<cfelse>
			<!--- we need a name ... --->
			<cfset a_db_item.setName( Left( Trim(GetFileFromPath( arguments.filename )), 255) ) />
		</cfif>
		
	</cfif>
	
	<!--- meta data hash value (simple hash for identification) --->
	<cfif StructKeyExists(arguments.metainformation, 'artist') AND StructKeyExists(arguments.metainformation, 'name')>
		
		<cfset local.sMetaHashValue = getHashValueArtistTrack( arguments.metainformation.artist, arguments.metainformation.name ) />
		
		<cfset a_db_item.setmetahashvalue( local.sMetaHashValue ) />
	
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'genre') AND Len( arguments.metainformation.genre ) GT 0>
		<cfset a_db_item.setGenre( Left( Trim(UnifyGenre(arguments.metainformation.genre)), 100) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'album') AND Len( arguments.metainformation.album ) GT 0>
		<cfset a_db_item.setAlbum( Left( Trim(arguments.metainformation.album), 150) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'trackno')>
		<cfset a_db_item.setTracknumber( Left( Trim(arguments.metainformation.trackno), 20) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'licence_type')>
		<cfset a_db_item.setlicence_type( Val( arguments.metainformation.licence_type ) ) />
	</cfif>	
	
	<!--- only set year if not "" --->
	<cfif (StructKeyExists(arguments.metainformation, 'year') AND Val( arguments.metainformation.year ) GT 0)>
		<cfset a_db_item.setyear( Val(arguments.metainformation.year) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'size')>
		<cfset a_db_item.setsize( Val(arguments.metainformation.size) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'bitrate')>
		<cfset a_db_item.setbitrate( Val(arguments.metainformation.bitrate) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'samplerate')>
		<cfset a_db_item.setsamplerate( Val(arguments.metainformation.samplerate) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'tracklength')>
		<cfset a_db_item.setTotalTime( Val(arguments.metainformation.tracklength) ) />
	</cfif>
	
	<!--- <METADATA> --->
	
	<!--- itunes specific --->
	<cfif StructKeyExists(arguments.metainformation, 'iTunesTrackID')>
		<cfset oMetaItem.setITunesTrackID( Val(arguments.metainformation.iTunesTrackID) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'itunespersistentid')>
		<cfset oMetaItem.setitunespersistentid( Left( Trim(arguments.metainformation.itunespersistentid), 255) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.metainformation, 'format')>
		<cfset oMetaItem.setformat( Left( Trim(arguments.metainformation.format), 100) ) />
		
		
		<cfswitch expression="#arguments.metainformation.format#">
			<cfcase value="AAC">
				<!--- aac is supported --->
				<cfset local.iAudioFormat = application.const.I_AUDIO_FORMAT_M4A />
			</cfcase>
			<cfcase value="MPEG-1 Layer 3">
				<!--- default mp3 --->
				<cfset local.iAudioFormat = application.const.I_AUDIO_FORMAT_MP3 />			
			</cfcase>
			
			<!--- todo: add further formats --->
			
			<!--- todo: let caller submit the format as ID --->
			
			<cfdefaultcase>
				<!--- use mp3 as default --->
				<cfset local.iAudioFormat = application.const.I_AUDIO_FORMAT_MP3 />
			</cfdefaultcase>
		</cfswitch>
		
		<!--- store the audio format --->
		<cfset oMetaItem.setformat_ID( local.iAudioFormat ) /> 
		
	</cfif>

	<cfif StructKeyExists(arguments.metainformation, 'location')>
		<cfset oMetaItem.setlocation( Left( Trim(arguments.metainformation.location), 255) ) />
	</cfif>	
	
	<!--- </METADATA> --->
	
	<!--- internal attributes ... stored by auto job? special storage type? --->
	<cfif StructKeyExists(arguments.metainformation, 'createdbyunit')>
		<cfset a_db_item.setcreatedbyunit( Left( Trim(arguments.metainformation.createdbyunit), 20) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.metainformation, 'source')>
		<cfset a_db_item.setsource( Left( Trim(arguments.metainformation.source), 10) ) />
	</cfif>			
	
	<cfif StructKeyExists(arguments.metainformation, 'storagetype')>
		<cfset a_db_item.setstoragetype( Trim(arguments.metainformation.storagetype) ) />
	</cfif>			
	
	<!--- musicbrainz data --->
	<cfif StructKeyExists(arguments.metainformation, 'mb_artistid') AND Val( arguments.metainformation.mb_artistid ) GT 0>
		<cfset a_db_item.setmb_artistid( arguments.metainformation.mb_artistid ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.metainformation, 'mb_albumid') AND Val( arguments.metainformation.mb_albumid ) GT 0>
		<cfset a_db_item.setmb_albumid( arguments.metainformation.mb_albumid ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.metainformation, 'mb_trackid') AND Val( arguments.metainformation.mb_trackid ) GT 0>
		<cfset a_db_item.setmb_trackid( arguments.metainformation.mb_trackid ) />
	</cfif>		
	
	<!--- PUID of the file --->
	<cfif StructKeyExists(arguments.metainformation, 'puid')>
		<cfset a_db_item.setpuid( arguments.metainformation.puid ) />
	</cfif>		
	
	<!--- puid generated? (calculated) --->
	<cfif StructKeyExists(arguments.metainformation, 'puid_generated')>
		<cfset a_db_item.setpuid_generated( arguments.metainformation.puid_generated ) />
	</cfif>			
	
	<!--- PUID already analyzed by local routines? --->
	<cfif StructKeyExists(arguments.metainformation, 'puid_analyzed')>
		<cfset a_db_item.setpuid_analyzed( arguments.metainformation.puid_analyzed ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.metainformation, 'customartwork') AND Val( arguments.metainformation.customartwork ) GT 0>
		<cfset a_db_item.setcustomartwork( 1 ) />
	</cfif>
	
	
		
	<!--- handle custom artwork string --->
	<cfif StructKeyExists( arguments.metainformation, 'ARTWORKFILECONTENT' ) AND Len( arguments.metainformation.ARTWORKFILECONTENT ) GT 0>
		
		<!--- save to file --->
		<cfset sArtworkFileName = GetTempDirectory() & CreateUUID() & '.artwork.temp.jpg' />
		
		<cftry>
			<cffile action="write" file="#sArtWorkFilename#" output="#ToBinary( arguments.metainformation.ARTWORKFILECONTENT )#" />
			
			<cfset local.stAddArtwork = application.beanFactory.getBean( 'ContentComponent' ).HandleCustomTrackArtwork( mediaitemkey = arguments.entrykey,
							file_location = sArtWorkFilename ) />
							
			<!--- ok, set custom artwork to true --->
			<cfset a_db_item.setcustomartwork( 1 ) />
							
		<cfcatch type="any">
			<cfthrow message="#cfcatch.Message#">
		</cfcatch>
		</cftry>
		
	
	</cfif>
	
	<!--- custom covertart has been provided --->
	<!--- <cfif StructKeyExists( arguments.metainformation, 'artworkFilename') AND FileExists( arguments.metainformation.artworkFilename )>
		<cfset a_db_item.setcustomartwork( 1 ) />
	</cfif> --->
	
	<!--- finally, store the item --->
	<cfset oTransfer.save(a_db_item) />
	
	<cfset oTransfer.save( oMetaItem ) />
	
	<!--- set the lastkey (important for sync operations ) --->
	<cfset SetLibraryLastkey( librarykey = arguments.librarykey, lastkey = arguments.entrykey ) />
	
	<!--- analyze meta information ... only in case musicbrainz data is not set explicitly--->
	<cfif NOT StructKeyExists(arguments.metainformation, 'mb_artistid')
		  AND NOT StructKeyExists(arguments.metainformation, 'mb_albumid')
		  AND NOT StructKeyExists(arguments.metainformation, 'mb_trackid')>
			  
		<cfset application.beanFactory.getBean( 'MusicBrainz' ).AnalyzeDBTrackMetaInfo( arguments.entrykey ) />
		
	</cfif>
	
	<!--- add relation --->
	<cfif arguments.operation IS 'CREATE'>
		
		<cfset application.beanFactory.getBean( 'Tools' ).createRelationByEntrykeys( sRelation = 'rel_library_mediaitem',
							librarykey = arguments.librarykey,
							mediaitemkey = arguments.entrykey) />
							
		<!--- update item counter --->
		<cfset UpdateCountInformation( userkey = arguments.userkey, type = 'library' ) />
	
	</cfif>
	
	<!--- return the hash value of the basic meta data --->
	<cfset stReturn.sMetaHashValue = local.sMetaHashValue />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="addMediaItemMetaInfoToLibrary" output="false" returntype="struct"
		hint="routine to add a new media item to the library">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="librarykey" type="string" default="" required="false"
		hint="entrykey of the library">
	<cfargument name="metainformation" type="struct" required="false" default="#StructNew()#"
		hint="meta information">
	<cfargument name="hashvalue" type="string" required="false" default=""
		hint="the hashvalue of the original file">
	<cfargument name="originalhashvalue" type="string" required="false" default=""
		hint="the original hashvalue of the original file (maybe the file has been converted WMA -> MP3)" />
	<cfargument name="autoaddtoplaylist" type="string" required="false" default=""
		hint="automatically add to the named playlist?">
	<cfargument name="filename" type="string" required="false" default=""
		hint="the location of the file on the HD of the user" />
	<cfargument name="source" type="string" required="false" default=""
		hint="source of this file, some sort of user-agent" />
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />

	<cfset var cfhttp = 0 />
	<cfset var a_str_librarykey = arguments.securitycontext.defaultlibrarykey />
	<cfset var a_cmp_plists = application.beanFactory.getBean( 'PlaylistsComponent' ) />
	<cfset var a_bol_db = 0 />
	<cfset var a_bol_hashvalue_exists = false />
	<cfset var a_str_hashvalue = arguments.hashvalue />
	<cfset var q_select_filesize = 0 />
	<cfset var a_struct_storage = 0 />
	<cfset var a_struct_result_parse_mp3 = StructNew() />
	<cfset var a_str_original_hashvalue = arguments.originalhashvalue />
	<cfset var a_struct_call = 0 />
	<cfset var stInsertMeta = {} />
	<cfset var sEntrykey = CreateUUID() />
	
	<cfif Len( arguments.librarykey ) IS 0>
		<cfset arguments.librarykey = arguments.securitycontext.defaultlibrarykey />
	</cfif>
	
	<!--- original hashvalue is empty? set it to the very same as the calculated file hashvalue --->
	<cfif Len( a_str_original_hashvalue ) IS 0>
		<cfset a_str_original_hashvalue = a_str_hashvalue />
	</cfif>
	
	<!--- does this file already exist? --->
	<cfif CheckHashValueExists(userkey = arguments.securitycontext.entrykey, hashvalue = a_str_hashvalue)>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002, 'File already exists') />
	</cfif>	
	
	<!--- insert into database ... --->
	<cfset stInsertMeta = StoreMediaItemInformation(
			operation 			= 'CREATE',
			entrykey 			= sEntrykey,
			userkey 			= arguments.securitycontext.entrykey,
			librarykey 			= arguments.librarykey,
			metainformation 	= arguments.metainformation,
			hashvalue 			= a_str_hashvalue,
			originalhashvalue 	= a_str_original_hashvalue,
			filename 			= arguments.filename
			) />

	<!--- failure? --->
	<cfif NOT stInsertMeta.result>
		<cfreturn stInsertMeta />
	</cfif>					
	
	<!--- return the new entrykey and the meta data hashvalue --->
	<cfset stReturn.entrykey = stInsertMeta.entrykey />
	<cfset stReturn.sMetaHashValue = stInsertMeta.sMetaHashValue />
						
	<!--- check if we should add this file to a playlist automatically? --->
	<cfset a_cmp_plists.CheckAutoAddItemToPlaylist( securitycontext = arguments.securitycontext,
						librarykey = arguments.librarykey,
						mediaitemkey = stReturn.entrykey,
						hashvalue = a_str_original_hashvalue ) />						
								
	<!--- automatically add to a playlist --->					
	<cfif Len( arguments.autoaddtoplaylist ) GT 0>
		
			<cfset a_cmp_plists.CheckAutoAddItemToPlaylistByName( securitycontext = arguments.securitycontext,
						librarykey = arguments.librarykey,
						mediaitemkey = a_str_entrykey,
						playlistname = arguments.autoaddtoplaylist ) />
	</cfif>
						
	<!--- update lib counter --->
	<cfset UpdateCountInformation( userkey = arguments.securitycontext.entrykey, type = 'library' ) />
	
	<!--- some special information provided by uploader? rating /  --->
	<cfif StructKeyExists( arguments.metainformation, 'rating' ) AND Val( arguments.metainformation.rating ) GT 0>
		
		<!--- save rating --->
		<cfset a_struct_call = RateItem( securitycontext = arguments.securitycontext,
							librarykey = arguments.librarykey,
							mediaitemkey = stReturn.entrykey,
							itemtype = 0,
							rating = Val( arguments.metainformation.rating )) />
							
	</cfif>
	
	<!--- lastplayed --->
	<cfif StructKeyExists( arguments.metainformation, 'LastPlayed' ) AND IsDate( arguments.metainformation.LastPlayed )>
	
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="CheckOriginalHashValueExists" output="false" returntype="boolean"
		hint="check if a certain hash value exists for an user">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="originalhashvalue" type="string" required="true"
		hint="the original hashvalue of the file before any conversion took place">
	
	<cfset var a_bol_return = false />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_map = { userkey = arguments.userkey, originalfilehashvalue = arguments.originalhashvalue } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'mediaitems.mediaitem', a_map ) />	
	
	<cfreturn a_item.getisPersisted() />
</cffunction>

<cffunction access="public" name="CheckHashValueExists" output="false" returntype="boolean"
		hint="check if a certain hash value exists for an user">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="hashvalue" type="string" required="true">	
	
	<cfset var a_bol_return = false />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_map = { userkey = arguments.userkey, hashvalue = arguments.hashvalue } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'mediaitems.mediaitem', a_map ) />
	
	<cfreturn a_item.getisPersisted() />
</cffunction>


<cffunction access="public" name="RemoveItemFromLibrary" output="false" returntype="struct"
		hint="delete an item from the library">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of the media item">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_struct_delete_storage = 0 />
	<cfset var a_map_q = { userkey = arguments.securitycontext.entrykey,
						   entrykey = arguments.entrykey } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'mediaitems.mediaitem', a_map_q ) />
	
	<cfif a_item.getUserkey() NEQ arguments.securitycontext.entrykey>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1001 ) />
	</cfif>
	
	
	<!--- check if we can delete the file from S3 --->
	<cfset a_struct_delete_storage = application.beanFactory.getBean( 'StorageComponent' ).DeleteStorageItem( securitycontext = arguments.securitycontext,
							mediaitemkey = arguments.entrykey,
							hashvalue = a_item.getHashvalue() ) />
	
	<!--- delete from mediaitems table --->
	<cfif a_struct_delete_storage.result>
		
		<!--- delete relation --->
		
		<cfset application.beanFactory.getBean( 'Tools' ).deleteRelationByCriteria( sRelation = 'rel_user_mediaitem',
					stCriteria = { mediaitemkey = a_item.getEntrykey() } ) />
					
		<cfset application.beanFactory.getBean( 'Tools' ).deleteRelationByCriteria( sRelation = 'rel_library_mediaitem',
					stCriteria = { mediaitemkey = a_item.getEntrykey() } ) />		
		<!--- delete item --->
		<cfset oTransfer.delete( a_item ) />
		
		<cfset UpdateCountInformation( arguments.securitycontext.entrykey, 'library' ) />
		
		<!--- success --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	<cfelse>
	
		<!--- return failure --->
		<cfreturn a_struct_delete_storage />
	
	</cfif>
	
</cffunction>

<cffunction access="public" name="getMediaItemIDByEntrykey" returntype="numeric"
		hint="return the ID by it's entrykey">
	<cfargument name="entrykey" type="string" required="true" />
	
	<cfset var qSelect = 0 />
	
	<cfquery name="qSelect" datasource="mytunesbutleruserdata">
	SELECT
		id
	FROM
		mediaitems
	WHERE
		entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
	;
	</cfquery>
	
	<cfreturn Val( qSelect.id ) />

</cffunction>

<cffunction access="public" name="RateItem" output="false" returntype="struct" hint="Rate an item">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="mbid" type="numeric" default="0" required="true"
		hint="the musicbrainz id of this item (artist, track, album)">	
	<cfargument name="mediaitemkey" type="string" required="false" default=""
		hint="entrykey of item, can be empty in case just an artist is rated">
	<cfargument name="itemtype" type="string" required="false" default="0"
		hint="0 = track, 1 = album, 2 = artist, 3 = playlist">
	<cfargument name="rating" type="numeric" default="0" required="true"
		hint="rating ... min = 0, max = 100">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<!--- select old ratings for delete --->
	<cfset var q_delete_old_mediaitem_ratings = 0 />
	<cfset var q_delete_old_fan_artist_item = 0 />
	<cfset var a_bol_check_access = false />	
	<cfset var a_struct_item = 0 />
	<cfset var q_select_old_items = 0 />
	<cfset var a_struct_update_artist_fans = StructNew() />
	<cfset var a_rating_item = oTransfer.new( 'mediaitems.rating' ) />
	<cfset var a_bol_result = false />
	<cfset var q_set_plist_avg_rating = 0 />
	<!--- the log number --->
	<cfset var a_int_log_no = 610 />
	<cfset var a_str_hashvalue = '' />
	<cfset var a_item = 0 />
	<cfset var a_str_displayname = '' />
	<cfset var local = {} />
	
	<cfswitch expression="#arguments.itemtype#">
	
		<cfcase value="0">
			<!--- a TRACK has to be rated --->
			
			<!--- entrykey provided? --->
			<cfif Len(arguments.mediaitemkey) IS 0>
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1001 ) />
			</cfif>
	
			<!--- check access --->
			<cfset a_bol_check_access = application.beanFactory.getBean( 'SecurityComponent' ).CheckAccess(entrykey = arguments.mediaitemkey,
					securitycontext = arguments.securitycontext,
					type='mediaitem',
					ip = cgi.REMOTE_ADDR ).result />
					
			<cfif NOT a_bol_check_access>
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1001 ) />
			</cfif>
			
			<!--- delete old ratings --->
			<cfinclude template="queries/rating/q_delete_old_mediaitem_ratings.cfm">
			
			<cfset a_item = GetSimpleMediaItemInfo( arguments.mediaitemkey ) />
			
			<cfset a_str_hashvalue = getHashValueArtistTrack( a_item.getArtist(), a_item.getName() ) />
			<cfset arguments.mbid = a_item.getmb_trackid() />
			
			<!--- displayname --->
			<cfset a_str_displayname = GetMediaItemDisplayNameByEntrykey( arguments.mediaitemkey ) />
			
			<!--- insert strands event --->
			<!--- <cfset application.beanFactory.getBean( 'MyStrandsComponent' ).InsertStrandsEvent( mediaitemkey = arguments.mediaitemkey,
					action = 2,
					itemtype = 0,
					dt_action = Now(),
					username = arguments.securitycontext.username,
					unique_identifier = a_str_hashvalue,
					parameter = (arguments.rating / 20)) /> --->
			
			<cfset a_bol_result = true />
			<cfset a_int_log_no = 610 />
			
		</cfcase>
		<cfcase value="1">
			
			<!--- ALBUM ... --->
		
		</cfcase>
		<cfcase value="2">
			<!--- rate an ARTIST / BECOME A FAN! --->
			
			<!--- music brainz ID given? --->
			<cfif Val( arguments.mbid )IS 0>
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1001 ) />
			<cfelse>
			
				<cfset a_str_displayname = application.beanFactory.getBean( 'MusicBrainz' ).getArtistNameByID( arguments.mbid ) />
			
				<cfinclude template="queries/rating/q_delete_old_fan_artist_item.cfm">
			
				<!--- update number of fans! --->
				<cfset a_struct_update_artist_fans.add_one_fan = true />
				
				<!--- TODO FIX BECOMING FAN --->
				<cfset application.beanFactory.getBean( 'ContentComponent' ).CheckStoreUpdateCommonArtistInfo( mbartistid = arguments.mbid,
							data = a_struct_update_artist_fans ) />
			
				<!--- seems ok, proceed --->
				<cfset a_bol_result = true />
				<cfset a_int_log_no = 620 />
			</cfif>
			
			<!--- recalculate mbids --->
			<cfset ReculateFansOrArtist( arguments.securitycontext ) />
			
		</cfcase>
		<cfcase value="3">
		
			<!--- rate a PLAYLIST --->
			
			<!--- delete old ratings --->
			<cfinclude template="queries/rating/q_delete_old_mediaitem_ratings.cfm">			
			<cfset a_bol_result = true />
			
			<cfset a_str_displayname = application.beanFactory.getBean( 'PlaylistsComponent' ).getPlaylistDisplayNameData( entrykey = arguments.mediaitemkey ) />
		
		
		</cfcase>
	</cfswitch>
	
	<!--- access denied? exit! --->
	<cfif NOT a_bol_result>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 999 ) />	
	</cfif>
	
	<!--- edit log operation ... --->
	<cfset application.beanFactory.getBean( 'LogComponent' ).LogAction( securitycontext = arguments.securitycontext,
						action = a_int_log_no,
						linked_objectkey = arguments.mediaitemkey,
						objecttitle = a_str_displayname,
						param = arguments.rating,
						private = 0) />	
	
	<!--- insert into general rating table ... --->
	<cfset a_rating_item.setentrykey( CreateUUID() ) />
	<cfset a_rating_item.setdt_created( Now() ) />
	<cfset a_rating_item.setuserid( arguments.securitycontext.userid ) />
	<cfset a_rating_item.setuserkey( arguments.securitycontext.entrykey ) />
	<cfset a_rating_item.setmediaitemkey( arguments.mediaitemkey ) />
	<cfset a_rating_item.setrating( arguments.rating ) />
	<cfset a_rating_item.setmediaitemtype( arguments.itemtype ) />
	<cfset a_rating_item.sethashvalue( a_str_hashvalue ) />
	<cfset a_rating_item.setmbid( arguments.mbid ) />
	
	<cfif arguments.itemtype IS 0>
			
		<cfquery name="local.qSelectMediaitem_ID" datasource="mytunesbutleruserdata">
		SELECT id
		FROM
			mediaitems
		WHERE
			entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
		;
		</cfquery>
		
		<cfset a_rating_item.setmediaitem_id( VAl( local.qSelectMediaitem_ID.id ) ) />
	</cfif>
	
	<!--- save item --->
	<cftry>
		<cfset oTransfer.save( a_rating_item ) />
		

	<cfcatch type="any">
	
		<!--- 
		
			an error occured, return failure
		
		 --->
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, 'Could not save rating' ) />
		</cfcatch>
	</cftry>
	
	<!--- set plist avg rating --->
	<cfif arguments.itemtype IS 3>
		<cfinclude template="queries/rating/q_set_plist_avg_rating.cfm">
	</cfif>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="getItemRatings" output="false" returntype="struct" hint="return rating information for a single item">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="itemkey" type="string" required="true">
	<cfargument name="itemtype" type="numeric" default="0" required="false">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<!--- select old ratings for delete --->
	<cfset var a_str_basic_sql = 'SELECT rating.rating FROM mediaitems.rating AS rating WHERE rating.userkey = :userkey AND rating.mediaitemtype = :mediaitemtype AND rating.mediaitemkey = :mediaitemkey' />
	<cfset var a_tsql_query = oTransfer.createQuery(a_str_basic_sql) />
	
	<cfset a_tsql_query.setParam( 'userkey', arguments.securitycontext.entrykey, 'string' ) />
	<cfset a_tsql_query.setParam( 'mediaitemtype', arguments.itemtype, 'numeric' ) />
	<cfset a_tsql_query.setParam( 'mediaitemkey', arguments.itemkey, 'string' ) />
	
	<cfset stReturn.q_select_ratings = oTransfer.listByQuery(a_tsql_query) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<cffunction access="public" name="ReculateFansOrArtist" output="false" returntype="void"
		hint="calculate fans or artist">
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var qSelectArtistFans = 0 />
	<cfset var stUpdate = {} />
	
	<cfquery name="qSelectArtistFans" datasource="mytunesbutleruserdata">
	SELECT
		ratings.mbid
	FROM
		ratings
	WHERE
		ratings.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
		AND
		ratings.mediaitemtype = 2
	;
	</cfquery>
	
	<!--- set artist data --->
	<cfset stUpdate.artistfanids = ValueList( qSelectArtistFans.mbid ) />
	
	<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateUserData( securitycontext = arguments.securitycontext, newvalues = stUpdate ) />
	
</cffunction>

<cffunction access="public" name="GetCommonArtistInformation" output="false" returntype="struct"
		hint="return common artist information based on given criteria">
	<cfargument name="mbid" type="numeric" required="true"
		hint="musicbrainz ID of this artist">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ExtContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.readByProperty( 'commoninformation.common_artist_information', arguments.mbid) />
	
	<!--- return the item --->
	<cfset stReturn.a_item = a_item />
	
	<!--- does the item really exist? --->
	<cfset stReturn.exists = a_item.getIsPersisted() />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="getUniqueFirstCharsOfArtists" output="false" returntype="query">
	<cfargument name="securitycontext" type="struct" required="true" />
	
	<cfset var q_select_distinct_firstchar = 0 />
	
	<cfquery name="q_select_distinct_firstchar" datasource="mytunesbutleruserdata" cachedwithin="#application.udf.getQCacheTimeSpan()#">
	SELECT
		DISTINCT(UPPER( LEFT(artist, 1) ) ) AS first_char,
		COUNT(id) AS count_char,
		CONCAT(LEFT( GROUP_CONCAT( DISTINCT artist SEPARATOR ', ' ), 50), ' ...') AS artists
	FROM
		mediaitems
	WHERE
		userid = <cfqueryparam cfsqltype="cf_sql_integer"value="#arguments.securitycontext.userid#">
		AND
		LENGTH( artist ) > 0
	GROUP BY
		LEFT(artist, 1)
	ORDER BY
		UPPER(artist)
	;
	</cfquery>
	
	<cfreturn q_select_distinct_firstchar />

</cffunction>

</cfcomponent>