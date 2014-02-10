<!--- //

	Module:		Security Component for mach-ii
	Action:		
	Description:	
	
// --->

<!--- general security checker ... --->
<cfcomponent name="security" displayname="LoginListener" output="false" extends="MachII.framework.Listener" hint="LoginListener for tunesBag application">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" 
returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
<!--- do nothing --->
</cffunction> 

<cffunction access="public" name="checkSendLoginInformation" output="false" returntype="void" hint="send login information to user">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_username_send_pwd = event.getArg( 'username_sendpwd' ) />
	<cfset var a_struct_pwd = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).checkSendLoginInformation( username = a_str_username_send_pwd ) />
	
	<cfif Len( a_str_username_send_pwd ) GT 0>
		<cfset event.setArg( 'a_struct_send_pwd', a_struct_pwd ) />
	</cfif>

</cffunction>

<cffunction access="public" name="LogLogin" output="false" returntype="void" hint="log a login to database">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ).LogLogin( securitycontext = application.udf.GetCurrentSecurityContext(),
				user_agent = cgi.HTTP_USER_AGENT,
				ip = cgi.REMOTE_ADDR,
				provider = event.getArg( 'provider' ) ) />
</cffunction>

<cffunction name="validateLogin" access="public" output="false" returntype="void" hint="Validates a login attempt and announces a success or failure event"> 
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_struct_login_check = application.udf.GenerateReturnStruct() />
	<cfset var success = false />
	<cfset var sUsername = arguments.event.getArg('username') />
	<cfset var a_str_password = arguments.event.getArg("password") />
	<cfset var a_str_password_md5 = arguments.event.getArg( 'password_md5' ) />
	<cfset var a_cmp_security = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ) />
	
	<!--- 2do: hash the password ... --->
	<cfset a_str_password = a_str_password />
	
	<!--- perform check with plain text pwd or MD5 pwd? --->
	<cfif Len( a_str_password ) GT 0>
		<cfset a_struct_login_check = a_cmp_security.CheckLoginData(username = sUsername, password = a_str_password) />
	<cfelse>
		<cfset a_struct_login_check = a_cmp_security.CheckLoginData(username = sUsername, password_md5 = a_str_password_md5) />
	</cfif>
	
	<cfscript>
	if (a_struct_login_check.result) { 
		// alright, everything OK
		success = true;
		arguments.event.setArg('logged_in_userkey', a_struct_login_check.userkey);
		arguments.event.setArg('logged_in_username', sUsername);
		announceEvent("login.Succeeded", arguments.event.getArgs()); 
		}
		else
			{ 
			// put a message in the event argument so we can tell 
			// the user their login failed 
			arguments.event.setArg("message", application.udf.GetLangValSec( 'err_ph_12000' ) );
			arguments.event.setArg("loginfailed", true); 
			announceEvent("login.Failed", arguments.event.getArgs()); 
			} 
	</cfscript> 
</cffunction>

<!--- set session vars --->
<cffunction access="public" name="SetSessionVariables" output="false" returntype="void">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_userkey = event.getArg( 'logged_in_userkey' ) />
	<cfset var a_cmp_security = getProperty( 'beanFactory' ).getBean( 'SecurityComponent' ) />
	<cfset var sProvider = event.getArg( 'provider', '' ) />
	<cfset var sexternalidentifierkey = event.getArg( 'externalidentifierkey', '' ) />
	
	<!--- invalid --->
	<cfif Len( a_str_userkey ) IS 0>
		<cfreturn />
	</cfif>
	
	<cflock scope="session" type="exclusive" timeout="30">
		<cfset session.loggedIn = true />
		
		<!--- set the security context --->
		<cfset session.a_struct_usercontext = a_cmp_security.GetUserContextByUserkey( userkey = a_str_userkey,
						provider = sProvider,
						externalidentifierkey = sexternalidentifierkey ) />
		
	</cflock>
	
	<!--- copy to request scope for lock-free access --->
	<cflock scope="session" timeout="3" type="exclusive">
		<cfset request.a_struct_usercontext = Duplicate(session.a_struct_usercontext) />
	</cflock>
	
</cffunction>

<!--- remove all session vars --->
<cffunction access="public" name="RemoveSessionVariables" output="false" returntype="void"
	hint="remove all session vars (= logout user)">
		
	<cfset var tmp = false />
	
	<cflock scope="session" type="exclusive" timeout="30">
		<cfset session.loggedIn = false />
		
		<cfif StructKeyExists(session, 'a_struct_usercontext')>
			<cfset tmp = StructDelete(session, 'a_struct_usercontext')>
		</cfif>
		
	</cflock>

</cffunction>

<cffunction access="public" name="CheckPublicAccess" output="false" returntype="void" hint="Check if a user profile is available to the public">
	<cfreturn />
</cffunction>

<cffunction access="public" name="checkIsLoggedInRedirector" output="false" returntype="void"
		hint="redirect to library if logged in and no special page has been requested">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- 
	
		if the user is logged in and no special page has been requested, forward
		to /start/
		
	 --->
	<cfif application.udf.IsLoggedIn()>
		<cflocation addtoken="false" url="/start/" />
	</cfif>

</cffunction>

</cfcomponent>