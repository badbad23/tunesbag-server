<!--- //

	Module:		MachII User component
	Description:Important routines for user management
	
// --->

<cfcomponent name="logger" displayname="Logging component"output="false" extends="MachII.framework.Listener" hint="Logger for tunesBag application">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="CheckRPXLinkAccount" output="false" returntype="void"
		hint="try to link the account to an existing user account">
	<cfargument name="event" type="MachII.framework.Event" required="true">
	
	<cfset var sUsername = event.getArg( 'username' ) />
	<cfset var sPassword = event.getArg( 'password' ) />
	<cfset var sIdentifier = event.getArg( 'identifier' ) />
	<cfset var sProvider = event.getArg( 'provider' ) />
	<cfset var stComplete_data = event.getArg( 'complete_data' ) />
	
	<cfset var stLoginCheck = application.beanFactory.getBean( 'SecurityComponent' ).CheckLoginData( username = sUsername, password = sPassword )	/>
	
	<cfset event.setArg( 'stLoginCheck', stLoginCheck ) />
	
	<cfif NOT stLoginCheck.result>
		<cfset event.setArg( 'action', '' ) />
		<cfset announceEvent( 'login.rpxnow.check', event.getArgs() ) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="CheckRPXLoginLanding" output="false" returntype="void"
		hint="user has landed ...">
	<cfargument name="event" type="MachII.framework.Event" required="true">
	
	<cfset var sToken = event.getArg( 'token' ) />
	<cfset var oIdentities = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ) />
	<cfset var stCallSave = 0 />
	<cfset var qIdentifier = 0 />

	<!--- check result --->
	<cfset var stRPX = oIdentities.CheckRPXLoginData( token = sToken ) />
	
	<cfset event.setArg( 'rpxresult', stRPX ) />
	
	<!--- error message --->
	<cfif NOT stRPX.result>
		<!--- TODO: error page --->
		<cfset event.setArg( 'FAIL', true ) />
		<cfreturn />
	</cfif>
	
	<!--- one or more bindings found, use the first one --->
	<cfif stRPX.userBindingsFound GT 0>
		<!--- perfect, login this user --->
		
		<cfset qIdentifier = stRPX.stLookup.QIDENTIFIERUSERREL />
		
		<!--- set the userkey/username of our securitycontext to create --->
		<cfset event.setArg( 'logged_in_userkey', qIdentifier.userkey ) />
		<cfset event.setArg( 'logged_in_username', qIdentifier.username ) />
		
		<!--- log the provider --->
		<cfset event.setArg( 'externalidentifierkey', qIdentifier.entrykey ) />
		<cfset event.setArg( 'provider', qIdentifier.provider ) />
		
		<!--- perform normal login --->
		<cfset announceEvent( 'login.Succeeded', event.getArgs() ) />
		
	<!---<cfelseif stRPX.userBindingsFound GT 1>
		<!--- TODO: more than one binding, let the user select which one --->
		
		<cfthrow message="handle multiple bindings" />--->
	
	<cfelse>		
		<!--- no account yet, finish signup --->
		<cfset event.setArg( 'invitationkey', 'add' ) />
		
		<cfset stCallSave = oIdentities.StoreRPXLoginData( token = sToken,
								provider = stRPX.unifieduserdata.provider,
								identifier = stRPX.unifieduserdata.identifier,
								complete_userdata = stRPX.unifieduserdata.complete_data,
								unified_userdata = stRPX.unifieduserdata ) />
								
		
		<cfset event.setArg( 'sRPXDataEntrykey', stcallSave.entrykey ) />
				
		<cflocation addtoken="false" url="?event=register.externalsource.finish&entrykey=#stCallSave.entrykey#&source=rpx" />
		
		<!--- set external userdata property --->
		<!---><cfset event.setArg( 'external_userdata', a_struct_rpx.unifieduserdata ) />
		
		<cfset announceEvent( 'register.externalsource.finish', event.getArgs() ) />
	--->
	</cfif>

</cffunction>

<cffunction access="public" name="CheckRPXLoginData" output="false" returntype="void"
		hint="check the data provided by rpxnow">
	<cfargument name="event" type="MachII.framework.Event" required="true">
	
	<cfset var a_str_token = event.getArg( 'token' ) />
	<cfset var a_cmp = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ) />
	<cfset var sAction = event.getArg( 'action', 'check' ) />
	
	<!--- perform check and decide how to continue
	
		is is the first time this user logs in?
		 --->
	<cfset var a_struct_rpx = 0 />
	
	<!--- link existing account to this account --->
	<cfif sAction IS 'linkaccount'>
		
		<cfset announceEvent( 'login.rpxnow.handleLinkAccountsRequest', event.getArgs() ) />
	
		<!--- <cfreturn /> --->
	</cfif>
	
	
	<!--- create an account? --->
	<cfif sAction IS 'createaccount'>
	
		
		
		<cfreturn />
	</cfif>
	
	<cfif Len( a_str_token ) IS 0>
		<cfreturn />
	</cfif>
	
	

</cffunction>

<cffunction access="public" name="checkExternalIdentifierData" output="false" returntype="void" hint="check the provided data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfif Len( application.udf.GetCurrentSecurityContext().externalIdentifierKey ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'stExternalIdentifierData', getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).checkExternalIdentifierData( application.udf.GetCurrentSecurityContext() )) />

</cffunction>

<cffunction access="public" name="GetUserEntrykeyByUsername" output="false" returntype="void" hint="Load userdata given username">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_username = event.getArg( 'username', '' ) />
	
	<cfif Len( a_str_username ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfset event.setArg( 'userkey', getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserEntrykeyByUsername( a_str_username )) />
	
</cffunction>

<cffunction access="public" name="GetUserProfile" output="false" returntype="void" hint="load userdata and meta data">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_userkey = event.getArg( 'userkey' ) />
	
	<cfset event.setArg( 'a_struct_user_profile', getProperty( 'beanFactory' ).getBean( 'UserComponent').GetUserProfile( userkey = a_str_userkey ) ) />

</cffunction>

<cffunction access="public" name="GetUserData" output="false" returntype="void" hint="Load userdata of current user">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_transfer = getProperty( 'beanFactory' ).getBean( 'UsersTransfer' ).getTransfer() />								
	<cfset var a_struct_item = 0 />
	<cfset var a_str_userkey = application.udf.GetCurrentUserkey() />
	<cfset var a_str_default_library = application.udf.GetCurrentSecurityContext().defaultlibrarykey />
	<cfset var sHostLibraryLastkey = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetLibraryLastkey( a_str_default_library ) />
	
	<cfif Len(a_str_userkey) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- get user data by UUID --->
	<cfset a_struct_item = a_transfer.readByProperty('users.user', 'entrykey', a_str_userkey) />
	
	<!--- set the userdata ... --->
	<cfset arguments.event.setArg( 'a_struct_userdata', a_struct_item ) />
	
	<!--- library data --->
	<cfset arguments.event.setArg( 'a_str_default_library', a_str_default_library ) />
	<cfset arguments.event.setArg( 'sHostLibraryLastkey', sHostLibraryLastkey ) />
	
</cffunction>

<cffunction access="public" name="CheckMobileIntegrationActions" output="false" returntype="void" hint="Check if we should send out a confirmation SMS">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<!--- any action to perform? e.g. send confirmation or check code? --->
	<cfset var a_bol_send_confirmation = arguments.event.getArg( 'DoSendConfirmationCode', false ) />
	<cfset var a_bol_verify_code = arguments.event.getArg( 'DoVerifyConfirmationCode', false ) />	
	<cfset var a_cmp_mobile = getProperty( 'beanFactory' ).getBean( 'MobileComponent' ) />
	<cfset var a_struct_call = 0 />
	
	<!--- send out confirmation code --->
	<cfif a_bol_send_confirmation>
		<cfset a_struct_call = a_cmp_mobile.SendConfirmationSMS( securitycontext = application.udf.GetCurrentSecurityContext() ) />
		
		<cfset arguments.event.setArg( 'a_struct_confirmation_code_send_result', a_struct_call) />
	</cfif>
	
	<!--- verify code --->
	<cfif a_bol_verify_code>
		<cfset a_struct_call = a_cmp_mobile.VerifyConfirmationCode( securitycontext = application.udf.GetCurrentSecurityContext(), code = arguments.event.getArg( 'code') ) />
		
		<!--- send intro SMS to user --->
		<cfif a_struct_call.result>
			<cfset a_cmp_mobile.SendSetupSMS( securitycontext = application.udf.GetCurrentSecurityContext() ) />
		</cfif>
		
		<cfset arguments.event.setArg( 'a_struct_verify_confirmation_code', a_struct_call) />
	</cfif>
	
</cffunction>


<cffunction access="public" name="ChangeChangeLanguage" output="false" returntype="void" hint="check if the language has been changed by the user">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_str_lang_id = event.getArg( 'lang_id' ) />
	
	<!--- lang has changed --->
	<cfif a_str_lang_id NEQ application.udf.GetCurrentSecurityContext().lang_id>
		<!--- reload the security context --->
		<cfset session.a_struct_usercontext = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).GetUserContextByUserkey( application.udf.GetCurrentSecurityContext().entrykey ) />
		
		<cfset request.a_struct_usercontext = Duplicate( session.a_struct_usercontext ) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="CheckStoreUserData" output="false" returntype="void" hint="Store userdata if necessary">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_cmp_user = getProperty( 'beanFactory' ).getBean( 'UserComponent' ) />
	<!--- has data been stored? --->
	<cfset var a_bol_stored = event.getArg( 'stored', false ) />
	<!--- result --->
	<cfset var a_struct_return_store_user_data = 0 />
	<cfset var a_struct_update = StructNew() />
	
	<cfif a_bol_stored>
		
		<cfif event.isargdefined( 'email' )>
			<cfset a_struct_update.email = arguments.event.getArg( 'email' ) />
		</cfif>
		
		<cfif event.isargdefined( 'cellphone_nr' )>
			<cfset a_struct_update.cellphone_nr = arguments.event.getArg( 'cellphone_nr' ) />
		</cfif>
		
		<cfif event.isargdefined( 'lang_id' )>
			<cfset a_struct_update.lang_id = arguments.event.getArg( 'lang_id' ) />
		</cfif>
		
		<cfif event.isargdefined( 'countryisocode' )>
			<cfset a_struct_update.countryisocode = arguments.event.getArg( 'countryisocode' ) />
		</cfif>
		
		<cfif event.isargdefined( 'firstname' )>
			<cfset a_struct_update.firstname = arguments.event.getArg( 'firstname' ) />
		</cfif>
		
		<cfif event.isargdefined( 'surname' )>
			<cfset a_struct_update.surname = arguments.event.getArg( 'surname' ) />
		</cfif>
		
		<cfif event.isargdefined( 'about_me' )>
			<cfset a_struct_update.about_me = arguments.event.getArg( 'about_me' ) />
		</cfif>
		
		<cfif event.isargdefined( 'city' )>
			<cfset a_struct_update.city = arguments.event.getArg( 'city' ) />
		</cfif>
		
		<cfif event.isargdefined( 'zipcode' )>
			<cfset a_struct_update.zipcode = arguments.event.getArg( 'zipcode' ) />
		</cfif>
		
		<cfif event.isargdefined( 'rsslink' )>
			<cfset a_struct_update.rsslink = arguments.event.getArg( 'rsslink' ) />
		</cfif>
		
		<cfif event.isargdefined( 'homepage' )>
			<cfset a_struct_update.homepage = arguments.event.getArg( 'homepage' ) />
		</cfif>		
		
		<cfif event.isargdefined( 'privacy_playlists' )>
			<cfset a_struct_update.privacy_playlists = arguments.event.getArg( 'privacy_playlists' ) />
		</cfif>			
		
		<cfif event.isargdefined( 'privacy_newsfeed' )>
			<cfset a_struct_update.privacy_newsfeed = arguments.event.getArg( 'privacy_newsfeed' ) />
		</cfif>	
		
		<cfif event.isargdefined( 'privacy_profile' )>
			<cfset a_struct_update.privacy_profile = arguments.event.getArg( 'privacy_profile' ) />
		</cfif>		
			
		<!--- call update and set result --->
		<cfset a_struct_return_store_user_data = a_cmp_user.UpdateUserData(securitycontext = application.udf.GetCurrentSecurityContext(),
						newvalues = a_struct_update ) />
						
		<cfset arguments.event.setArg( 'a_struct_update_user_data_result', a_struct_return_store_user_data) />	
	
	</cfif>

</cffunction>

<cffunction name="CreateUser" access="public" output="false" returntype="void" hint="Create a new user"> 
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 

	<cfset var a_cmp_user = getProperty( 'beanFactory' ).getBean( 'UserComponent' ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var a_str_username = Trim(arguments.event.getArg('frmusername', '')) />
	<cfset var a_str_password = Trim(arguments.event.getArg('frmpassword', '')) />
	<cfset var a_str_email = Trim(arguments.event.getArg('frmemail', '')) />
	<cfset var a_str_city = Trim(arguments.event.getArg('frmcity', '')) />
	<cfset var a_str_zipcode = Trim(arguments.event.getArg('frmzipcode', '')) />
	<cfset var a_str_firstname = Trim(arguments.event.getArg('frmfirstname', '')) />
	<cfset var a_str_surname = Trim(arguments.event.getArg('frmsurname', '')) />
	<cfset var a_int_ctac_accepted = arguments.event.getArg('frmcatc', '0') />
	<cfset var a_str_country = arguments.event.getArg('frmcountry', 'at') />
	<cfset var a_struct_return_create_user = 0 />
	<cfset var a_str_lang_id = arguments.event.getArg( 'frmlang_id', 'en' ) />
	<cfset var a_str_source = arguments.event.getArg( 'frmsource', '' ) />
	<cfset var sEmail2 = event.getArg( 'frmemail2' ) />
	
	<!--- get invitation key --->
	<cfset var a_str_invitation_key = arguments.event.getArg( 'invitationkey', '' ) />
	
	<cfif a_int_ctac_accepted IS '0'>
		<cfset arguments.event.setArg( 'error', 5005 ) />
		<cfset announceEvent( "register.failed", arguments.event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- email addresses do not match --->
	<cfif CompareNoCase( sEmail2, a_str_email ) NEQ 0>
		
		<cfset arguments.event.setArg( 'error', 5007 ) />
		<cfset announceEvent( "register.failed", arguments.event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- call business CFC --->
	<cfinvoke component="#a_cmp_user#" method="CreateUser" returnvariable="a_struct_return_create_user">
		<cfinvokeargument name="username" value="#a_str_username#">
		<cfinvokeargument name="password" value="#a_str_password#">
		<cfinvokeargument name="email" value="#a_str_email#">
		<cfinvokeargument name="firstname" value="#a_str_firstname#">
		<cfinvokeargument name="surname" value="#a_str_surname#">
		<cfinvokeargument name="city" value="#a_str_city#">
		<cfinvokeargument name="zipcode" value="#a_str_zipcode#">
		<cfinvokeargument name="countryisocode" value="#a_str_country#">
		<cfinvokeargument name="lang_id" value="#a_str_lang_id#">
		<cfinvokeargument name="source" value="#a_str_source#">
	</cfinvoke>
	
	<!--- success? --->
	<cfif NOT a_struct_return_create_user.result>
		<cfset arguments.event.setArg('error', a_struct_return_create_user.error ) />
		<cfset announceEvent( "register.failed", arguments.event.getArgs() ) />
		<cfreturn />
	</cfif>
	
	<!--- everything went ok! ...set the userkey plus announce the event --->
	<cfscript>
	arguments.event.setArg( "logged_in_userkey", a_struct_return_create_user.entrykey );
	arguments.event.setArg( "logged_in_username", a_str_username );	
	announceEvent( "register.success", arguments.event.getArgs() );
	</cfscript>
	
	<!--- create a friendship ... the user who has invited will become the master, the new user the friend --->
	<cfif Len( a_str_invitation_key ) GT 0>
		
		<cfset application.beanFactory.getBean( 'SocialComponent' ).CreateFriendShipBasedOnInvitation( invitationkey = a_str_invitation_key,
							friend_userkey = a_struct_return_create_user.entrykey) />

	</cfif>
	
</cffunction>

<cffunction access="public" name="CheckInvitationkey" output="false" returntype="void"
		hint="Check the given invitation key">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_invitation_key = event.getArg( 'invitationkey', '' ) />
	<cfset var a_struct_check = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetInvitationData( invitationkey = a_str_invitation_key ) />
	
	<!--- if the invitation is correct, proceed --->	
	<cfset event.setArg( 'a_invitation_check', a_struct_check ) />
	<cfset event.setArg( 'source', 'invitation' ) />
	
	<!--- if result, load userdata --->
	<cfif a_struct_check.result>
		<cfset a_struct_check.a_user_data = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserData( a_struct_check.oItem.getUserkey() ) />
	</cfif>

</cffunction>

<cffunction access="public" name="CheckExternalSignupCreateAccount" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var bCreateReq = event.getArg( 'action' ) IS 'createaccount' />
	<cfset var oUser = application.beanFactory.getBean( 'UserComponent' ) />
	<cfset var oIdentities = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ) />
	<cfset var stCreateUser = {} />
	<cfset var stCreateBinding = {} />
	<cfset var stRPXData = oIdentities.GetRPXLoginData( event.getArg( 'entrykey' ) ) />	
	<cfset var stSecurityContext = {} />
	
	<!--- try to create an account --->
	<cfif bCreateReq>
		
		<cfif Val( arguments.event.getArg( 'acceptctac' )) IS 0>
			<cfset event.setArg( 'error', 5005 ) />
		</cfif>
		
		<cfif Len(application.udf.ExtractEmailAdr( event.getarg( 'email'))) IS 0>
			
		</cfif>
		
		<cfinvoke component="#oUser#" method="CreateUser" returnvariable="stCreateUser">
			<cfinvokeargument name="username" value="#event.getarg( 'username' )#">
			<cfinvokeargument name="password" value="#Left( CreateUUID(), 4 )#">
			<cfinvokeargument name="email" value="#event.getArg( 'email' )#">
			<cfinvokeargument name="firstname" value="#event.getArg( 'firstname' )#">
			<cfinvokeargument name="surname" value="#event.getArg( 'surname' )#">
			<cfinvokeargument name="city" value="#event.getArg( 'city' )#">
			<cfinvokeargument name="zipcode" value="#event.getArg( 'zipcode' )#">
			<cfinvokeargument name="countryisocode" value="at">
			<cfinvokeargument name="lang_id" value="#arguments.event.getArg( 'frmlang_id', 'en' )#">
			<cfinvokeargument name="source" value="rpx">
		</cfinvoke>
		
		<cfset event.setArg( 'stCreateUser', stCreateUser ) />
		
		<cfif NOT stCreateUser.result>
			<cfset event.setArg( 'error', stCreateUser.error ) />
			<cfreturn />
		<cfelse>
			
			<cfset stSecurityContext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( userkey = stCreateUser.entrykey ) />
			
			<!--- add the binding --->
			<cfinvoke component="#oIdentities#" method="StoreExternalIdentityLink" returnvariable="stCreateBinding">
				<cfinvokeargument name="securitycontext" value="#stSecurityContext#">
				<cfinvokeargument name="identifier" value="#stRPXData.oItem.getIdentifier()#">
				<cfinvokeargument name="provider" value="#stRPXData.oItem.getProvider()#">
				<cfinvokeargument name="complete_data" value="#DeSerializeJSON( stRPXData.oItem.getComplete_data() )#">
				<cfinvokeargument name="source" value="rpx" />
			</cfinvoke>
			
			<!--- try to fetch the photo of the other service --->			
			<cfset oIdentities.StoreUserPhotoOfOtherService( securitycontext = stSecurityContext, sLocation = DeSerializeJSON( stRPXData.oItem.getunified_userdata() ).PHOTO ) />
			
			<cfset event.setArg( 'stCreateBinding', stCreateBinding ) />
			
			<!--- waiting for confirmation email ... --->
			<cfset event.setArg( 'frmemail', event.getArg( 'email' ) ) />
			<cfset announceEvent( 'register.success', event.getArgs() ) />
			
			<!--- set the userkey/username of our securitycontext to create --->
			<!--- <cfset event.setArg( 'logged_in_userkey', stCreateUser.entrykey ) />
			<cfset event.setArg( 'logged_in_username', event.getArg( 'username' ) ) />
			
			<!--- log the provider --->
			<cfset event.setArg( 'provider', stRPXData.oItem.getProvider() ) />
			
			<!--- set the entrykey of this new binding --->
			<cfset event.setArg( 'externalidentifierkey', stCreateBinding.entrykey ) />
			
			<!--- perform normal login --->
			<cfset announceEvent( 'login.Succeeded', event.getArgs() ) /> --->
			
	
		</cfif>
	</cfif>

</cffunction>

<cffunction access="public" name="CheckLoadExternalAccountBinding" output="false" returntype="void"
		hint="load data of external account if key has been provided">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var sEntrykey = event.getArg( 'rpxkey' ) />
	<cfset var stRPXData = 0 />
	
	<cfif Len( sEntrykey ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfset stRPXData = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).GetRPXLoginData( sEntrykey ) />
	
	<cfset event.setArg( 'stRPXData', stRPXData ) />

</cffunction>

<cffunction access="public" name="CheckCreateExternalAccountBinding" output="false" returntype="void"
		hint="check if we should create a link to an external account now">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var sEntrykey = event.getArg( 'rpxkey' ) />
	<cfset var stRPXData = 0 />
	<cfset var stBinding = 0 />
	<cfset var sLoggedInUserkey = event.getArg( 'logged_in_userkey' ) />
	
	<!--- rpx data already available? --->
	<cfif IsStruct( event.getArg( 'rpxResult' ) )>
	
		<!--- UPDATE the binding --->
		<cfset stBinding =getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).StoreExternalIdentityLink( securitycontext = application.udf.GetCurrentSecurityContext(),
						identifier = event.GetArg( 'rpxResult' ).UNIFIEDUSERDATA.IDENTIFIER,
						provider = application.udf.GetCurrentSecurityContext().provider,
						source = 'rpx',
						complete_data = event.GetArg( 'rpxResult' ).unifieduserdata.complete_data ) />
	
	</cfif>
	
	
	<!--- rpx key available? --->
	<cfif Len( sEntrykey ) GT 0 AND Len( sLoggedInUserkey ) GT 0>
		<cfset stRPXData = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).GetRPXLoginData( sEntrykey ) />
		
		<cfif stRPXData.result>
			
			<!--- CREATE the binding --->
			<cfset stBinding = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).StoreExternalIdentityLink( securitycontext = application.udf.GetCurrentSecurityContext(),
						identifier = stRPXData.oItem.getIdentifier(),
						provider = stRPXData.oItem.getProvider(),
						source = 'rpx',
						complete_data = DeSerializeJSON( stRPXData.oItem.getcomplete_data() )) />
						
			<!--- RE-Create the securitycontext with this new information! --->

			
		</cfif>
	</cfif>

</cffunction>

<cffunction name="SignupUserCheckExternalDataSource" access="public" output="false" returntype="void"
		hint="Get data from other sources"> 
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<!--- check if we've a rpx powered structure --->
	<cfset var sSource = event.getArg( 'source' ) />
	<cfset var sEntrykey = event.getArg( 'entrykey' ) />
	<cfset var stRPXData = getProperty( 'beanFactory' ).getBean( 'IdentitiesComponent' ).GetRPXLoginData( sEntrykey ) />
	
	<cfif Len( sSource ) IS 0>
		<cfreturn />
	</cfif>
	
	<cfswitch expression="#sSource#">
		<cfcase value="rpx">
			
			<cfset event.setArg( 'stRPXData', stRPXData ) />
			
		</cfcase>
	</cfswitch>

</cffunction>

<cffunction name="CheckPasswordChangeRequest" access="public" output="false" returntype="void"
		hint="user wants to check pwd">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var bRequest = event.getArg( 'PasswordChangeRequest', false ) />
	<cfset var local = {} />
	<cfset var stPasswordChangeResult = application.udf.GenerateReturnStruct() />
	
	<cfif bRequest>
		<cfset local.oldpwd = event.getArg( 'frmoldpwd' ) />
		<cfset local.newpwd1 = event.getArg( 'frmnewpwd1' ) />
		<cfset local.newpwd2 = event.getArg( 'frmnewpwd2' ) />
		
		<!--- no match --->
		<cfif local.newpwd1 NEQ local.newpwd2>
			<cfset event.setArg( 'stPasswordChangeResult', application.udf.SetReturnStructErrorCode( stPasswordChangeResult, 500, application.udf.GetLangValSec( 'cm_ph_newpwds_no_match' ) )) />
			<cfreturn />
		</cfif>
		
		<cfset stPasswordChangeResult = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).changePasswordOfuser(
					securitycontext = application.udf.GetCurrentSecurityContext(),
					oldpwd = local.oldpwd,
					newpwd = local.newpwd1 ) />
					
		<cfset event.setArg( 'stPasswordChangeResult', stPasswordChangeResult ) />
	</cfif>

</cffunction>

<cffunction name="checkAccountConfirmation" access="public" output="false" returntype="void"
		hint="check account confirmation">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var local = {} />
	
	<cfset local.stConfirmAccount = getProperty( 'beanFactory' ).getBean( 'UserComponent').checkAccountConfirmation( skey = event.getArg( 'key' ), susername = event.getArg( 'username' )) />
	
	<cfset event.setArg( 'stConfirmAccount', local.stConfirmAccount ) />
	
	<cfif local.stConfirmAccount.result>
		
		<cfset event.setArg( 'logged_in_userkey', local.stConfirmAccount.sUserkey ) />		
		<cfset announceEvent( 'register.confirmaccount.success', event.getArgs() ) />		
		
		<cfreturn />
	</cfif>

</cffunction>

<cffunction name="checkSignOffRequest" access="public" output="false" returntype="void"
		hint="Check the signoff request">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var local = {} />
	
	<cfif Len( event.getArg( 'password' ))>
		
		<!--- check password --->
		<cfset local.stUserdata = getProperty( 'beanFactory' ).getBean( 'UserComponent').GetUserProfile( userkey = application.udf.GetCurrentSecurityContext().entrykey ) />
		<cfset local.sPassword = local.stUserdata.a_userdata.getpwd() />

		<cfif CompareNoCase( event.getArg( 'password' ), local.sPassword ) NEQ 0>
		
			<cfset event.setArg( 'sErrorMessage', application.udf.GetLangValSec( 'err_ph_12000' )) />
			
			<cfreturn />
			
		</cfif>
		
		<cfquery name="local.qSelect" datasource="mytunesbutleruserdata">
		SELECT
			*
		FROM
			users
		WHERE
			entrykey = <cfqueryparam value="#application.udf.GetCurrentSecurityContext().entrykey#" cfsqltype="cf_sql_varchar" />
		;
		</cfquery>
		
			
		<cfmail from="office@tunesBag.com" to="office@tunesBag.com" subject="user signoff data" type="html">
		comment: <pre>#event.getArg( 'comment' )#</pre>
		<cfdump var="#local.qSelect#">
		<cfdump var="#application.udf.GetCurrentSecurityContext()#" />
		</cfmail>
		
		<!--- delete account --->
		<cfquery name="local.qSelect" datasource="mytunesbutleruserdata">
		DELETE FROM
			users
		WHERE
			entrykey = <cfqueryparam value="#application.udf.GetCurrentSecurityContext().entrykey#" cfsqltype="cf_sql_varchar" />
		;
		</cfquery>
		
		<cfset StructClear( session ) />
		
		<cflocation addtoken="false" url="/">
		
		
	</cfif>

</cffunction>

</cfcomponent>