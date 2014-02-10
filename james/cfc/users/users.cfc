<!--- //

	Module:		User Business component
	Description:User actions (as own CFC method)
	
// --->
<cfprocessingdirective pageencoding="utf-8" />

<cfcomponent name="users" displayname="User component"output="false" hint="User component for tunesBag application">

<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.users.users" hint=""> 
	<!--- do nothing --->
	<cfreturn this />
</cffunction>

<cffunction access="public" name="SearchForUsers" output="false" returntype="struct" hint="search for users">
	<cfargument name="search" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_search_users = 0 />
	
	<cfinclude template="queries/q_select_search_users.cfm">
	
	<cfset stReturn.q_select_search_users = q_select_search_users />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="StoreDesignBackgroundImage" output="false" returntype="struct">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="imagefile" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_info = 0 />
	<!--- organize in sub directories --->
	<cfset var a_str_sub_dir = Left( arguments.securitycontext.username, 3 ) & '/' />	
	<cfset var a_img_directory = application.udf.GetLocalContentDirectory() & 'profile_background/'  & a_str_sub_dir />	
	<cfset var a_str_big_img = a_img_directory & arguments.securitycontext.username & '_background.jpg' />
	<cfset var a_update_data = { bgimage = '/res/images/profile_background/' & a_str_sub_dir & GetFileFromPath( a_str_big_img) } />
	
	<!--- create the directory if necessary --->
	<cfif NOT DirectoryExists( a_img_directory ) >
		<cfdirectory action="create" directory="#a_img_directory#">
	</cfif>
	
	<cfimage action="info" source="#arguments.imagefile#" structName="a_struct_info">
	
	<cfif a_struct_info.width GT 1200>
		<!--- resize --->
		<cfimage action="RESIZE" source="#arguments.imagefile#" destination="#a_str_big_img#" width="1200" height="" overwrite="true" format="jpeg" />
	<cfelse>	
		<!--- copy image ... --->
		<cffile action="copy" source="#arguments.imagefile#" destination="#a_str_big_img#">
	</cfif>
	
	
	<cfset UpdateUserData( securitycontext = arguments.securitycontext, newvalues = a_update_data ) />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="StoreUserProfilePhoto" output="false" returntype="struct"
		hint="store the given photo for the user">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="bigimagefile" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<!--- organize in sub directories --->
	<cfset var a_str_sub_dir = Left( arguments.securitycontext.username, 3 ) & '/' />	
	<cfset var a_img_directory = application.udf.GetLocalContentDirectory() & 'profile_images/' & a_str_sub_dir />
	<cfset var a_str_big_img = a_img_directory & arguments.securitycontext.username & '_big.jpg' />
	<cfset var a_str_small_img = a_img_directory & arguments.securitycontext.username & '_small.jpg' />
	<cfset var local = {} />
	
	<cfset local.sDestFileBase = a_img_directory & arguments.securitycontext.username />
	
	<cfset var a_update_data = { pic = '/res/images/profile_images/' & a_str_sub_dir & arguments.securitycontext.username & '.jpg', update_photoindex = 1 } />
	
	<!--- create the directory if necessary --->
	<cfif NOT DirectoryExists( a_img_directory ) >
		<cfdirectory action="create" directory="#a_img_directory#">
	</cfif>
	
	<!--- generate all sizes --->
	<cfset application.beanFactory.getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = arguments.bigimagefile, destination = local.sDestFileBase & '.300.jpg', height = '', width = 300 ) />	
	<cfset application.beanFactory.getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = arguments.bigimagefile, destination = local.sDestFileBase & '.120.jpg', height = '', width = 120 ) />	
	<cfset application.beanFactory.getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = arguments.bigimagefile, destination = local.sDestFileBase & '.75.jpg', height = '', width = 73 ) />	
	<cfset application.beanFactory.getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = arguments.bigimagefile, destination = local.sDestFileBase & '.48.jpg', height = '', width = 48 ) />	
	<cfset application.beanFactory.getBean( 'ContentComponent' ).GenerateImageSizeVariation( source = arguments.bigimagefile, destination = local.sDestFileBase & '.30.jpg', height = '', width = 30 ) />	

	<!--- update the database --->	
	<cfset UpdateUserData( securitycontext = arguments.securitycontext, newvalues = a_update_data ) />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="UpdateUserOnlineStatus" output="false" returntype="void"
		hint="update user online status">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="instance" type="string" required="false" default=""
		hint="which instance is online?">
		
	<cfset var a_update_data = { online = 1, dt_lastping = Now() } />
	
	<cfset UpdateUserData( securitycontext = arguments.securitycontext, newvalues = a_update_data ) />
	
	<!--- alert anyone about new users online? --->

</cffunction>

<cffunction access="public" name="GetUserEntrykeyByUsername" output="false" returntype="string"
		hint="return the userkey of the given user">
	<cfargument name="username" type="string" required="true">
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_str_item = oTransfer.readByProperty( 'users.user', 'username', arguments.username ) />
	
	<!--- user exists? --->
	<cfif a_str_item.getisPersisted()>
		<cfreturn a_str_item.getEntrykey() />
	<cfelse>
		<cfreturn '' />
	</cfif> 

</cffunction>

<cffunction access="public" name="GetCountryList" output="false" returntype="query"
			hint="return the list of known countries">
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	
	<cfreturn oTransfer.list( 'various.country' ) />

</cffunction>

<cffunction access="public" name="GetUserData" output="false" returntype="struct" hint="Load userdata">
	<cfargument name="userkey" type="string" required="true" /> 
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_struct_item = 0 />
	
	<cfif Len(arguments.userkey) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- get user data by UUID --->
	<cfset a_struct_item = oTransfer.readByProperty('users.user', 'entrykey', arguments.userkey) />
	
	<!--- item does not exist --->
	<cfif NOT a_struct_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<!--- set the userdata ... --->
	<cfset stReturn.a_struct_item = a_struct_item />
	
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
</cffunction>

<cffunction access="public" name="UpdateStatusCounterItems" output="false" returntype="void" hint="update status data of a user">
	<cfargument name="securitycontext" type="struct">
	<cfargument name="property" type="string">
	
	<cfset var a_struct_newvalues = {} />
	<cfset var q_select_open_friendship_request_count = 0 />
	
	<cfswitch expression="#arguments.property#">
		<cfcase value="openfriendshiprequests">
			<!--- open friendship requests --->
			<cfinclude template="queries/q_select_open_friendship_request_count.cfm">
			<cfset a_struct_newvalues.openfriendshiprequests = Val(q_select_open_friendship_request_count.counter) />
		</cfcase>
		<cfcase value="unreadshareditems">
			<!--- unread shared items --->
			<cfinclude template="queries/q_select_unread_shared_items_counter.cfm">
			<cfset a_struct_newvalues.status_unreadshareditems = Val( q_select_unread_shared_items_counter.counter) />
		</cfcase>
	</cfswitch>
	
	<cfset UpdateUserData( securitycontext = securitycontext, newvalues = a_struct_newvalues ) />
	
</cffunction>

<cffunction access="public" name="UpdateUserData" output="false" returntype="struct" hint="Update data of a user">
	<cfargument name="securitycontext" type="struct">
	<cfargument name="newvalues" type="struct">

	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_user = oTransfer.readByProperty( 'users.user', 'entrykey', arguments.securitycontext.entrykey ) />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<!--- call updates --->
	<cfif StructKeyExists(arguments.newvalues, 'music_preferences' ) AND (Len( arguments.newvalues.music_preferences) GT 0)>
		<cfset a_user.setmusic_preferences( Left( arguments.newvalues.music_preferences, 250) ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.newvalues, 'pic' ) AND (Len( arguments.newvalues.pic ) GT 0)>
		<cfset a_user.setpic( Left( arguments.newvalues.pic, 250) ) />
	</cfif>	
	
	<!--- update photo index --->
	<cfif StructKeyExists( arguments.newvalues, 'update_photoindex')>
		<cfset a_user.setphotoindex( Val( a_user.getphotoindex() ) + 1 ) />
	</cfif>
	
	<cfif StructKeyExists(arguments.newvalues, 'bgimage' ) AND (Len( arguments.newvalues.bgimage ) GT 0)>
		
		<!--- user wants to clear the background image --->
		<cfif arguments.newvalues.bgimage IS 'RESET'>
			<cfset arguments.newvalues.bgimage = '' />
		</cfif>
		
		<cfset a_user.setbgimage( Left( arguments.newvalues.bgimage, 250) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'about_me' ) AND (Len( arguments.newvalues.about_me ) GT 0)>
		<cfset a_user.setabout_me( Left( arguments.newvalues.about_me, 250) ) />
	</cfif>		
		
	<cfif StructKeyExists(arguments.newvalues, 'lang_id' ) AND (Len( arguments.newvalues.lang_id ) GT 0)>
		<cfset a_user.setlang_id( arguments.newvalues.lang_id ) />
	</cfif>			
		
	<cfif StructKeyExists(arguments.newvalues, 'fb_uid' ) AND (Len( arguments.newvalues.fb_uid ) GT 0)>
		<cfset a_user.setfb_uid( Left( arguments.newvalues.fb_uid, 50) ) />
	</cfif>	
		
	<cfif StructKeyExists(arguments.newvalues, 'sex' ) AND (Len( arguments.newvalues.sex ) GT 0)>
		<cfset a_user.setsex( arguments.newvalues.sex ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'city' ) AND (Len( arguments.newvalues.city ) GT 0)>
		<cfset a_user.setcity( Left( arguments.newvalues.city, 100) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'zipcode' ) AND (Len( arguments.newvalues.zipcode ) GT 0)>
		<cfset a_user.setzipcode( Left( arguments.newvalues.zipcode, 20) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'countryisocode' ) AND (Len( arguments.newvalues.countryisocode ) GT 0)>
		<cfset a_user.setcountryisocode( Left( arguments.newvalues.countryisocode, 5) ) />
	</cfif>						
	
	<cfif StructKeyExists(arguments.newvalues, 'firstname' ) AND (Len( arguments.newvalues.firstname ) GT 0)>
		<cfset a_user.setfirstname( Left( arguments.newvalues.firstname, 100) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'surname' ) AND (Len( arguments.newvalues.surname ) GT 0)>
		<cfset a_user.setsurname( Left( arguments.newvalues.surname, 100) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'email' ) AND (Len( arguments.newvalues.email ) GT 0)>
		<cfset a_user.setemail( Left( arguments.newvalues.email, 100) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'password' ) AND (Len( arguments.newvalues.password ) GT 0)>
		<cfset a_user.setpwd( Left( arguments.newvalues.password, 100) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'cellphone_nr' ) AND (Len( arguments.newvalues.cellphone_nr ) GT 0)>
		<cfset a_user.setcellphone_nr( Left( arguments.newvalues.cellphone_nr, 20) ) />
	</cfif>		 	 	 	
	
	<cfif StructKeyExists(arguments.newvalues, 'cellphone_confirmed' ) AND (Len( arguments.newvalues.cellphone_confirmed ) GT 0)>
		<cfset a_user.setcellphone_confirmed( arguments.newvalues.cellphone_confirmed ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'email_confirmed' ) AND (Len( arguments.newvalues.email_confirmed ) GT 0)>
		<cfset a_user.setemail_confirmed( arguments.newvalues.email_confirmed ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'public_profile' )>
		<cfset a_user.setpublic_profile( Val( arguments.newvalues.public_profile) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'rsslink' )>
		<cfset a_user.setrsslink( Left( arguments.newvalues.rsslink, 255) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'homepage' )>
		<cfset a_user.sethomepage( Left( arguments.newvalues.homepage, 255) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'online' )>
		<cfset a_user.setonline( Val( arguments.newvalues.online ) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'privacy_playlists' )>
		<cfset a_user.setprivacy_playlists( Val( arguments.newvalues.privacy_playlists ) ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'privacy_newsfeed' )>
		<cfset a_user.setprivacy_newsfeed( Val( arguments.newvalues.privacy_newsfeed ) ) />
	</cfif>				
	
	<cfif StructKeyExists(arguments.newvalues, 'privacy_profile' )>
		<cfset a_user.setprivacy_profile( Val( arguments.newvalues.privacy_profile ) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'dt_lastping' ) AND IsDate( arguments.newvalues.dt_lastping )>
		<cfset a_user.setdt_lastping( arguments.newvalues.dt_lastping ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'openfriendshiprequests' )>
		<cfset a_user.setstatus_openfriendshiprequests( val(arguments.newvalues.openfriendshiprequests) ) />
	</cfif>	
	
	<cfif StructKeyExists(arguments.newvalues, 'status_unreadmessages' )>
		<cfset a_user.setstatus_unreadmessages( Val(arguments.newvalues.status_unreadmessages) ) />
	</cfif>		
		
	<cfif StructKeyExists(arguments.newvalues, 'status_unreadshareditems' )>
		<cfset a_user.setstatus_unreadshareditems( Val(arguments.newvalues.status_unreadshareditems) ) />
	</cfif>			
	
	<cfif StructKeyExists(arguments.newvalues, 'artistfanids' )>
		<cfset a_user.setartistfanids( arguments.newvalues.artistfanids ) />
	</cfif>		
	
	<cfif StructKeyExists(arguments.newvalues, 'accounttype' )>
		<cfset a_user.setaccounttype( Val( arguments.newvalues.accounttype )) />
	</cfif>		
	
	<cfset oTransfer.update( a_user ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction name="CreateUser" access="public" output="false" returntype="struct" hint="Create a new user"> 
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="firstname" type="string" required="true">
	<cfargument name="surname" type="string" required="true">
	<cfargument name="email" type="string" required="true">
	<cfargument name="zipcode" type="string" required="true">
	<cfargument name="city" type="string" required="true">
	<cfargument name="countryisocode" type="string" required="true">
	<cfargument name="lang_id" type="string" required="true" default="en"
		hint="language ID">
	<cfargument name="source" type="string" required="true"
		hint="source of this user">
	<cfargument name="bSendWelcomeMail" type="boolean" default="true"
		hint="send a welcome mail">
	<cfargument name="bPrefillLibrary" type="boolean" default="true"
		hint="prefill the lib of this user?" />
	<cfargument name="iStatus" type="numeric" default="0"
		hint="0 = unconfirmed, 1 = confirmed" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />									
	<cfset var a_new_item = oTransfer.new('users.user') />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var q_select_country = 0 />
	<cfset var q_select_countries = 0 />
	
	<cfset arguments.username = Trim(arguments.username) />
	
	<cfif Len(arguments.username) LT 3>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5001) />
	</cfif>
	
	<!--- invalid chars? --->
	<cfif ReFindNoCase("[^0-9, ,a-z,.,-,_]", arguments.username) GT 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5006) />
	</cfif>	
	
	<cfif Len(arguments.password) LT 3>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5002) />
	</cfif>
	
	<cfif Len( application.udf.ExtractEmailAdr( arguments.email )) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5003) />
	</cfif>
	
	<!--- username exists? --->
	<cfif UsernameExists(arguments.username)>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 5100) />
	</cfif>
	
	<!--- we need the ISO code --->
	<cfif Len( arguments.countryisocode ) GT 4>
		<cfset q_select_countries = GetCountryList() />
		
		<cfquery name="q_select_country" dbtype="query">
		SELECT
			iso
		FROM
			q_select_countries
		WHERE
			printable_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.countryisocode#">
		;
		</cfquery>
		
		<cfset arguments.countryisocode = q_select_country.iso />
		
	</cfif>
	
	<!--- default! --->
	<cfif Len( arguments.countryisocode ) IS 0>
		<cfset arguments.countryisocode = 'at' />
	</cfif>
	
	<!--- confirmation of email address is necessary --->
	<cfif arguments.iStatus IS application.const.I_USER_STATUS_UNCONFIRMED>
		<cfset a_new_item.settransactionUUID( CreateUUID() ) />
		<!--- <cfset a_new_item.setdt_transaction_valid_until( DateAdd( 'd', 5, Now() )) /> --->
	</cfif>
	
	<cfscript>
		a_new_item.setentrykey(a_str_entrykey);
		a_new_item.setsurname(arguments.surname);
		a_new_item.setfirstname(arguments.firstname);
		a_new_item.setusername(arguments.username);
		a_new_item.setpwd(arguments.password);
		a_new_item.setlang_id( arguments.lang_id );
		a_new_item.setemail(arguments.email);
		a_new_item.setcity(arguments.city);
		a_new_item.setzipcode(arguments.zipcode);
		a_new_item.setcountryisocode(arguments.countryisocode);
		a_new_item.setdt_created(Now());
		a_new_item.setsource( arguments.source );
		a_new_item.setpublic_profile( 1 );
		a_new_item.setstatus( arguments.istatus );
		a_new_item.setdt_lastping( Now() );
		a_new_item.setsubscribed_newsletter( 1 );
		oTransfer.save(a_new_item);
	</cfscript>
	
	<!--- everything went ok! ...set the userkey return the data --->
	<cfset stReturn.entrykey = a_str_entrykey />
	
	<!--- create the default library --->
	<cfset application.beanFactory.getBean( 'MediaItemsComponent' ).CreateDefaultLibrary( userkey = a_str_entrykey ) />
	
	<!--- send email in order to enable account --->
	<cfif arguments.iStatus IS application.const.I_USER_STATUS_UNCONFIRMED>
		
		<!--- send email, please confirm your account --->
		<cfset sendConfirmEmailAddressMail( a_str_entrykey ) />
		
	<cfelse>
		
		<!--- send a welcome mail --->
		<cfif arguments.bSendWelcomeMail>
			<cfset sendWelcomeMail( a_str_entrykey ) />
		</cfif>
		
		
	</cfif>
	
	
	<!--- prefill the library? --->
	<cfif arguments.bPrefillLibrary>
		<cftry>
		<cfset application.beanFactory.getBean( 'ContentComponent' ).prefillLibraryPlaylist( application.beanFactory.getBean( 'SecurityComponent').GetUserContextByUserkey( a_str_entrykey) ) />
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	
	<!--- create log entry --->	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="UserkeyExists" output="false" returntype="boolean" hint="Does a certain user already exist?">
	<cfargument name="entrykey" type="string" required="true">

	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_record = oTransfer.readByProperty('users.user', 'entrykey', arguments.entrykey) />
	
	<!--- return true if the username exists --->
	<cfreturn a_record.getIsPersisted() />
	
</cffunction>

<cffunction access="public" name="UsernameExists" output="false" returntype="boolean" hint="Does a certain user already exist?">
	<cfargument name="username" type="string" required="true">

	<cfset var qUserExists = 0 />

	<cfquery name="qUserExists" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS count_user
	FROM
		users
	WHERE
		username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
	;
	</cfquery>
	
	<cfreturn (qUserExists.count_user GT 0) />
	
</cffunction>

<cffunction name="Deleteuser" access="public" output="false" returntype="void" hint="Delete a user">
</cffunction>

<cffunction access="public" name="GetUseridByEntrykey" output="false" returntype="numeric" hint="return the userid by entrykey">
	<cfargument name="entrykey" type="string" required="true" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfreturn val( oTransfer.readByProperty('users.user', 'entrykey', arguments.entrykey).GetID() ) />
	
</cffunction>

<cffunction access="public" name="GetEntrykeyByUsername" output="false" returntype="string" hint="Return the entrykey of a user by its username, if not found empty string">
	<cfargument name="username" type="string" required="true">
	
	<cfset var local = StructNew() />
	
	<cfquery name="local.qSelectEntrykey" datasource="mytunesbutleruserdata">
	SELECT
		entrykey
	FROM
		users
	WHERE
		username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#" />
	;
	</cfquery>
	
	<cfreturn local.qSelectEntrykey.entrykey />
	
</cffunction>

<cffunction access="public" name="GetUsernamebyEntrykey" output="false" returntype="string" hint="Return the entrykey of a user by its userkey">
	<cfargument name="userkey" type="string" required="true">
	
	<cfset var a_str_entrykey = '' />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_record = oTransfer.readByProperty('users.user', 'entrykey', arguments.userkey) />
	
	<cfreturn a_record.getUsername() />
	
</cffunction>


<cffunction access="public" name="GetPreference" output="false" returntype="string" hint="Read and return a preference value">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="defaultvalue" type="string" required="true"
		hint="if not found">
		
	<cfset var local = {} />
	
	<cfquery name="local.qPreference" datasource="mytunesbutleruserdata">
	SELECT
		value
	FROM
		preferences
	WHERE
		userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#" />
		AND
		name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" />
	;
	</cfquery>
	
	<cfif local.qPreference.recordcount IS 1>
		<cfreturn local.qPreference.value />
	<cfelse>
		<cfreturn arguments.defaultvalue />
	</cfif>
	
</cffunction>

<cffunction access="public" name="StorePreference" output="false" returntype="boolean" hint="Store a preference value">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="name" type="string" required="true">
	<cfargument name="value" type="string" required="true">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_struct_map = { userkey = arguments.userkey, name = arguments.name } />
	<cfset var a_item = oTransfer.readByPropertyMap('userpreferences.preference', a_struct_map) />
	
	<cfscript>
		a_item.setuserkey( arguments.userkey );
		a_item.setname( arguments.name );
		a_item.setvalue( arguments.value);
		a_item.setdt_created( Now() );
		oTransfer.save( a_item );
	</cfscript>
	
	<cfreturn true />
	
</cffunction>

<cffunction access="public" name="DeleteExternalSiteID" output="false" returntype="struct" hint="Delete information about 3rd party service/site">
	<cfargument name="securitycontext" type="struct" required="false">
	<cfargument name="servicename" type="string" required="true"
		hint="name of the service">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_map = { userkey = arguments.securitycontext.entrykey, servicename = arguments.servicename } />
	<cfset var a_item = oTransfer.readByPropertyMap( 'external_services.siteids', a_map ) />
	
	<!--- when found delete --->
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	<cfelse>
		<cfset oTransfer.delete( a_item ) />
	</cfif>
	
	<!--- clean up ... --->
	<cfset application.beanFactory.getBean( 'MediaItemsComponent' ).cleanUpLibraryAfterSyncSourceRemoval(
			stContext 		= arguments.securitycontext,
			sServicename	= arguments.servicename
			) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="GetExternalSiteID" output="false" returntype="struct" hint="Return data about external site">
	<cfargument name="securitycontext" type="struct" required="false">
	<cfargument name="servicename" type="string" required="true"
		hint="name of the service">
		
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_struct_map = StructNew() />
	<cfset var a_item = 0 />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	
	<cfset a_struct_map.userkey = arguments.securitycontext.entrykey />
	<cfset a_struct_map.servicename = arguments.servicename />
	
	<cfset a_item = oTransfer.readByPropertyMap('external_services.siteids', a_struct_map) />
	
	<!--- no data found --->
	<cfif NOT a_item.getIsPersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfset stReturn.a_item = a_item />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
</cffunction>

<cffunction access="public" name="StoreExternalSiteID" output="false" returntype="struct" hint="store an external site credential information">
	<cfargument name="securitycontext" type="struct" required="false">
	<cfargument name="servicename" type="string" required="true"
		hint="name of the service">
	<cfargument name="username" type="string" required="true">
	<cfargument name="password" type="string" required="true">
	<cfargument name="sessionid" type="string" required="false" default=""
		hint="optional: a session ID (e.g. needed for facebook)">
	<cfargument name="enabled" type="numeric" required="false" default="1"
		hint="service (yet) enabled?" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_item = 0 />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_map = StructNew() />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var a_struct_tmp_validate = StructNew() />
	
	<!--- perform some basic checks --->
	<cfif Len( arguments.username ) IS 0 OR Len( arguments.servicename ) IS 0 OR Len( arguments.password ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
	</cfif>
	
	<cfset a_struct_map.userkey = arguments.securitycontext.entrykey />
	<cfset a_struct_map.servicename = arguments.servicename />
	
	<cfset a_item = oTransfer.readByPropertyMap('external_services.siteids', a_struct_map) />
	
	<cfset a_item.setuserkey( arguments.securitycontext.entrykey ) />
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setservicename( arguments.servicename ) />
	<cfset a_item.setusername( arguments.username ) />
	<cfset a_item.setpwd( arguments.password ) />
	<cfset a_item.setsessionid( arguments.sessionid ) />
	<cfset a_item.setenabled( arguments.enabled ) />
	<!--- is working = true --->
	<cfset a_item.setIsworking( 1 ) />
	
	<!--- new or old item? --->
	<cfif Len( a_item.getEntrykey() ) IS 0>
		<cfset a_item.setentrykey( a_str_entrykey ) />
	<cfelse>
		<cfset a_str_entrykey = a_item.getEntrykey() />
	</cfif>
	
	<!--- save and return the new entrykey --->
	<cfset oTransfer.save( a_item ) />
	
	<cfset stReturn.entrykey = a_str_entrykey />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="updateParamOfExternalService" returntype="void" output="false"
		hint="Update the parameter property of a stored external service">
	<cfargument name="stContext" type="struct" />
	<cfargument name="sServiceName" type="string" />
	<cfargument name="sParam1" type="string" />
	<cfargument name="enabled" type="numeric" required="false" default="1" />
	
	<cfquery name="local.qUpdate" datasource="mytunesbutleruserdata">
	UPDATE	3rdparty_ids
	SET		param1		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sParam1#" />,
			enabled		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.enabled#" />
	WHERE	userkey		= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stContext.entrykey#" />
			AND
			servicename	= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sServiceName#" />
	</cfquery>
		
</cffunction>

<cffunction access="public" name="changePasswordOfuser" returntype="struct" output="false"
		hint="change the password of the uesr">
	<cfargument name="securitycontext" type="struct" required="true" />
	<cfargument name="oldpwd" type="string" required="true" />
	<cfargument name="newpwd" type="string" required="true" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var local = {} />
	
	<!--- invalid new pwd --->
	<cfif Len( arguments.newpwd ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 500, application.udf.GetLangValSec( 'cm_ph_invalid_input' )) />
	</cfif>
	
	<!--- check against old pwd --->
	<cfset local.oUserdata = GetUserData( arguments.securitycontext.entrykey ).a_struct_item />
	
	<!--- passwords --->
	<cfif local.oUserdata.getpwd() NEQ arguments.oldpwd>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 505, application.udf.GetLangValSec( 'cm_ph_invalid_input' )) />
	</cfif>
	
	<!--- alright, update pwd --->
	<cfset local.stUpdate = { password = arguments.newpwd } />
	
	<cfset updateUserdata( securityContext = arguments.securitycontext, newvalues = local.stUpdate ) />
	
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

</cffunction>

<cffunction access="public" name="getFavouriteArtistsOfUser" returntype="query" hint="return fav artists of user">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="options" type="string" required="false" default=""
		hint="options like IMPLICIT_FAVOURITES_AS_WELL (will load implicit favs as well)">
	
	<cfset var q_select_favourite_artists_of_user = 0 />
	<cfset var q_select_implicit_fav_artists = 0 />
	<cfset var sArtistFans = GetUserData(userkey = arguments.securitycontext.entrykey ).a_struct_item.getartistfanids() />
	<cfset var iFansListLen = ListLen( sArtistFans ) />
	<cfset var ii = 0 />
	
	<!--- not fan or a single artist? --->
	<cfif iFansListLen IS 0>
		<cfset iFansListLen = 1 />
		<cfset sArtistFans = 0 />
	</cfif>
	
	<!--- select implicit favourites --->
	<cfif ListFindNoCase( arguments.options, 'IMPLICIT_FAVOURITES_AS_WELL' ) GT 0>
		<cfinclude template="queries/q_select_implicit_fav_artists.cfm">
	</cfif>
	
	<cfinclude template="queries/q_select_favourite_artists_of_user.cfm">
	<cfreturn q_select_favourite_artists_of_user />
</cffunction>

<cffunction access="public" name="GetUserProfile" output="false" returntype="struct" hint="return user profile and meta data">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="datatypes" type="string" required="false" default=""
		hint="data types to return">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_struct_user_data = GetUserData( arguments.userkey ) />
	<cfset var a_social = application.beanFactory.getBean( 'SocialComponent' ) />
	<cfset var a_struct_securitycontext = 0 />
	<cfset var q_select_genre_cloud_of_user = 0 />
	<cfset var q_select_favourite_artists_of_user = 0 />
	<!--- playlists ... ignore temporary ones and receive public playlists only! --->	
	<cfset var stFilter_playlists = { public_only = true } />
	<cfset var a_tc = getTickCount() />
	
	<cfif NOT a_struct_user_data.result>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002) />
	</cfif>
	
	<cfset a_struct_securitycontext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = arguments.userkey ) />
	
	<!--- return userdata --->
	<cfset stReturn.a_userdata = a_struct_user_data.a_struct_item />
	
	<!--- friends --->
	<cfset stReturn.q_select_friends = a_social.GetFriendsList( a_struct_securitycontext ).q_select_friends />
	
	<!--- fav artists --->
	<cfset stReturn.q_select_favourite_artists = getFavouriteArtistsOfUser( a_struct_securitycontext ) />
	
	<!--- cloud of fav genres / tags --->
	<cfinclude template="queries/q_select_genre_cloud_of_user.cfm">
	<cfset stReturn.q_select_genre_cloud_of_user = q_select_genre_cloud_of_user />
	
	<cflog application="false" file="ib_profiling" log="Application" type="information" text="getting cloud: #(GetTickCount() - a_tc )#">	
		
	<cfset stReturn.q_select_playlists = application.beanFactory.getBean( 'MediaItemsComponent' ).GetUserContentData( librarykeys = '',
								securitycontext = a_struct_securitycontext,
								type = 'playlists',
								filter = stFilter_playlists,
								calculateitems = false ).q_select_items />
								
	<cflog application="false" file="ib_profiling" log="Application" type="information" text="getting playlists: #(GetTickCount() - a_tc )#">								
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="isIPhoneCustomer" output="false" returntype="boolean"
		hint="has this user installed the iPhone app?">
	<cfargument name="sUserkey" type="string" required="true" />
	
	<cfset var qSelect = 0 />
	
	<cfquery name="qSelect" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(installed.id) AS count_installed
	FROM
		applications_installed AS installed
	LEFT JOIN
		users ON (users.entrykey = installed.userkey)
	WHERE
		installed.applicationkey = '#application.const.S_APPKEY_IPHONE#'
		AND
		installed.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sUserkey#">
	;
	</cfquery>
	
	<cfreturn (qSelect.count_installed GT 0) />

</cffunction>

<cffunction access="public" name="sendConfirmEmailAddressMail" output="false" returntype="struct"
		hint="User has to confirm his account by clicking on a link in an email">
	<cfargument name="sUserkey" type="string" required="true" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var oUser = oTransfer.readByProperty( 'users.user', 'entrykey', arguments.sUserkey ) />
	<cfset var stUserdata = {} />
	<cfset var sHTMLMail = ''/>
	<cfset var sTextMail = '' />
	<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />

	<cfif NOT oUser.getisPersisted()>
		<cfreturn />
	</cfif>
	
	<!--- set transaction UUID --->
	<cfset local.sTransactionUUID = oUser.getTransactionUUID() />
	
	<!--- file with terms --->
	<cfset local.sTermsFile = GetDirectoryFromPath( GetCurrentTemplatePath() ) & '../../../res/download/terms.pdf' />
	
	<cfset stUserdata = { entrykey = oUser.getEntrykey(), firstname = oUser.getFirstname(), email = oUser.getEmail(), username = oUser.getUsername(), password = oUser.getpwd() } />
	
	
<cfsavecontent variable="sTextMail"><cfoutput>
Hi #htmleditformat( stUserdata.firstname )#

Welcome to tunesBag, #htmleditformat( stUserdata.username )#! To activate your account, please click on the following link:

http://www.tunesBag.com/rd/activate/?key=#local.sTransactionUUID#&username=#UrlEncodedFormat( stUserdata.username )#

Best regards,

Your tunesBag.com - team

In case you've received this email without a registration please ignore it. Your address will be automatically removed from our database.
We've attached our Common Terms and Conditions to this email. They apply to your membership at tunesBag.com.
</cfoutput>
</cfsavecontent>


<cfsavecontent variable="sHTMLMail">
<cfoutput>
<p>Hi #htmleditformat( stUserdata.firstname )# -</p>

<p>Welcome to tunesBag, #htmleditformat( stUserdata.username )#! To activate your account and finish the registration process, please click on the following link:

<a style="font-weight:bold" href="http://www.tunesBag.com/rd/activate/?key=#local.sTransactionUUID#&username=#UrlEncodedFormat( stUserdata.username )#">Click here to activate your account</a></p>


<p>Best regards,
<br />
Your tunesBag.com - team
</p>
<br />
<p>In case you've received this email without a registration please ignore it. Your address will be automatically removed from our database.</p>
<p>We've attached our Common Terms and Conditions to this email. They apply to your membership at tunesBag.com.</p>
</cfoutput>
</cfsavecontent>
	

	<cfreturn oMsg.sendGenericEmail( bIsRegisteredUser = false, bTextOnly = true, sSubject = application.udf.GetLangValSec( 'cm_ph_welcome_confirm_account', stUserData.firstname ), sSender = 'tunesBag.com Office <office@tunesBag.com>', sTo = stUserdata.firstname & ' <' & stUserdata.email & '>', sHTMLContent = sHTMLMail, sTextContent = sTextMail, stUserData = stUserData, sAttachments = local.sTermsFile ) />
	
	
	<!--- ok! --->
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="sendWelcomeMail" output="false" returntype="struct">
	<cfargument name="sUserkey" type="string" required="true" />
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var oUser = oTransfer.readByProperty( 'users.user', 'entrykey', arguments.sUserkey ) />
	<cfset var stUserdata = {} />
	<cfset var sHTMLMail = ''/>
	<cfset var sTextMail = '' />
	<cfset var oMsg = application.beanFactory.getBean( 'MessagesComponent' ) />
		
	<cfif NOT oUser.getisPersisted()>
		<cfreturn />
	</cfif>
	
	<cfset stUserdata = { entrykey = oUser.getEntrykey(), firstname = oUser.getFirstname(), email = oUser.getEmail(), username = oUser.getUsername(), password = oUser.getpwd() } />
	
<cfsavecontent variable="sTextMail"><cfoutput>
A warm welcome from the tunesBag Team. We are glad that you have decided to join our growing community of music lovers and will give you some hints now how you can get out the most of our innovative solution.

Your username is: #stUserdata.username#

<!--- Your password is #stUserdata.password# --->

Best regards,

Your tunesBag team</cfoutput>
</cfsavecontent>
<cfsavecontent variable="sHTMLMail"><cfoutput>
A warm welcome from the tunesBag Team. We are glad that you have decided to join our
growing community of music lovers and will give you some hints how to start.<br /><br />
Your username is: <b>#stUserdata.username#</b>
<br /><br />
Visit <a href="http://www.tunesBag.com/rd/start/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#">tunesBag.com</a> now and start with the steps listed below:

<h4>Connect your Dropbox account to add media files</h4>
<div style="padding-left:50px">
tunesBag enables you to access your tracks stored in the Dropbox anywhere and anytime.
<a style="text-decoration:none" href="http://www.tunesbag.com/dropbox/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#"><img style="vertical-align:middle" border="0" src="http://www.tunesbag.com/res/images/partner/services/dropbox-110x37.png" width="110" alt="Dropbox" /> Connect your Dropbox account now</a>
<br /><br />

<!--- 
<br /><br />
<a style="text-decoration:none" href="http://www.tunesbag.com/start/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#"><img style="vertical-align:middle" src="http://cdn.tunesbag.com/images/si/folder_add.png" alt="" width="16" height="16" border="0" /> Browser-based Uploader (Firefox, Safari, IE etc). No setup needed.</a>
<br />
<a style="text-decoration:none" href="http://www.tunesbag.com/rd/download/uploader/win/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#"><img style="vertical-align:middle" src="http://cdn.tunesbag.com/images/ico/ico-win.png" alt="" width="16" height="16" border="0" /> Windows Client with support for iTunes, Winamp and Directory browsing</a>
<br />
<a style="text-decoration:none" href="http://www.tunesbag.com/rd/download/uploader/mac/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#"><img style="vertical-align:middle" src="http://cdn.tunesbag.com/images/ico/ico-osx-uni.png" alt="" width="16" height="16" border="0" /> Mac OS X Client with Drag &amp; Drop support</a>
<br />
<a style="text-decoration:none" href="mailto:#stUserdata.username#@incoming.tunesBag.com?subject=Attach%20your%20Audio%20Files"><img style="vertical-align:middle" src="http://cdn.tunesbag.com/images/si/email.png" alt="" width="16" height="16" border="0" /> Send your audio files to #stUserdata.username#@incoming.tunesBag.com</a>
 --->
</div>

<h4>Connect tunesBag to your existing devices / services</h4>
<div style="padding-left:50px">
<a style="text-decoration:none" href="http://www.tunesbag.com/rd/iphone/appstore/"><img style="vertical-align:middle" border="0" src="http://cdn.tunesbag.com/images/partner/app_store_badge.png" width="110" alt="iPhone App Store" /> Download our free iPhone app</a>
<br /><br />
<a style="text-decoration:none" href="http://www.tunesbag.com/squeezenetwork/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'start' )#"><img style="vertical-align:middle" border="0" src="http://www.tunesbag.com/res/images/content/sqbn/sqbn-prod1-75x52.jpg" width="75" alt="" /> Stream to your Logitech Squeezebox&trade;</a>
<br /><br />
and some more - check out our <a style="text-decoration:none" href="http://www.tunesbag.com/start/##tb:apps">Application and device page</a>.
</div>

<!--- 
<h4>Explore other playlists / Share tunes with friends</h4>
<div style="padding-left:50px">
Just type the name of an artist into the search box - we'll provide you with a list of matching playlists.
</div>

<h4>Download our Desktop Radio Application for Win, Mac and Linux</h4>
<div style="padding-left:50px">
This application provides access to your own playlists and other public playlists without using a browser - it's a native player application! <a href="http://www.tunesBag.com/rd/desktopradio/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'desktopradio' )#">Download & install now</a>
</div> --->
<h4>Connect with us!</h4>
<div style="padding-left:50px">
	To stay in touch with us and always receive the latest information, please become a fan of <a href="http://www.facebook.com/tunesBag">tunesBag on Facebook</a> and follow <a href="http:///twitter.com/tunesBag">@tunesBag</a> on twitter.
</div>
<h4>Your feedback is welcome!</h4>
<div style="padding-left:50px">
Please use our <a href="http:/www.tunesBag.com/rd/feedback/?#application.udf.generateGAURLParams( 'email', 'signup', 'email', 'feedback' )#">feedback form</a> in order to let us know your opinion or bug reports!
</div>

<br /><br />
So, go ahead and have a good time with tunesBag! ;-)</cfoutput>
</cfsavecontent>


	<cfreturn oMsg.sendGenericEmail( bIsRegisteredUser = true, sSubject = application.udf.GetLangValSec( 'cm_ph_welcome_intro_headline', stUserData.username ), sSender = 'tunesBag.com Office <office@tunesBag.com>', sTo = stUserdata.firstname & ' <' & stUserdata.email & '>', sHTMLContent = sHTMLMail, sTextContent = sTextMail, stUserData = stUserData ) />

</cffunction>

<cffunction access="public" name="checkAccountConfirmation" output="false" returntype="struct"
		hint="check account confirmation">
	<cfargument name="sUsername" type="string" required="true" />
	<cfargument name="sKey" type="string" required="true" />
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var local = {} />
	
	<cfif Len( arguments.sKey ) IS 0 OR Len( arguments.sUsername ) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404) />
	</cfif>
	
	<!--- still exists? --->
	<cfquery name="local.qSelect" datasource="mytunesbutleruserdata">
	SELECT
		entrykey
	FROM
		users
	WHERE
		<!--- username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sUsername#" />
		AND --->
		transactionUUID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sKey#" />
	;
	</cfquery>
	
	<cfif local.qSelect.recordcount NEQ 1>
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 404, 'No account found or request has expired') />
	</cfif>
	
	<!--- update, set the account as confirmed --->
	<cfquery name="local.qUpdate" datasource="mytunesbutleruserdata">
	UPDATE
		users
	SET
		status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.const.I_USER_STATUS_CONFIRMED#" />,
		transactionUUID = ''
		<!--- dt_transaction_valid_until = NULL --->
	WHERE
		<!--- username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sUsername#" />
		AND --->
		transactionUUID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sKey#" />
	;	
	</cfquery>
	
	<cfset stReturn.sUserkey = local.qSelect.entrykey />
	
	<!--- send a welcome email --->
	<cfset sendWelcomeMail( stReturn.sUserkey ) />
	
	<!--- ok! --->
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

</cfcomponent>