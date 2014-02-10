<!--- //

	Module:		
	Action:		Social network (friends, invitations, ...)
	
// --->

<cfcomponent output="false">
	
	<cfprocessingdirective pageencoding="utf-8" />

	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="GetAllFriendUserids" output="false" returntype="string"
		hint="return list of userids of friends">
		<cfargument name="securitycontext" type="struct" required="true" />
		
		<cfset var sReturn = 0 />
		<cfset var ii = 0 />
		
		<cfloop from="1" to="#ArrayLen( arguments.securitycontext.friends )#" index="ii">
			<cfset sReturn = ListAppend( sReturn, arguments.securitycontext.friends[ ii ].userid ) />
		</cfloop>
		
		<cfreturn sReturn />
	</cffunction>
	
	<cffunction access="public" name="UpdateRecommendedItemAsRead" output="false" returntype="void">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="mediaitemkey" type="string" required="true">
		
		<cfset var q_select_shared_items_list = 0 />
		<cfset var q_update_set_rec_read = 0 />
		
		<cfinclude template="queries/sharing/q_update_set_rec_read.cfm">
		
		<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateStatusCounterItems( securitycontext = arguments.securitycontext,
							property = 'unreadshareditems' ) />
		
	</cffunction>
	
	<cffunction access="private" name="SendShareItemMail" output="false" returntype="void" hint="send the email with the sharing information">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="title" type="string" required="true"
			hint="name of item">
		<cfargument name="firstname" type="string" required="true" default="">
		<cfargument name="surname" type="string" required="true" default="">
		<cfargument name="recipient" type="string" required="true"
			hint="the email address of the recipient">
		<cfargument name="link" type="string" required="true"
			hint="full link to item">
		<cfargument name="comment" type="string" required="true">
		<cfargument name="isuser" type="boolean" required="true" default="false"
			hint="a registered user on the system?">
		<cfargument name="itemtype" type="numeric" required="false" />
		
		<cfset var a_subject = '' />
		<cfset var a_arr_data = '' />
		<cfset var sHTMLMail = ''/>
		<cfset var sTextMail = '' />
		<cfset var stUserData = {} />
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
		<cfset var a_str_recipient = Trim( arguments.firstname & ' ' & arguments.surname & ' <' & arguments.recipient & '>') />
			
		<cfinclude template="utils/inc_send_recommendation_mail.cfm">
	
	</cffunction>
	
	<cffunction access="public" name="getSentSharedItems" output="false" returntype="struct" hint="return all item sharings by this user">
		<cfargument name="securitycontext" type="struct" required="true">
	
	
	</cffunction>
	
	<cffunction access="public" name="ShareItem" output="false" returntype="struct" hint="share an item">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="itemtype" type="numeric" required="true"
			hint="type of item">
		<cfargument name="title" type="string" required="true"
			hint="name of item">
		<cfargument name="identifier" type="string" required="true"
			hint="depending on the type ... can be the entrykey or just the artist name">
		<cfargument name="recipients" type="string" required="true"
			hint="list of recipients">
		<cfargument name="comment" type="string" required="false" default=""
			hint="comment to add">
		<cfargument name="url" type="string" required="true"
			hint="url to link to for this item">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_entrykey = createUUID() />
		<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'social.shareditems' ) />
		<cfset var a_content_item = 0 />
		<cfset var a_str_recipient = 0 />
		<cfset var a_str_mail_address = 0 />
		<cfset var a_userdata = 0 />
		<cfset var a_str_firstname = 0 />
		<cfset var a_str_surname = 0 />
		<cfset var a_str_url = '' />
		<cfset var a_recipient_type = 'unknown' />
		<cfset var a_bol_firstlog = true />
		
		<!--- get friends list --->
		<cfset var q_select_friends = GetFriendsList( securitycontext = arguments.securitycontext ).q_select_friends />
		
		<cfif Len( arguments.recipients ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'no recipients given') />
		</cfif>
		
		<!---<cfif Len( arguments.url ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>--->
		
		<cfif Len( arguments.identifier ) IS 0>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999, 'missing identifier') />
		</cfif>
		
		<!--- url has to be generated ... --->
		<cfif Len( arguments.url ) IS 0>
		
			<cfswitch expression="#arguments.itemtype#">
				<cfcase value="1">
					<!--- track --->
					<cfset a_content_item = oTransfer.get( 'mediaitems.mediaitem', arguments.identifier ) />

					<cfset a_str_url = 'http://www.tunesBag.com' & generateGenericURLToTrack( a_content_item.getArtist(), a_content_item.getName(), a_content_item.getmb_trackid(), a_content_item.getentrykey() ) />
				</cfcase>
				<cfcase value="2">
					<!--- plist --->
					<cfset a_str_url = generateURLToPlist( arguments.identifier, arguments.title, true ) />
				</cfcase>
				<cfcase value="3">
					<!--- artist --->
					<cfset a_str_url = 'http://www.tunesBag.com' & application.udf.generateArtistURL( arguments.title, 0 ) />
				</cfcase>
			</cfswitch>			
		
		</cfif>
		
		<!--- insert into database --->
		<cfset oItem.setentrykey( a_entrykey ) />
		<cfset oItem.setdt_created( Now() ) />
		<cfset oItem.setcreatedbyuserkey( arguments.securitycontext.entrykey ) />
		<cfset oItem.setidentifier( arguments.identifier ) />
		<cfset oItem.setrecipients( arguments.recipients ) />
		<cfset oItem.setitemtype( arguments.itemtype ) />
		<cfset oItem.setcomment( arguments.comment ) />
		<cfset oItem.settitle( arguments.title ) />
		<cfset oItem.sethref( arguments.url ) />
		
		<cfset oTransfer.create( oItem ) />
		
		<cfset stReturn.entrykey = a_entrykey />
		
		<!--- ok, how to inform the other user? EMAIL! --->
		<cfloop list="#arguments.recipients#" delimiters=",; " index="a_str_recipient">
			
			<cfset a_str_mail_address = '' />
			<cfset a_str_firstname = '' />
			<cfset a_str_surname = '' />
			
			<cfset a_str_recipient = trim( a_str_recipient ) />
				
			<!--- A) email address --->
			<cfif FindNoCase( 'mailto:', a_str_recipient) IS 1>
			
				<!--- send by mail --->
				<cfset a_str_mail_address = application.udf.ExtractEmailAdr( ReplaceNoCase( a_str_recipient, 'mailto:', '' )) />
				
				<cfset a_recipient_type = 'mail' />

			
			<!--- B) tunesBag user --->
			<cfelseif FindNoCase( 'user:', a_str_recipient ) IS 1>
			
				<!--- real user - friend of user? check if this user is a friend and get out the email address --->
				<cfset a_str_recipient = ReplaceNoCase( a_str_recipient, 'user:', '' ) />
				
				<cfset a_recipient_type = 'user' />
				
				<cfset var q_select_is_friend = 0 />
				
				<cfquery name="q_select_is_friend" dbtype="query">
				SELECT
					otheruserkey
				FROM
					q_select_friends
				WHERE
					UPPER( displayname ) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#uCase( a_str_recipient )#">
				;
				</cfquery>
				
				<!--- HIT? --->
				<cfif q_select_is_friend.recordcount IS 1 AND Len( q_select_is_friend.otheruserkey ) GT 0>
				
					<!--- try to load userdata --->					
					<cfset a_userdata = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = q_select_is_friend.otheruserkey ) />
					
					<!--- user exists! --->
					<cfif a_userdata.result>
					
						<!--- set address --->
						<cfset a_str_mail_address = application.udf.ExtractEmailAdr( a_userdata.a_struct_item.getemail() ) />
						<cfset a_str_firstname = a_userdata.a_struct_item.getFirstname() />
						<cfset a_str_surname = a_userdata.a_struct_item.getsurname() />
												
						<!--- store as plist item (just a lookup table) --->						
						<cfset oItem = oTransfer.new( 'social.shareditems_autoplist' ) />
						<cfset oItem.setUserkey( a_userdata.a_struct_item.getEntrykey() ) />
						<cfset oItem.setShareKey( a_entrykey ) />
						
						<!--- create! --->
						<cfset oTransfer.create( oItem ) />
						
						<!--- save the first item to the logbook --->
						<cfif (arguments.itemtype IS 1) AND a_bol_firstlog>
							
							<cfset application.beanFactory.getBean( 'LogComponent' ).LogAction( securitycontext = arguments.securitycontext,
								action = 500,
								affecteduserkey = a_userdata.a_struct_item.getEntrykey(),
								param =  a_userdata.a_struct_item.getUsername(),
								linked_objectkey = arguments.identifier,
								objecttitle = arguments.title ) />
								
							<cfset a_bol_firstlog = false />
								
						</cfif>
						
						<!--- update number of unread items --->
						<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateStatusCounterItems( property = 'unreadshareditems',
										securitycontext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = a_userdata.a_struct_item.getEntrykey() )) />
					
					</cfif>
				
				</cfif>
				
				
			<!--- myspace user --->
			<cfelseif FindNoCase( 'myspsace:', a_str_recipient ) IS 1>
			
				<cfset a_recipient_type = 'myspace' />
			
			<!--- C) Facebook user --->	
			<cfelseif FindNoCase( 'facebook:', a_str_recipient ) IS 1>
			
				<cfset a_recipient_type = 'facebook' />
			
			<!--- D) SMS --->
			<cfelseif FindNoCase( 'sms:', a_str_recipient ) IS 1>
			
				<cfset a_recipient_type = 'sms' />
			
			</cfif>
			
			<!--- send mail --->
			<cfif Len( a_str_mail_address ) GT 0>
				
				<cfset SendShareItemMail( securitycontext = arguments.securitycontext,
							title = arguments.title,
							recipient = a_str_mail_address,
							firstname = a_str_firstname,
							surname = a_str_surname,
							link = arguments.url & '?rec',
							comment = arguments.comment,
							itemtype = arguments.itemtype,
							isuser = (a_recipient_type IS 'user') ) />
			
			</cfif>

		</cfloop>
				
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="DeleteSharedItem" output="false" returntype="void" hint="delete the given shared item">
		<cfargument name="entrykey" type="string" required="true">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.get( 'social.shareditems', arguments.entrykey ) />
		<cfset var a_mediaitemkey = oItem.getMediaitemkey() />

		<cfset oTransfer.delete( oItem ) />	
		
		<cfset oItem = oTransfer.get( 'social.shareditems_autoplist', a_mediaitemkey ) />
		<cfset oTransfer.delete( oItem ) />
	
	</cffunction>
	
	<cffunction access="public" name="CancelFriendship" output="false" returntype="struct" hint="cancel friendship">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="friendshipkey" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_map = {userkey=arguments.securitycontext.entrykey,entrykey=arguments.friendshipkey}/>
		<cfset var oItem = oTransfer.readByPropertyMap( 'users.friend', a_map ) />
		
		<!--- found? --->
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002) />
		<cfelse>
			
			<!--- delete the item --->
			<cfset oTransfer.delete( oItem ) />
		
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />		
		</cfif>
	
	</cffunction>

	<cffunction access="public" name="AddFriend" output="false" returntype="struct" hint="Add a friend">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="photourl" type="string" required="false" default="">
		<cfargument name="taste" type="string" required="false" default="">
		<cfargument name="source" type="numeric" default="0"
			hint="the source of this friend ... 0 = internal system, 1 = facebook">
		<cfargument name="otherusername" type="string" required="false" default=""
			hint="if an internal system user">
		<cfargument name="otheruserkey" type="string" required="false" default=""
			hint="if an internal system user">
		<cfargument name="accesslibrary" type="numeric" default="1" required="false"
			hint="allowed to access data?">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'users.friend' ) />
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var a_struct_already_exists = false />
		<cfset var a_struct_friend_securitycontext = 0 />
		<cfset var a_map_query = StructNew() />
		<cfset var iOtherUserid = Val( application.beanFactory.getBean( 'UserComponent' ).GetUseridByEntrykey( arguments.otheruserkey )) />
		
		<!--- cannot add yourself --->
		<cfif arguments.securitycontext.entrykey IS arguments.otheruserkey>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfif Len( arguments.otheruserkey ) IS 0 AND Len( arguments.otherusername ) GT 0>
			<!--- set the given userkey --->
			<cfset arguments.otheruserkey = application.beanFactory.getBean( 'UserComponent' ).GetEntrykeyByUsername( username = arguments.otherusername ) />
		</cfif>
		
		<!--- does the user already exist? --->
		<cfset a_struct_already_exists = FriendAlreadyExists( securitycontext = arguments.securitycontext,
									otheruserkey = arguments.otheruserkey,
									source = arguments.source ) />
									
		<!--- already exists ... get item by it's entrykey for update --->
		<cfif a_struct_already_exists.result>
			<cfset oItem = oTransfer.get( 'users.friend', a_struct_already_exists.entrykey) />
		<cfelse>
			<cfset oItem.setdt_created( Now() ) />
			<cfset oItem.setentrykey( a_str_entrykey ) />
			<cfset oItem.setuserkey( arguments.securitycontext.entrykey ) />
			<cfset oItem.setcreatedbyuserkey( arguments.securitycontext.entrykey ) />
		</cfif>
				<cfmail from="hansjoerg@tunesbag.com" to="hansjoerg@tunesbag.com" subject="test" type="html">
		<cfdump var="#arguments#">
		<cfdump var="#iOtherUserid#">
		</cfmail>
		<!--- store data --->
		<cfset oItem.setdisplayname( Mid( arguments.name, 1, 100 ) ) />
		<cfset oItem.setphotourl( arguments.photourl ) />
		<cfset oItem.setsource( Int(Val( arguments.source ))) />
		<cfset oItem.setotheruserkey( arguments.otheruserkey) />
		<cfset oItem.settaste( Mid( arguments.taste, 1, 250 ) ) />
		<cfset oItem.setaccesslibrary( arguments.accesslibrary ) />
		
		<!--- set userid as well --->
		<cfset oItem.setuser1_id( arguments.securitycontext.userid ) />
		<cfset oItem.setuser2_id( iOtherUserid ) />
		
		<cfset oTransfer.save( oItem ) />
		
		<cfset oItem = 0 />
		
		<!--- let's insert the friend the other way 'round as well .... only if the friend is a REAL user --->
		<cfif Len( arguments.otheruserkey ) GT 0>
			<cfset a_struct_friend_securitycontext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = arguments.otheruserkey ) />
			
			<!--- insert into DB ... --->
			<cfset InternalSaveFriendSetting( userkey = arguments.otheruserkey,
								userid = iOtherUserid,
								displayname = arguments.securitycontext.username,
								otheruserkey = arguments.securitycontext.entrykey,
								otheruserid = arguments.securitycontext.userid,
								createdbyuserkey = arguments.securitycontext.entrykey,
								accesslibrary = arguments.accesslibrary ) />
			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="private" name="InternalSaveFriendSetting" output="false" returntype="boolean"
			hint="store friendship in database internally">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="userid" type="numeric" required="true" />
		<cfargument name="displayname" type="string" required="true">
		<cfargument name="otheruserkey" type="string" required="true">
		<cfargument name="otheruserid" type="numeric" required="true" />
		<cfargument name="createdbyuserkey" type="string" required="true">
		<cfargument name="accesslibrary" type="numeric" default="0" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = 0 />
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var a_map_query = StructNew() />

		<!--- search for userkey / otheruserkey connection ... --->		
		<cfset a_map_query.userkey = arguments.userkey />
		<cfset a_map_query.otheruserkey = arguments.otheruserkey />
			
		<cfset oItem = oTransfer.readByPropertyMap( 'users.friend', a_map_query ) />
		
		<!--- already stored --->
		<cfif oItem.getIsPersisted()>
			<cfreturn true />
		</cfif>
		
		<cfset oItem.setuser1_id( arguments.userid ) />
		<cfset oItem.setuser2_id( arguments.otheruserid ) />
		<cfset oItem.setuserkey( arguments.userkey ) />
		<cfset oItem.setotheruserkey( arguments.otheruserkey ) />		
		<cfset oItem.setcreatedbyuserkey( arguments.createdbyuserkey ) />	
		<cfset oItem.setdt_created( Now() ) />		
		<cfset oItem.setEntrykey( CreateUUID() ) />
		<cfset oItem.setaccesslibrary( arguments.accesslibrary ) />	
		<cfset oItem.setdisplayname( arguments.displayname ) />
		
		<cfset oTransfer.save( oItem ) />
		
		<cfreturn true />

	</cffunction>
	
	<cffunction access="public" name="RemoveFriend" output="false" returntype="struct" hint="Remove a friend">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="friendkey" type="string" required="true">
	</cffunction>
	
	<cffunction access="public" name="EditFriendSettings" output="false" returntype="struct" hint="Edit friend settings (e.g. library access)">
		
	</cffunction>
	
	<cffunction access="public" name="GetWaitingFriendShipRequests" output="false" returntype="struct"
			hint="Return the number of waiting requests">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		
		<cfset var q_select_requests = oTransfer.listByProperty( 'users.friendship_request', 'otheruserkey', arguments.securitycontext.entrykey ) />
		
		<cfset stReturn.q_select_requests = q_select_requests />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="FriendShipRequestAnswer" output="false" returntype="struct"
			hint="perform action based on answer of user">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="requestkey" type="string" required="true">
		<cfargument name="answer" type="numeric" required="true" hint="0 = no, 1 = yes">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_cmp_log = application.beanfactory.getBean( 'LogComponent' ) />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.get( 'users.friendship_request', arguments.requestkey ) />
		<cfset var a_struct_sec_context = StructNew() />
		<cfset var a_struct_user_added = application.beanFactory.getBean( 'UserComponent' ).GetUserData( oItem.getotheruserkey() ) />
		<cfset var a_struct_user_requesting = application.beanFactory.getBean( 'UserComponent' ).GetUserData( oItem.getcreatedbyuserkey() ) />
		
		<cfif arguments.answer IS 1>
			
			<!--- add friends, send notification --->
			<cfset a_struct_sec_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = oItem.getcreatedbyuserkey() ) />
			
			<!--- add friend --->
			<cfset stReturn = AddFriend( securitycontext = a_struct_sec_context,
							name = a_struct_user_added.a_struct_item.getUsername(),
							source = 0,
							otheruserkey = oItem.getOtherUserkey(),
							accesslibrary = 1 ) />

<cftry>
<cfmail from="tunesBag <no-reply@tunesBag.com>" subject="[tunesBag] Friendship request accepted" to="#a_struct_user_requesting.a_struct_item.getEmail()#">
<cfmailparam name="Sender" value="mail@tunesBag.com">
#a_struct_user_requesting.a_struct_item.getFirstName()# -

You and #a_struct_user_added.a_struct_item.getUsername()# are now friends on tunesBag!

Profile of #a_struct_user_added.a_struct_item.getUsername()#: http://www.tunesBag.com/user/#a_struct_user_added.a_struct_item.getUsername()#

-- Your tunesBag.com team
</cfmail>
<cfcatch type="any"></cfcatch></cftry>

			<!--- log this as event --->
			<cfset a_cmp_log.LogAction( securitycontext = a_struct_sec_context,
						action = 802,
						affecteduserkey = oItem.getOtherUserkey(),
						linked_objectkey = oItem.getOtherUserkey(),
						objecttitle = a_struct_user_added.a_struct_item.getUsername()) />	

		</cfif>
		
		<!--- delete request --->
		<cfset oTransfer.delete( oItem ) />
		
		<!--- update counter --->
		<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateStatusCounterItems( securitycontext = arguments.securitycontext, property = 'openfriendshiprequests' ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="RequestFriendShip" output="false" returntype="struct" hint="request friendship">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="otheruserkey" type="string" required="true"
			hint="entrykey of the other user">
		<cfargument name="customtext" type="string" required="false" default="">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'users.friendship_request' ) />
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var a_struct_user_from = application.beanFactory.getBean( 'UserComponent' ).GetUserData( arguments.securitycontext.entrykey ) />		
		<cfset var a_struct_user_to = application.beanFactory.getBean( 'UserComponent' ).GetUserData( arguments.otheruserkey ) />
		<cfset var a_struct_other_sec_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( arguments.otheruserkey ) />
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
		<cfset var stUserdata = {} />
		<cfset var sHTMLMail = ''/>
		<cfset var sTextMail = '' />
		
		<cfif arguments.securitycontext.entrykey IS arguments.otheruserkey>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />		
		</cfif>
		
		<cfset oItem.setEntrykey( a_str_entrykey ) />
		<cfset oItem.setCreatedByUserkey( arguments.securitycontext.entrykey ) />
		<cfset oItem.setOtherUserkey( arguments.otheruserkey ) />
		<cfset oItem.setdt_created( Now() ) />
		<cfset oItem.setcustomText( arguments.customtext ) />
		
		<cfset oTransfer.save( oItem ) />
		
		<!--- update openFriendShipProperty of users --->
		<cfset application.beanFactory.getBean( 'UserComponent' ).UpdateStatusCounterItems( securitycontext = a_struct_other_sec_context, property = 'openfriendshiprequests' ) />
		
		
		<!--- send a notification to the other user --->
		<cfset stUserdata = { entrykey = a_struct_user_to.a_struct_item.getEntrykey(), firstname = a_struct_user_to.a_struct_item.getFirstName(), email = a_struct_user_to.a_struct_item.getEmail(), username = a_struct_user_to.a_struct_item.getUsername() } />
	
	
<cfsavecontent variable="sTextMail"><cfoutput>
#a_struct_user_from.a_struct_item.getFirstName()# would like to be your friend on tunesBag.com and share great stuff with you.

<cfif Len( arguments.customtext ) GT 0>#arguments.customtext#</cfif>

Accept or deny this request here: http://www.tunesBag.com/rd/start/

Profile of #a_struct_user_from.a_struct_item.getFirstName()#: http://www.tunesBag.com/user/#a_struct_user_from.a_struct_item.getUsername()#

--- Your tunesBag.com team
</cfoutput></cfsavecontent>

<cfsavecontent variable="sHTMLMail"><cfoutput>
<p>
	<img src="http://www.tunesBag.com/#application.udf.getUserImageLink( a_struct_user_from.a_struct_item.getUsername(), 75 )#" style="height:36px;width:36px;vertical-align:middle" align="absmiddle" border="0" alt="user" />
	#a_struct_user_from.a_struct_item.getFirstName()# would like to be your friend on tunesBag.com and share great stuff with you.
</p>

<cfif Len( arguments.customtext ) GT 0><p>#arguments.customtext#</p></cfif>

<p>
	<a href="http://www.tunesBag.com/rd/start/">Accept or deny this request</a>
</p>

<p>
<a href="http://www.tunesBag.com/user/#a_struct_user_from.a_struct_item.getUsername()#">Profile of #a_struct_user_from.a_struct_item.getFirstName()#</a>
</p>

<p>
--- Your tunesBag.com team
</p>
</cfoutput>
</cfsavecontent>

	<cfreturn oMsg.sendGenericEmail( bIsRegisteredUser = true, sSubject = application.udf.GetLangValSec( 'mail_ph_subject_friendship_request', a_struct_user_from.a_struct_item.getFirstName()), sSender = 'tunesBag.com <no-reply@tunesBag.com>', sTo = a_struct_user_to.a_struct_item.getFirstname() & ' <' & a_struct_user_to.a_struct_item.getEmail() & '>', sHTMLContent = sHTMLMail, sTextContent = sTextMail, stUserData = stUserData ) />

		<cfset stReturn.entrykey = a_str_entrykey />
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<!---
	direction is important!
				
				0 = User A does not want to access library B any more
				1 = User A does not want B to access his library any more
				
				 --->
	
	<cffunction access="public" name="EditLibraryAccess" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="otheruserkey" type="string" required="true"
			hint="entrykey of the other user">
		<cfargument name="access" type="numeric" required="true"
			hint="0 or 1">
		<cfargument name="direction" type="numeric" required="true"
			hint="0 = User A does not want to access library B any more; 1 = User A does not want B to access his library any more">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_map_query = StructNew() />
		<cfset var oItem = 0 />

		<!--- search for userkey / otheruserkey connection ... IMPORTANT is the
			assignment here in the "wrong" order, because we want to modify the access right of the other user! --->
		
		<cfif arguments.direction IS 0>
		
			<cfset a_map_query.userkey = arguments.securitycontext.entrykey />
			<cfset a_map_query.otheruserkey = arguments.otheruserkey />
			
		<cfelse>
		
			<cfset a_map_query.userkey = arguments.otheruserkey />
			<cfset a_map_query.otheruserkey = arguments.securitycontext.entrykey />
		
		</cfif>	
			
		<cfset oItem = oTransfer.readByPropertyMap( 'users.friend', a_map_query ) />
		
		<!--- item does not exist --->
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<!--- call the update --->
		<cfset oItem.setaccesslibrary( arguments.access )>
		<cfset oTransfer.Update( oItem ) />
		
		<!--- do auto permission check --->
		<cfset DoAutoPermissionCheck( arguments.securitycontext.entrykey ) />
		<cfset DoAutoPermissionCheck( arguments.otheruserkey ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<cffunction access="public" name="DoAutoPermissionCheck" output="false" returntype="void">
		<cfargument name="userkey" type="string" required="true"
			hint="entrykey of the user">
			
		<cfset var q_select_shares_count = 0 />
		<cfset var q_select_consumed_shares_count = 0 />
		
		<cfinclude template="queries/q_select_shares_count.cfm">
		<cfinclude template="queries/q_select_consumed_shares_count.cfm">
		
		<cfif q_select_shares_count.count_shares GT 10>
		
			<!--- remove shares --->
			
			<!--- TODO: include restriction --->
			
		
		</cfif>
		
		<cfif q_select_consumed_shares_count.count_shares GT 10>
			
			<!--- remove shares --->
			
			
			
		
		</cfif>
	
	
	</cffunction>
	
	<cffunction access="public" name="IsReallyExistingFriendWithLibraryAccess" output="false" returntype="boolean"
			hint="return true if this a real friend with existing right to access the library or not">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="otheruserkey" type="string" required="true">
		
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<!--- select
			a friend which exists on the system and is allowed to access the library --->
		<cfset var a_str_sql = 'SELECT friend.entrykey FROM users.friend AS friend WHERE friend.userkey = :userkey AND friend.otheruserkey = :otheruserkey AND friend.accesslibrary = :accesslibrary' />
		<cfset var a_tsql_query = oTransfer.createQuery(a_str_sql) />
		<cfset var q_select = 0 />
		
		<cfset a_tsql_query.setParam( 'userkey' , arguments.securitycontext.entrykey, 'string' ) />
		<cfset a_tsql_query.setParam( 'accesslibrary' , 1, 'numeric' ) />
		<cfset a_tsql_query.setParam( 'otheruserkey' , arguments.otheruserkey, 'string' ) />
		
		<cfset q_select = oTransfer.listByQuery(a_tsql_query) />
		
		<cfreturn ( q_select.recordcount IS 1 ) />

	</cffunction>
	
	<cffunction access="public" name="FriendAlreadyExists" output="false" returntype="struct">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="source" type="numeric" required="true">
		<cfargument name="otheruserkey" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_str_sql = 'SELECT friend.entrykey FROM users.friend AS friend WHERE friend.userkey = :userkey AND friend.source = :source AND friend.otheruserkey = :otheruserkey' />
		<cfset var a_tsql_query = oTransfer.createQuery(a_str_sql) />
		<cfset var q_select = 0 />
	
		<cfset a_tsql_query.setParam( 'userkey' , arguments.securitycontext.entrykey, 'string' ) />
		<cfset a_tsql_query.setParam( 'source' , arguments.source, 'numeric' ) />
		<cfset a_tsql_query.setParam( 'otheruserkey' , arguments.otheruserkey, 'string' ) />
		
		<cfset q_select = oTransfer.listByQuery(a_tsql_query) />
		
		<!--- exists? return entrkey as well --->
		<cfset stReturn.result = ( q_select.recordcount GT 0 ) />
		<cfset stReturn.entrykey = q_select.entrykey />
		
		<cfreturn stReturn />
	</cffunction>
	
	<cffunction access="public" name="GetInvitationData" output="false" returntype="struct"
			hint="get invitation data">
		<cfargument name="invitationkey" type="string" required="true"
			hint="entrykey of the invitation">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.readByProperty( 'users.invitation', 'entrykey', arguments.invitationkey ) />
		
		<!--- invalid ... or already used --->
		<cfif NOT oItem.getIsPersisted() OR (oItem.getaccepted() IS 1)>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 6005) />
		</cfif>
		
		<cfset stReturn.stillavailable = oItem.getStillAvailable() />
		
		<!--- already the max number of invitations with this keyword (WITHOUT a special user) have been used --->
		<cfif Len( oItem.getUserkey() ) IS 0 AND oItem.getStillAvailable() LT 1>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 6005) />
		</cfif>
		
		<cfset stReturn.oItem = oItem />
		
		<!--- remove from cache?! --->
		<cfset oTransfer.discard( oItem ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="GetPreparedInvitationText" output="false" returntype="struct"
			hint="Create the whole invitation text ready for usage in various fields">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="invitationkey" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_arr_items = ArrayNew( 1 ) />
		<cfset var a_str_text = '' />
		<cfset var a_user_data = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = arguments.securitycontext.entrykey).a_struct_item />
		
		<cfset a_arr_items[ 1 ] = arguments.invitationkey />
		<cfset a_arr_items[ 2 ] = a_user_data.getFirstName() />
		
		<!--- get replaced text --->
		<cfset a_str_text = application.udf.GetLangValSec( 'mail_invite_body', a_arr_items ) />
		
		<cfset stReturn.text = a_str_text />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="GetInvitationsSentByUser" output="false" returntype="struct" hint="Return the number of invitations a user has left">
		<cfargument name="securitycontext" type="struct" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var q_select_invitations = oTransfer.listByProperty( 'users.invitation', 'userkey', arguments.securitycontext.entrykey ) />
		
		<cfset stReturn.q_select_invitations = q_select_invitations />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	</cffunction>
	
	<cffunction access="public" name="DeleteInvitation" output="false" returntype="struct" hint="delete an invitation">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="entrykey" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var a_map = { userkey = arguments.securitycontext.entrykey, entrykey = arguments.entrykey } />
		<cfset var oItem = oTransfer.readByPropertyMap( 'users.invitation' ,a_map) />
		
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
		</cfif>
		
		<cfset oTransfer.delete( oItem ) />
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>

	<cffunction access="public" name="CreateInvitation" output="false" returntype="struct" hint="Create a new invitation">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="recipient_type" type="numeric" default="0" required="false"
			hint="0 = email, 1 = facebook contact">
		<cfargument name="customtext" type="string" default="" required="false">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_str_invite_key = CreateUUID() />
		<cfset var a_str_email_adr = application.udf.ExtractEmailAdr(arguments.recipient) />
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.new( 'users.invitation' ) />
		<cfset var a_user_data = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = arguments.securitycontext.entrykey).a_struct_item />
		<cfset var a_str_text = GetPreparedInvitationText( securitycontext = arguments.securitycontext, invitationkey = a_str_invite_key ).text />
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
		<cfset var stUserdata = {} />
		<cfset var sHTMLMail = ''/>
		<cfset var sTextMail = '' />
	
		<cfif Len( arguments.recipient ) IS 0>
			<!--- no valid email --->
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5003) />
		</cfif>
		
		<cfset oItem.setEntrykey( a_str_invite_key ) />
		<cfset oItem.setuserkey( arguments.securitycontext.entrykey ) />
		<cfset oItem.setdt_created( Now() ) />
		<cfset oItem.setrecipient( arguments.recipient ) />
		<cfset oItem.setrecipient_type( arguments.recipient_type ) />
		<cfset oItem.setlang_id( 0 ) />
		<cfset oItem.setcustomtext( arguments.customtext ) />
		<cfset oItem.setdt_accepted( CreateDate( 1970, 1, 1 )) />
		
		<cfset oTransfer.save ( oItem ) />
		
		<!--- send by email? --->
		<cfif arguments.recipient_type IS 0>
			
<cfsavecontent variable="sTextMail"><cfoutput>
#a_str_text#
#arguments.customtext#
</cfoutput></cfsavecontent>

<cfsavecontent variable="sHTMLMail"><cfoutput>
<p style="font-weight:bold">
	<img src="http://www.tunesBag.com/#application.udf.getUserImageLink( arguments.securitycontext.username, 75 )#" style="height:36px;width: 30px" alt="user" border="0" vspace="4" hspace="4" align="absmiddle" />
	A message from #arguments.securitycontext.username#
</p>
<p>
	#a_str_text#</p>
<p>#arguments.customtext#</p>
</cfoutput></cfsavecontent>
			
			<cfset oMsg.sendGenericEmail( bIsRegisteredUser = false,
					sSubject = application.udf.GetLangValSec( 'mail_invite_subject' ),
					sSender = '#a_user_data.getFirstname()# <#a_user_data.getemail()#>',
					sTo = arguments.recipient,
					sHTMLContent = sHTMLMail, sTextContent = sTextMail ) />
		</cfif>
		
		<cfset stReturn.entrykey = a_str_invite_key />
		<cfset stReturn.text = a_str_text />
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="private" name="ContactAlreadyInvited" output="false" returntype="boolean">
		<cfargument name="recipient" type="string" required="true">
		<cfargument name="recipient_type" type="numeric" default="0" required="false">
		
		
	</cffunction>
	
	<cffunction access="public" name="GetInvitations" output="false" returntype="struct" hint="Return the open invitations">
		
	</cffunction>
	
	<cffunction access="private" name="UpdateAcceptedFriendShip" output="false" returntype="void"
			hint="set accepted to true">
		<cfargument name="invitationkey" type="string" required="true"
			hint="the invitation key">
			
		<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
		<cfset var oItem = oTransfer.readByProperty( 'users.invitation', 'entrykey', arguments.invitationkey ) />
		
		<cfif NOT oItem.getIsPersisted()>
			<cfreturn />
		</cfif>
		
		<!--- is connected to a certain user --->
		<cfif Len( oItem.getUserkey() ) GT 0>
			
			<cfset oItem.setaccepted( 1 ) />
			<cfset oItem.setdt_accepted( Now() ) />
		<cfelse>
			
			<!--- subtract stillavailable number  --->
			<cfset oItem.setstillavailable( oItem.getstillavailable() - 1 ) />
		
		</cfif>
		
		<!--- save --->
		<cfset oTransfer.save( oItem ) />
		
	</cffunction>
	
	<cffunction access="public" name="CreateFriendShipBasedOnInvitation" output="false" returntype="struct" hint="take the invitation key and create a friendship between the two users">
		<cfargument name="invitationkey" type="string" required="true"
			hint="the invitation key">
		<cfargument name="friend_userkey" type="string" required="true"
			hint="the userkey of the new user (= the friend of the invitor)">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_struct_invitation = GetInvitationData( arguments.invitationkey ) />
		<cfset var a_str_userkey = '' />
		<cfset var a_struct_add = 0 />
		<cfset var a_cmp_user = application.beanFactory.getBean( 'UserComponent' ) />
		<cfset var a_struct_host_data = 0 />
		<cfset var a_struct_friend_data = a_cmp_user.GetUserData( friend_userkey ) />
		<cfset var a_struct_host_security_context = 0 />
		<cfset var stUserdata = {} />
		<cfset var sHTMLMail = ''/>
		<cfset var sTextMail = '' />
		<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />

		<!--- not found?! --->
		<cfif NOT a_struct_invitation.result>
			<cfreturn a_struct_invitation />
		</cfif>
		
		<!--- update invitation item ... set accepted to true ... or subtract ONE from the number of used invitations --->
		<cfset UpdateAcceptedFriendShip( arguments.invitationkey ) />
		
		<!--- not bound to a certain user ... do nothing and exit --->
		<cfif Len( a_struct_invitation.oItem.getUserkey() ) IS 0>
			<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		</cfif>
		
		<cfset a_str_userkey = a_struct_invitation.oItem.getUserkey() />
		<cfset a_struct_host_security_context = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( a_str_userkey ) />
		<cfset a_struct_host_data = a_cmp_user.GetUserData( a_str_userkey ) />
		
		<!--- get host data --->
		<cfset a_struct_friend_data = a_cmp_user.GetUserData( friend_userkey ) />
		
		<cfset a_struct_add = AddFriend( securitycontext = a_struct_host_security_context,
								name = a_struct_friend_data.a_struct_item.getUsername(),
								source = 0,
								otherusername = a_struct_friend_data.a_struct_item.getUsername(),
								otheruserkey = arguments.friend_userkey,
								accesslibrary = 1) />
								
		<cfif a_struct_add.result>

		<cfset stUserdata = { entrykey = a_struct_host_data.a_struct_item.getEntrykey(), firstname = a_struct_host_data.a_struct_item.getFirstname(), email = a_struct_host_data.a_struct_item.getEmail(), username = a_struct_host_data.a_struct_item.getUsername() } />
	
<cfsavecontent variable="sTextMail"><cfoutput>
#a_struct_friend_data.a_struct_item.getFirstName()# has joined tunesBag,
you can start sharing items and playlists with this new user now!

Click here to start: http://www.tunesBag.com/

- Your tunesBag.com Team
</cfoutput></cfsavecontent>

<cfsavecontent variable="sHTMLMail"><cfoutput>
<p><b>#a_struct_friend_data.a_struct_item.getFirstName()#</b> (<a href="http://www.tunesBag.com/user/#a_struct_friend_data.a_struct_item.getUsername()#">#a_struct_friend_data.a_struct_item.getUsername()#</a>) has joined tunesBag, you can start sharing items and playlists now!</p>

<p><a href="http://www.tunesBag.com/">Click here to start</a></p>

<br />
-- Your tunesBag.com Team
</cfoutput>
</cfsavecontent>

		<cfset oMsg.sendGenericEmail( bIsRegisteredUser = true,
					sSubject = application.udf.GetLangValSec( 'mail_ph_subject_friend_has_joined', a_struct_friend_data.a_struct_item.getFirstName()),
					sSender = 'tunesBag.com <noreply@tunesBag.com>',
					sTo = stUserdata.firstname & ' <' & stUserdata.email & '>',
					sHTMLContent = sHTMLMail, sTextContent = sTextMail,
					stUserData = stUserData ) />
		
		</cfif>
		
		<cfset stReturn.a_struct_add = a_struct_add />
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	</cffunction>
	
	<cffunction access="public" name="GetSimpleFriendsInformation" returntype="array" hint="Simple basic version of returning friends">
		<cfargument name="sUserkey" type="string" required="true"
			hint="entrykey of user" />
			
		<cfset var arReturn = [] />
		<cfset var qFriends = 0 />
		
		<cfquery name="qFriends" datasource="mytunesbutleruserdata">
		SELECT
			friend.otheruserkey,
			friend.user2_id,
			friend.accesslibrary,
			users.username,
			users.photoindex,
			friendlibrary.id AS libraryid,
			friendlibrary.entrykey as librarykey
		FROM
			friends AS friend
		LEFT JOIN
			users ON (users.id = friend.user2_id)
		LEFT JOIN
			libraries AS friendlibrary ON (friendlibrary.userkey = friend.otheruserkey)
		WHERE
			friend.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sUserkey#">
			AND NOT
			ISNULL(users.id)
		;
		</cfquery>
		
		<cfloop query="qFriends">
			
			<cfset arReturn[ qFriends.currentrow ] = { userid = qFriends.user2_id,
					userkey = qFriends.otheruserkey,
					accesslibrary = qFriends.accesslibrary,
					username = qFriends.username,
					photoindex = qFriends.photoindex,
					libraryid = qFriends.libraryid,
					librarykey = qFriends.librarykey } />
		</cfloop>
		
		<cfreturn arReturn />
			
	</cffunction>
	
	<cffunction access="public" name="GetFriendsList" output="false" returntype="struct" hint="Return a list of friends of the current user">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="filter_entrykeys" type="string" required="false" default=""
			hint="if not empty, filter for the given entrykeys">
		<cfargument name="filter_accesslibrary_only" type="boolean" required="false" default="false"
			hint="filter for certain friends who can access the library">
		<cfargument name="realusers_only" type="boolean" required="false" default="false"
			hint="only return real users who are members of tunesBag (no Facebook users)">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_friend_list = 0 />
		
		<cfinclude template="queries/q_select_friend_list.cfm">
		
		<cfloop query="q_select_friend_list">
			<cfif Len( q_select_friend_list.photourl ) IS 0>
				<cfset QuerySetCell( q_select_friend_list, 'photourl', '/res/images/nobody.png', q_select_friend_list.currentrow ) />
			</cfif>
		</cfloop>
		
		<cfset stReturn.q_select_friends = q_select_friend_list />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>
		
	<cffunction access="public" name="ReloadFriendsFromCommunities" output="false" returntype="struct" hint="Reload friends stored in communites (e.g. facebook)">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="communities" type="string" required="false" default=""
			hint="empty = load all data">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<!--- get access data --->
		<cfset var a_user_data = application.beanFactory.getBean( 'UserComponent' ).GetUserData( userkey = arguments.securitycontext.entrykey).a_struct_item />
		<cfset var a_struct_facebook = application.beanFactory.getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = arguments.securitycontext,
							servicename = 'facebook' ) />	
		<cfset var a_struct_mystrands = application.beanFactory.getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = arguments.securitycontext,
							servicename = 'mystrands' ) />		
		<cfset var a_struct_twitter = application.beanFactory.getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = arguments.securitycontext,
							servicename = 'twitter' ) />
		<cfset var a_cmp_fb = application.beanFactory.getBean( 'FacebookComponent' ) />
		<!--- load which services? --->	
		<cfset var a_bol_check_facebook = (a_struct_facebook.result) AND ((arguments.communities IS '' ) OR (FindNoCase( arguments.communities, 'facebook' ) GT 0)) />
	
		<!--- reload facebook friends --->
		<cfif a_bol_check_facebook>
			<cfset a_cmp_fb.CheckAddFacebookFriends( securitycontext = arguments.securitycontext ) />
		</cfif>
	
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="ExploreUsers" output="false" returntype="struct"
			hint="search for users">
		<cfargument name="securitycontext" type="struct" required="true">
		<cfargument name="username" type="string" required="false" default="">
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_explore_users = 0 />
		
		<cfinclude template="queries/explore/q_select_explore_users.cfm">
		
		<cfset stReturn.q_select_explore_users = q_select_explore_users />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cffunction>

</cfcomponent>