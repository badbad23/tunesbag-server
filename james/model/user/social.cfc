<!--- //

	Module:		MachII Social (e.g. Facebook) component
	Description:Important routines for user management
	
// --->

<cfcomponent name="social" displayname="Social component"output="false" extends="MachII.framework.Listener" hint="Logger for tunesBag application">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="GetPublicTrackInformation" output="false" returntype="void" hint="Get information about a certain track">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_entrykey = event.getArg( 'trackkey' ) />
	<cfset var a_struct_track_info = 0 />
	<cfset var a_struct_artist_information = 0 />
	<cfset var a_str_url = 0 />
	
	<cfif Len( a_str_entrykey ) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- return simple track info --->
	<cfset a_struct_track_info = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetSimpleMediaItemInfo( entrykey = a_str_entrykey ) />
	<cfset event.setArg( 'a_simple_info',  a_struct_track_info) />
	
	<cfif a_struct_track_info.getIsPersisted()>
		
		<!--- check if we can forward to the new page --->
		
		<cfif a_struct_track_info.getmb_trackid() GT 0 AND a_struct_track_info.getmb_artistid() GT 0>
			
			<cfset a_str_url = generateGenericURLToTrack( a_struct_track_info.getArtist(), a_struct_track_info.getName(), a_struct_track_info.getmb_trackid(), '' ) />

			<cflocation addtoken="false" url="#a_str_url#">
		</cfif>
					
	</cfif>
	
</cffunction>

<cffunction access="public" name="GetWaitingFriendShipRequests" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'q_select_friendship_requests', getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetWaitingFriendShipRequests( securitycontext = application.udf.GetCurrentSecurityContext() ).q_select_requests) />
</cffunction>

<cffunction access="public" name="SetFacebookData" output="false" returntype="void" hint="Store important facebook data in database">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var config           = StructNew() />
	<cfset var FBClient = 0 />
	<cfset var a_str_auth_token = event.getArg( 'auth_token' ) />
	<cfset var session_info = 0 />
	<cfset var a_int_user_uid = 0 />
	<cfset var a_str_session_key = 0 />
	<cfset var a_user_profile = 0 />
	<cfset var friends_array = 0 />
	<cfset var friend_profiles = 0 />
	<cfset var a_struct_update_data = StructNew() />
	<cfset var a_cmp_user = application.beanFactory.getBean( 'UserComponent' ) />
	<cfset var a_struct_result_update = 0 />
	<cfset var a_struct_store = 0 />
	
	<cfset event.setARg( 'FBFailedErrorMessage' , '') />
	
	<cfif Len(a_str_auth_token) IS 0>
		<cfset event.setArg('FBFailed', true) />
		<cfreturn />
	</cfif>
	
	<!--- set config data --->
	<cfset config.apiKey    = application.udf.GetSettingsProperty( 'fb_apikey', '' ) />
	<cfset config.secret    = application.udf.GetSettingsProperty( 'fb_secret', '' ) />
	
	<!--- init the Facebook client --->
	<cfset FBClient = application.BeanFactory.getBean( 'SocialFBRestClient' ).init( argumentCollection = config ) />
	
	<cfset session_info = FBClient.auth_getSession( a_str_auth_token ) />

	<!--- an error occured --->	
	<cfif StructKeyExists(session_info, 'error_msg') AND (Len( session_info.error_msg ) GT 0)>
		<cfset event.setArg( 'FBFailedErrorMessage' , session_info.error_msg) />
		<cfset event.setArg( 'FBFailed' , true) />
		<cfreturn />
	</cfif>
	
	<cfset a_str_session_key = session_info.session_key />
	<cfset a_int_user_uid = session_info.uid />
	
	<!--- store this access data! --->
	<cfset a_struct_store = a_cmp_user.StoreExternalSiteID( securitycontext = application.udf.GetCurrentSecurityContext(),
											servicename = 'facebook',
											username = a_int_user_uid,
											password = a_str_auth_token,
											sessionid = a_str_session_key) />	
	
	<!--- get user profile (first item only) --->
	<cfset a_user_profile = FBClient.users_getInfo( a_str_session_key, a_int_user_uid ) />
	<cfset a_user_profile = a_user_profile[1] />
	
	<!--- friends --->
	<cfset friends_array = FBClient.friends_get(a_str_session_key) />
	
	<!--- add friends --->
	<cfset application.beanFactory.getBean( 'FacebookComponent' ).CheckAddFacebookFriends( securitycontext = application.udf.GetCurrentSecurityContext() ) />
	
	<cfset friend_profiles = FBClient.users_getInfo(a_str_session_key, ArrayToList(friends_array)) />
	
	<!--- fill update struct ... start with facebook ID --->
	<cfset a_struct_update_data.fb_uid = a_int_user_uid />
	
	<!--- collect data --->
	<cfif StructKeyExists(a_user_profile, 'pic')>
		<cfset a_struct_update_data.pic = a_user_profile.pic />
	</cfif>
	
	<cfif StructKeyExists(a_user_profile, 'about_me')>
		<cfset a_struct_update_data.about_me = a_user_profile.about_me />
	</cfif>	
	
	<cfif StructKeyExists(a_user_profile, 'music')>
		<cfset a_struct_update_data.music_preferences = a_user_profile.music />
	</cfif>
	
	<!--- call real update --->
	<cfset a_struct_result_update = a_cmp_user.UpdateUserData(securitycontext = application.udf.GetCurrentSecurityContext(),
																newvalues = a_struct_update_data) />
	
</cffunction>

<cffunction access="public" name="GetFriend" output="false" returntype="void" hint="Return a list of friends of the current user">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_entrykey = event.getArg( 'entrykey' ) />
	
	<!--- call the appropiate method ... --->
	<cfset event.setArg('q_select_friend', getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetFriendsList( securitycontext = application.udf.GetCurrentSecurityContext(),
							filter_entrykeys = a_str_entrykey ).q_select_friends ) />
	
</cffunction>

<cffunction access="public" name="GetFriendsList" output="false" returntype="void" hint="Return a list of friends of the current user">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	<cfset var a_bol_real_users_only = event.getArg( 'realusersonly', false) />

	<!--- reload friend list? --->
	<cfif event.getArg( 'reloadfriends', 0 ) IS 1>
		<cfset ReloadFriendsFromCommunities( event ) />
	</cfif>
	
	<!--- call the appropiate method ... --->
	<cfset event.setArg( 'q_select_friends', getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetFriendsList( securitycontext = application.udf.GetCurrentSecurityContext(),
												realusers_only = a_bol_real_users_only  ).q_select_friends) />
	
</cffunction>

<cffunction access="public" name="ReloadFriendsFromCommunities" output="false" returntype="void" hint="Reload friends list of Facebook, ...">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).ReloadFriendsFromCommunities( securitycontext = application.udf.GetCurrentSecurityContext() ) />
</cffunction>

<cffunction access="public" name="GetNetworksStatus" output="false" returntype="void" hint="Return the status of the subscribtion to certain networks">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	
</cffunction>

<cffunction access="public" name="LoadExternalSiteIDs" output="false" returntype="void"
		hint="try to load all possible external site ids">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_struct_twitter = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = application.udf.GetCurrentSecurityContext(),
							servicename = 'twitter' ) />
	<cfset var a_struct_lastfm = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = application.udf.GetCurrentSecurityContext(),
							servicename = 'lastfm' ) />
	<!--- <cfset var a_struct_facebook = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = application.udf.GetCurrentSecurityContext(),
							servicename = 'facebook' ) />	 --->
	<cfset var a_struct_flickr = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = application.udf.GetCurrentSecurityContext(),
							servicename = 'flickr' ) />		
	<!--- <cfset var a_struct_blogger = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(securitycontext = application.udf.GetCurrentSecurityContext(),
							servicename = 'blogger' ) /> --->
	<cfset var stDropbox = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetExternalSiteID(
			securitycontext = application.udf.GetCurrentSecurityContext(),
			servicename		= 'dropbox'
			) />
	
	<!--- set data --->
	<cfset event.setArg( 'external_twitter',  a_struct_twitter) />
	<cfset event.setArg( 'external_lastfm',  a_struct_lastfm) />
	<cfset event.setArg( 'external_dropbox',  stDropbox) />

</cffunction>

<cffunction access="public" name="CheckStoreExternalSiteID" output="false" returntype="void"
		hint="check if we should save some access data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_bol_store_event = event.getArg( 'stored', false ) />
	<cfset var a_str_servicename = event.getArg( 'servicename' ) />
	<cfset var a_str_username = event.getArg( 'ext_username' ) />
	<cfset var a_str_password = event.getArg( 'ext_password' ) />
	<cfset var a_struct_store = 0 />
	<cfset var a_cmp_user = getProperty( 'beanFactory' ).getBean( 'UserComponent' ) />
	
	<cfif a_bol_store_event>
		
		<!--- store --->
		<cfset a_struct_store = a_cmp_user.StoreExternalSiteID( securitycontext = application.udf.GetCurrentSecurityContext(),
											servicename = a_str_servicename,
											username = a_str_username,
											password = a_str_password) />
											
		<!--- set the result --->
		<cfset event.setArg( 'stored_external_result', a_struct_store) />
		
	</cfif>

</cffunction>

<cffunction access="public" name="CheckGetSocialSyncData" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_datatype = event.getArg( 'type', '') />
	
	<cfswitch expression="#a_str_datatype#">
		<cfcase value="social.friends">
			
			<!--- friends should be loaded --->
			<cfset event.setArg( 'q_select_items', getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetFriendsList( securitycontext = application.udf.GetCurrentSecurityContext() ).q_select_friends) />
			
		</cfcase>
	</cfswitch>
	
</cffunction>

<cffunction access="public" name="UsersExplore" output="false" returntype="void" hint="search for users">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_username = event.getArg( 'username' ) />
	<cfset var a_struct_explore = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).ExploreUsers( securitycontext = application.udf.GetCurrentSecurityContext(), username = a_str_username ) />

	<cfset event.setArg( 'a_struct_explore', a_struct_explore ) />

</cffunction>

</cfcomponent>