<!--- //

	Module:		Handle storage issues
	Action:		
	Description:	
	
// --->

<cfcomponent name="upload" displayname="upload component"output="false" hint="upload handler">

<cfinclude template="/common/scripts.cfm">

<cfsetting requesttimeout="200">

<cffunction name="init" access="public" output="false" returntype="james.cfc.log.log"> 
	<cfreturn this />
</cffunction>

<cffunction access="public" name="getRecentlyPlayedItemsUsers" output="false" returntype="query"
		hint="return users who have recently listend to an artist / album / track ... ">
	<cfargument name="artistid" type="numeric" required="false" default="0">
	<cfargument name="albumid" type="numeric" required="false" default="0">
	<cfargument name="trackid" type="numeric" required="false" default="0">
	<cfargument name="userkeys" type="string" required="false" default=""
		hint="list of userkeys">
	<cfargument name="maxagedays" type="numeric" required="false" default="21"
		hint="max age of data">
	<cfargument name="minseconds" type="numeric" required="false" default="30"
		hint="listened for at least n seconds to this track">
			
	<cfset var q_select_recent_listeners = 0 />
	<cfset var a_bol_hit = false />
	
	<cfinclude template="queries/q_select_recent_item_listeners.cfm">
	
	<cfreturn q_select_recent_listeners />	

</cffunction>

<cffunction access="public" name="LogStreamingNodeStat" output="false" returntype="void">
	<cfargument name="jobkey" type="string" required="true">
	<cfargument name="readfromcache" type="numeric" default="0" required="false">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'logging.streaming_convert_requests', arguments.jobkey ) />
		
	<cfif NOT a_item.getisPersisted()>
		<cfreturn />
	</cfif>

	<!--- save! --->
	<cfset a_item.setreadfromcache( arguments.readfromcache ) />
	<cfset oTransfer.save( a_item ) />

</cffunction>

<cffunction access="public" name="LogMediaItemPlayPingBySessionkey" output="false" returntype="void"
		hint="update playstatus by sessionkey/mediaitemkey">
	<cfargument name="sessionkey" type="string" required="true">
	<cfargument name="secondsplayed" type="numeric" required="true"
		hint="number of seconds">
	<cfargument name="mediaitemkey" type="string" required="true"
		hint="enrykey of item">
		
	<cfset var local = {} />
	
	<cfquery name="local.qUpdate" datasource="mytunesbutlerlogging">
	UPDATE
		playeditems
	SET
		secondsplayed = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.secondsplayed#">
	WHERE
		sessionkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sessionkey#">
		AND
		mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
	/* update the newest item */
	ORDER BY
		id DESC
	LIMIT
		1
	;
	</cfquery>

</cffunction>

<cffunction access="public" name="LogMediaItemPlayPingUserkey" output="false" returntype="void">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="secondsplayed" type="numeric" required="true"
		hint="number of seconds">
	<cfargument name="mediaitemkey" type="string" required="true"
		hint="enrykey of item">
		
	<cfset var q_update_seconds_played = 0 />
	<cfinclude template="queries/q_update_seconds_played.cfm">

</cffunction>

<cffunction access="public" name="LogMediaItemPlayPing" output="false" returntype="struct"
		hint="all 30 seconds, a ping is sent ..,">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="secondsplayed" type="numeric" required="true"
		hint="number of seconds">
	<cfargument name="mediaitemkey" type="string" required="true"
		hint="enrykey of item">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<cfset LogMediaItemPlayPingUserkey( userkey = arguments.securitycontext.entrykey, secondsplayed = arguments.secondsplayed, mediaitemkey = arguments.mediaitemkey ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

</cffunction>

<cffunction access="public" name="LogMediaItemLastAccess" output="false" returntype="void"
		hint="store the last time an item has been access (can be either playlist or media item)">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="itemkey" type="string" required="true">
	<cfargument name="itemtype" type="numeric" required="false" default="0">
	<cfargument name="dt" type="date" required="false" default="#Now()#">
	
	<cfset var qUpdate = 0 />
	<cfset var qInsert = 0 />
	<cfset var stResult = {} />
	
	<cfquery name="qUpdate" datasource="mytunesbutleruserdata" result="stResult">
	UPDATE
		timesaccessed
	SET
		lasttime = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dt#">,
		times = times + 1
	WHERE
		userid = <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.securitycontext.userid#">
		AND
		mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemkey#">
	;
	</cfquery>
	
	<!--- first time ... --->
	<cfif stResult.recordcount IS 0>
	
		<!--- insert --->
		<cfquery name="qInsert" datasource="mytunesbutleruserdata">
		INSERT INTO
			timesaccessed
			(			
			userkey,
			mediaitemkey,
			lasttime,
			times,
			userid,
			itemtype
			)
		VALUES
			(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemkey#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dt#">,
			1,
			<cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.securitycontext.userid#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.itemtype#">
			)
		;
		</cfquery>
	
	</cfif>
	
</cffunction>

<cffunction access="public" name="LogMediaItemPlayed" output="false" returntype="struct"
		hint="log an item play">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="ip" type="string" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="sessionkey" type="string" required="false" default=""
		hint="session run" />
	<cfargument name="item" type="any" required="true"
		hint="the transfer object with all meta infos">
	<cfargument name="applicationkey" type="string" default="" required="false"
		hint="entrykey of the app requesting the file">
	<cfargument name="preview" type="numeric" default="0" required="false"
		hint="is this a preview play?">
	<cfargument name="context" type="numeric" default="0" required="false"
		hint="context in which this item has been requested (manually selected, plist, recommendation etc)" />
	<cfargument name="secondsplayed" type="numeric" default="0" required="false"
		hint="Already set seconds to a certain value (might be because the device does not support callbacks)" />

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_log_key = CreateUUID() />
	<cfset var a_struct_item_data = {} />
	<cfset var a_int_own_track = 1 />
	<cfset var local = {} />
	
	<!--- last play --->
	<cfset LogMediaItemLastAccess( securitycontext = arguments.securitycontext, itemkey = arguments.mediaitemkey ) />
	
	<!--- not own track? --->
	<cfif NOT arguments.securitycontext.entrykey IS arguments.item.getuserkey()>
		<cfset a_int_own_track = 0 />
	</cfif>
	
	<!--- store meta data --->
	<cfset a_struct_item_data.userkey = arguments.item.getuserkey() />
	<cfset a_struct_item_data.mb_matchlevel = arguments.item.getmb_matchlevel() />					
	
	<cfset a_struct_item_data.artist = arguments.item.getartist() />
	<cfset a_struct_item_data.album = arguments.item.getalbum() />
	<cfset a_struct_item_data.track = arguments.item.getname() />	
	
	<cfquery name="local.qInsertPlayedItem" datasource="mytunesbutlerlogging">
	INSERT INTO
		playeditems
		(
		userkey,
		entrykey,
		mediaitemkey,
		userid,
		ip,
		countryisocode,
		dt_created,
		applicationkey,
		sessionkey,
		itemdata,
		licence_type,
		mb_artistid,
		mb_albumid,
		mb_trackid,
		preview,
		owntrack,
		context,
		dt_played_end,
		secondsplayed
		)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item.getuserkey()#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_log_key#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ip#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.beanFactory.getBean( 'LicenceComponent' ).IPLookupCountry( arguments.ip )#" />,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.applicationkey#" />,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sessionkey#" />,
		<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#SerializeJSON( a_struct_item_data )#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item.getlicence_type()#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item.getmb_artistid()#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item.getmb_albumid()#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item.getmb_trackid()#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.preview#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#a_int_own_track#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.context#" />,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.secondsplayed#" />
		)
	;
	</cfquery>
	
	<!--- return the entrykey --->
	<cfset stReturn.entrykey = a_str_log_key />
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
</cffunction>

<cffunction access="public" name="LogHotCacheRead" output="false" returntype="void"
		hint="Log a storage read">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of user">
	<cfargument name="mediaitemkey" type="string"
		hint="entrykey of item">
	<cfargument name="hashvalue" type="string"
		hint="hashvalue">
		
		
</cffunction>

<cffunction access="public" name="StoreMediaItemOldMetaData" output="false" returntype="void">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="mediaitemkey" type="string" required="true">
	<cfargument name="data" type="any" required="true"
		hint="query">
	<cfargument name="source" type="string" required="false" default=""
		hint="source of edit operation">
		
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.new( 'logging.mediaitems_metadata_revisions' ) />
	<cfset var a_wddx = 0 />
	
	<cfwddx input="#arguments.data#" output="a_wddx" action="cfml2wddx" />
	
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setsource( arguments.source ) />
	<cfset a_item.setwddx( a_wddx ) />
	<cfset a_item.setuserkey( arguments.userkey ) />
	<cfset a_item.setmediaitemkey( arguments.mediaitemkey )  />
	
	<cfset oTransfer.create( a_item ) />

</cffunction>

<cffunction access="public" name="LogAction" output="false" returntype="string"
		hint="log a certain action to logbook">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="action" type="numeric" required="true"
		hint="see transfer.xml for description">
	<cfargument name="affecteduserkey" type="string" required="false" default=""
		hint="user who is affected by action - if empty, same user">
	<cfargument name="linked_objectkey" type="string" required="false" default=""
		hint="entrykey of object">
	<cfargument name="objecttitle" type="string" required="false" default=""
		hint="name of object">
	<cfargument name="param" type="string" required="false" default=""
		hint="parameter">
	<cfargument name="private" type="numeric" default="0" required="false"
		hint="private or not">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />									
	<cfset var a_log_item = oTransfer.new( 'logbook.logitems' ) />
	<cfset var iAffectedUserid = application.beanFactory.getBean( 'UserComponent' ).GetUseridByEntrykey( arguments.affecteduserkey ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var q_delete_old_same_log_item = 0 />
	
	<!--- "self" action --->
	<cfif Len( arguments.affecteduserkey ) IS 0>
		<cfset arguments.affecteduserkey = arguments.securitycontext.entrykey />
		<cfset iAffectedUserid = arguments.securitycontext.userid />
	</cfif>
	
	<!--- for certain actions, check out if we have to delete the same action from the list ...
			the same action happend less than 3 weeks ago --->
	<cfinclude template="queries/q_delete_old_same_log_item.cfm">
	
	<!---  create the new item --->
	<cfset a_log_item.setcreatedbyuserkey( arguments.securitycontext.entrykey ) />
	<cfset a_log_item.setcreatedbyusername( arguments.securitycontext.username ) />
	<cfset a_log_item.setcreatedbyuserid( arguments.securitycontext.userid ) />
	<cfset a_log_item.setaction( arguments.action ) />
	<cfset a_log_item.setEntrykey( a_str_entrykey ) />
	<cfset a_log_item.setaffecteduserkey( arguments.affecteduserkey ) />
	<cfset a_log_item.setaffecteduserid( iAffectedUserid ) />
	<cfset a_log_item.setlinked_objectkey( arguments.linked_objectkey ) />
	<cfset a_log_item.setobjecttitle( arguments.objecttitle ) />	
	<cfset a_log_item.setprivate( arguments.private ) />
	<cfset a_log_item.setparam( arguments.param ) />
	
	<cfset oTransfer.save( a_log_item ) />	
	<cfreturn a_str_entrykey />
	
</cffunction>

<cffunction access="public" name="GetLogItems" output="false" returntype="struct"
		hint="return the log items">
	<cfargument name="securitycontext" type="struct" required="true" />
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#">
	<cfargument name="maxrows" type="numeric" required="false" default="30">
	<cfargument name="maxagedays" type="numeric" required="false" default="0"
		hint="max age of item in days">
	<cfargument name="sincedate" type="numeric" required="false" default="0"
		hint="only news since date sincedate">
	<cfargument name="options" type="string" required="false" default=""
		hint="options for this call">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_log_items = 0 />
	<cfset var sFriendUserids = application.beanFactory.getBean( 'SocialComponent' ).GetAllFriendUserids( securitycontext = arguments.securitycontext ) />
		<!--- select items
		a) with friends of user
		b) this user is affected --->
	
	<cfinclude template="queries/q_select_log_items.cfm">	
	
	<cfset stReturn.q_select_log_items = q_select_log_items />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="getSingleStatusLogItem" output="false" returntype="struct"
		hint="return a single log item">
	<cfargument name="entrykey" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_single_log_item = 0 />
	
	<cfinclude template="queries/q_select_single_log_item.cfm">	
	
	<cfset stReturn.q_select_log_item = q_select_single_log_item />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="GetLastUserActivities" output="false" returntype="struct"
		hint="return the last activities of this user / where this user has been affected">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="filter" type="struct" required="false" default="#StructNew()#"
		hint="e.g. only certain actions">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_last_log_items_of_this_user = 0 />
	
	<cfinclude template="queries/q_select_last_log_items_of_this_user.cfm">
	
	<cfset stReturn.q_select_log_items = q_select_last_log_items_of_this_user />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<cffunction access="public" name="getImageNameForLogEvent" output="false" returntype="string"
		hint="return image for action number">
	<cfargument name="action" type="numeric" required="true">	
	
	<cfset var a_str_return = 'orange_bullet' />
	
	<cfswitch expression="#arguments.action#">
	<cfcase value="100">
		<cfset a_str_return = 'page_white_cd' />
	</cfcase>
	<cfcase value="110">
		<cfset a_str_return = 'link' />
	</cfcase>
	<cfcase value="500">
		<cfset a_str_return = 'thumb_up' />	
	</cfcase>
	<cfcase value="600,601">
		<cfset a_str_return = 'comment' />
	</cfcase>
	<cfcase value="610">
		<cfset a_str_return = 'star' />
	</cfcase>
	<cfcase value="620">
		<cfset a_str_return = 'heart' />
	</cfcase>
	<cfcase value="802">
		<cfset a_str_return = 'group_add' />
	</cfcase>
	</cfswitch>
	
	<cfreturn a_str_return />

</cffunction>

<cffunction access="public" name="getPublicEventLinkOfLogItem" output="false" returntype="string"
		hint="get the public link for an event">
	<cfargument name="objecttitle" type="string" required="true">
	<cfargument name="action" type="numeric" required="true">
	<cfargument name="linked_objectkey" type="string" required="true">
	
	<cfset var a_str_return = '' />
	
	<cfswitch expression="#arguments.action#">
		<cfcase value="100,110">
			<!--- <cfset a_str_return = generateURLToPlist( arguments.linked_objectkey, arguments.objecttitle, false ) /> --->
			<cfset a_str_return = '/rd/plist/?entrykey=' & arguments.linked_objectkey />
		</cfcase>
		<cfcase value="610,600,500">
			<cfset a_str_return = '/item/' & arguments.linked_objectkey />
		</cfcase>
		<cfcase value="601">
			<!--- comment on playlist --->
			<cfset a_str_return = generateURLToPlist( arguments.linked_objectkey, arguments.objecttitle, false ) />
		</cfcase>
		<cfcase value="620">
			<cfset a_str_return = application.udf.generateArtistURL( arguments.objecttitle, 0 ) />
		</cfcase>
		<cfcase value="802">
			<cfset a_str_return = '/user/' & arguments.objecttitle />
		</cfcase>
	</cfswitch>
	
	<cfreturn a_str_return />

</cffunction>

<cffunction access="public" name="FormatSingleLogItem" output="false" returntype="string"
		hint="format a single log item (same on newsfeed and so on)">
	<cfargument name="entrykey" type="string" required="true">
	<cfargument name="dt_created" type="date" required="true">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="affecteduserkey" type="string" required="true">
	<cfargument name="action" type="numeric" required="true">
	<cfargument name="param" type="string" required="true">
	<cfargument name="objecttitle" type="string" required="true">
	<cfargument name="pic" type="string" required="true">
	<cfargument name="linked_objectkey" type="string" required="true">
	<cfargument name="createdbyusername" type="string" required="true">
	<cfargument name="options" type="string" required="false" default=""
		hint="various options, currently supported: small (smaller display), nouserimage (no user image)">
	
	<cfset var a_str_return = '' />	
	<cfset var a_str_text = '' />
	<cfset var a_str_date = '' />
	<cfset var a_replace = '' />
	<cfset var a_bol_display_date = true />
	<cfset var a_str_img_name = '' />
	<cfset var a_dt_diff = DateDiff( 'd', arguments.dt_created, Now() ) />
	
	<cfif a_dt_diff LTE 3>
		<cfset a_dt_diff = 3 />
	<cfelseif a_dt_diff LTE 21>
		<cfset a_dt_diff = 21 />
	<cfelse>
		<cfset a_dt_diff = 99 />
	</cfif>

	<cfinclude template="utils/inc_format_single_log_item.cfm">
	
	<cfreturn a_str_return />
	
</cffunction>

<cffunction access="public" name="logArtistRelatedPageHit" output="false" returntype="void"
		hint="log if the artist page or album or an artist or track has been visitied">
	<cfargument name="iMBartistid" type="numeric" required="true" />	
	<cfargument name="sSessionHash" type="string" required="true"
		hint="hash of session" />
	<cfargument name="dCreated" type="date" default="#Now()#" required="false" />
	<cfargument name="iPage_Type" type="numeric" required="true"
		hint="0 = artist page, 1 = album, 2 = track" />
	<cfargument name="iPublic_Hit" type="numeric" required="false" default="1"
		hint="true or false, public = not a registered user" />
	<cfargument name="iAsset_MBID" type="numeric" required="false" default="0"
		hint="the track or album id of available" />
	<cfargument name="bSpiderHit" type="Boolean" required="false" default="false" />
	
	<cfset var local = {} />
	
	<cfif arguments.bSpiderHit OR (FindNoCase( 'Googlebot', cgi.HTTP_USER_AGENT ) GT 0)>
		<cfreturn />
	</cfif>
	
	<cfquery name="local.qInsert" datasource="mytunesbutlerlogging">
	INSERT DELAYED INTO
		artist_visit_log
		(
		mbartistid,
		dt_created,
		page_type,
		public_hit,
		asset_mbid
		)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMBartistid#" />,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.dCreated#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iPage_Type#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iPublic_Hit#" />,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iAsset_MBID#" />
		)
	;
	</cfquery>

</cffunction>

</cfcomponent>