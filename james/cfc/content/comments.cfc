<!--- //

	Module:		Comments
	Action:		
	Description:	
	
// --->


<cfcomponent name="mediaitmes" displayname="Comments items component" output="false" hint="Handle Comments">
	
<cfsetting requesttimeout="2000">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.content.comments"> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction>

<cffunction access="public" name="GetComments" output="false" returntype="struct"
		hint="Get comments for a certain object">
	<cfargument name="itemtype" type="numeric" default="0" required="false"
		hint="0 = item, 1 = playlist">
	<cfargument name="mediaitemkey" type="string" required="false" default="">
	<cfargument name="artist" type="string" required="false" default=""
		hint="search for artist comments">
	<cfargument name="album" type="string" required="false" default="">
	<cfargument name="name" type="string" required="false" default="">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_str_basic_sql = 'SELECT comment.entrykey,comment.dt_created,comment.createdbyusername,comment.comment,comment.rating,comment.linked_object_artist,comment.linked_object_type,comment.linked_object_name,comment.linked_objectkey FROM comments.comment AS comment WHERE comment.rating = comment.rating AND comment.linked_object_type = :linked_object_type' />
	<cfset var a_str_filter_artist = ' AND comment.linked_object_artist = :linked_object_artist' />
	<cfset var a_str_filter_album = ' AND comment.linked_object_album = :linked_object_album' />
	<cfset var a_str_filter_name = ' AND comment.linked_object_name = :linked_object_name' />
	<cfset var a_str_filter_type = ' AND comment.linked_object_type = :linked_object_type' />
	<cfset var a_str_filter_key = ' AND comment.linked_objectkey = :linked_objectkey' />
	<cfset var a_bol_filter_artist = Len( arguments.artist ) GT 0 />
	<cfset var a_bol_filter_album = Len( arguments.album ) GT 0 />
	<cfset var a_bol_filter_name = Len( arguments.name ) GT 0 />	
	<cfset var a_str_sql = a_str_basic_sql />
	<cfset var a_tsql_query = 0 />
	<cfset var q_select_items = 0 />
	<cfset var a_str_order_by = ' ORDER BY comment.dt_created DESC' />
	
	<!--- check if any data is given in case of a media item --->
	<cfif arguments.itemtype IS 0 AND (Len( arguments.artist ) IS 0 AND Len( arguments.album ) IS 0 AND Len( arguments.name ) IS 0)>
		<cfset stReturn.args = arguments />
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- build SQL --->
	<cfif a_bol_filter_artist>
		<cfset a_str_sql = a_str_sql & a_str_filter_artist />
	</cfif>
	
	<cfif a_bol_filter_album>
		<cfset a_str_sql = a_str_sql & a_str_filter_album />
	</cfif>
	
	<cfif a_bol_filter_name>
		<cfset a_str_sql = a_str_sql & a_str_filter_name />
	</cfif>		
	
	<!--- playlist - filter by itemkey --->
	<cfif arguments.itemtype IS 1>
		<cfset a_str_sql = a_str_sql & a_str_filter_key />
	</cfif>
	
	<!--- build query --->
	<cfset a_tsql_query = oTransfer.createQuery( a_str_sql & a_str_order_by ) />
	
	<!--- set type --->
	<cfset a_tsql_query.setParam( 'linked_object_type', arguments.itemtype, 'numeric' ) />
	
	<!--- playlist - filter by itemkey --->
	<cfif arguments.itemtype IS 1>
		<cfset a_tsql_query.setParam( 'linked_objectkey', arguments.mediaitemkey, 'string' ) />
	</cfif>
	
	<cfif a_bol_filter_artist>
		<cfset a_tsql_query.setParam( 'linked_object_artist', arguments.artist, 'string' ) />
	</cfif>
	
	<cfif a_bol_filter_album>
		<cfset a_tsql_query.setParam( 'linked_object_album', arguments.album, 'string' ) />
	</cfif>
	
	<cfif a_bol_filter_name>
		<cfset a_tsql_query.setParam( 'linked_object_name', arguments.name, 'string' ) />
	</cfif>		
	
	<!--- do query --->
	<cfset q_select_items = oTransfer.listByQuery( a_tsql_query ) />
	
	<cfset stReturn.q_select_items = q_select_items />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="AddComment" output="false" returntype="struct"
		hint="store a comment (and in logbook as well)">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="comment" type="string" required="true">
	<cfargument name="linked_object_type" type="numeric" required="true"
		hint="itemtype ... 0 = item, 1 = playlist, 2 = user">
	<cfargument name="rating" type="numeric" default="0" required="false"
		hint="rating">
	<cfargument name="posttotwitter" type="boolean" required="false" default="false"
		hint="post to twitter?">
	<cfargument name="linked_objectkey" type="string" required="true"
		hint="to which object is this comment linked?">
	<cfargument name="linked_object_hashvalue" type="string" required="false" default=""
		hint="hash value of commented object ...">
	<cfargument name="affecteduserkey" type="string" required="true" default="">
	<cfargument name="tags" type="string" required="false" default=""
		hint="tags to set">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_cmp_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	<cfset var a_cmp_plist = application.beanFactory.getBean( 'PlaylistsComponent' ) />
	<cfset var a_cmp_log = application.beanfactory.getBean( 'LogComponent' ) />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />									
	<cfset var a_cmt_item = oTransfer.new( 'comments.comment' ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var tmp = 0 />
	<cfset var a_str_msg = '' />
	<cfset var a_commented_on_item = 0 />
	<cfset var a_playlist = 0 />
	<cfset var a_str_display_name = '' />
	<cfset var a_int_log_action = 0 />
	<cfset var a_str_http_dir = '' />
	
	<!--- if mediaitem and not found, exit --->
	<cfswitch expression="#arguments.linked_object_type#">
	
		<cfcase value="0">
			
			<!--- commented on a mediaitem --->
			<cfset a_commented_on_item = a_cmp_mediaitems.GetMediaItem( securitycontext = arguments.securitycontext,
											entrykey = arguments.linked_objectkey ) />
			<cfif NOT a_commented_on_item.result>
				<cfreturn a_commented_on_item />
			</cfif>
			
			<cfset a_str_display_name = a_cmp_mediaitems.GetMediaItemDisplayName( a_commented_on_item.item ) />
			
			<cfset a_cmt_item.setlinked_object_album( a_commented_on_item.item.getAlbum() ) />
			<cfset a_cmt_item.setlinked_object_artist( a_commented_on_item.item.getArtist() ) />
			<cfset a_cmt_item.setlinked_object_name( a_commented_on_item.item.getName() ) />
			
			<!--- log action no 600 --->
			<cfset a_int_log_action = 600 />
			<cfset a_str_http_dir = 'item' />
			
		</cfcase>
		<cfcase value="1">
			
			<!--- playlist --->
			
			<cfset a_commented_on_item = a_cmp_plist.getSimplePlaylistInfo( playlistkey = arguments.linked_objectkey,
											loaditems = false ) />
			<cfif NOT a_commented_on_item.result>
				<cfreturn a_commented_on_item />
			</cfif>
			
			<cfset a_str_display_name = a_commented_on_item.q_select_simple_plist_info.name />
			<cfset a_cmt_item.setlinked_object_name( a_str_display_name ) />
			
			
			<!--- log action no 601 --->
			<cfset a_int_log_action = 601 />	
			<cfset a_str_http_dir = 'playlist' />					
		
		</cfcase>
		
	</cfswitch>
	
	<!--- meta info --->	
	<cfset a_cmt_item.setEntrykey( a_str_entrykey ) />
	<cfset a_cmt_item.setdt_created( Now() ) />
	<cfset a_cmt_item.setCreatedbyuserkey( arguments.securitycontext.entrykey ) />
	<cfset a_cmt_item.setCreatedByusername( arguments.securitycontext.username ) />
		
	<!--- object --->
	<cfset a_cmt_item.setlinked_object_type( arguments.linked_object_type ) />
	<cfset a_cmt_item.setlinked_objectkey( arguments.linked_objectkey ) />
	<cfset a_cmt_item.setlinked_objecttitle( a_str_display_name ) />
	
	<!--- comment --->
	<cfset a_cmt_item.setComment( arguments.comment ) />
	<cfset a_cmt_item.setrating( arguments.rating ) />
	<cfset a_cmt_item.settags( arguments.tags ) />
	
	<!--- create item --->
	<cfset oTransfer.Save( a_cmt_item ) />
	
	<cfset stReturn.entrykey = a_str_entrykey />
	
	<!--- post to twitter? --->
	<cfif arguments.posttotwitter>
		
		<cfif Len( a_str_display_name ) GT 0>
			
			<cfset tmp = application.beanFactory.getBean( 'TwitterComponent' ).SendTwitterMessage( securitycontext = arguments.securitycontext,
												message = '"' & arguments.comment & '" on ' & a_str_display_name & ' http://www.tunesBag.com/' & a_str_http_dir & '/' & arguments.linked_objectkey & '/' ) />
		</cfif>
		
	</cfif>
	
	<!--- log this action --->
	<cfset a_cmp_log.LogAction( securitycontext = arguments.securitycontext,
						action = a_int_log_action,
						linked_objectkey = linked_objectkey,
						objecttitle = a_str_display_name,
						<!--- comment = param --->
						param = arguments.comment,
						private = 0) />	
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

</cfcomponent>