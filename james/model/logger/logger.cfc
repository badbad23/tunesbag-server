<!--- //

	Module:		Logger compnent
	Description: 
	
// --->

<cfcomponent name="logger" displayname="Logging component"output="false" extends="MachII.framework.Listener" hint="Logger for tunesBag application">

<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="getSingleStatusLogItem" output="false" returntype="void"
		hint="return the log items">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var q_select_log_item = getProperty( 'beanFactory' ).getBean( 'LogComponent' ).getSingleStatusLogItem( entrykey = event.getArg( 'entrykey' ) ).q_select_log_item />
	<cfset event.setArg( 'q_select_log_item', q_select_log_item ) />

</cffunction>

<cffunction access="public" name="GetLastUserActivities" output="false" returntype="void"
		hint="get the lately activities of this user">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<!--- filter out certain action ... fan of artist, playlist, become friends ... comment on plist--->
	<cfset var a_filter = { actions = '100,620,601,802' } />
	<cfset var q_select_log_items = getProperty( 'beanFactory' ).getBean( 'LogComponent' ).GetLastUserActivities( userkey = event.getArg( 'userkey' ), filter = a_filter ).q_select_log_items />
	<cfset event.setArg( 'q_select_last_log_items', q_select_log_items ) />

</cffunction>

<cffunction access="public" name="GetLogItems" output="false" returntype="void"
		hint="return the log items">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var q_select_log_items = 0 />
	<!--- filter out certain actions if parameter has been provided --->
	<cfset var a_str_filter_actions = event.getArg( 'filter_actions', '' ) />
	<cfset var a_int_max_age_days = event.getArg( 'maxagedays', 0 ) />
	<cfset var a_struct_filter = {  actions =  a_str_filter_actions } />
	<cfset var a_struct_log_items = getProperty( 'beanFactory' ).getBean( 'LogComponent' ).GetLogItems( securitycontext = application.udf.GetCurrentSecurityContext(),
										filter = a_struct_filter,
										maxagedays = a_int_max_age_days ) />
	
	<cfset q_select_log_items = a_struct_log_items.q_select_log_items />
	
	<cfset event.setArg( 'q_select_log_items', q_select_log_items ) />
</cffunction>

<cffunction name="LogLastPlayed" access="public" output="false" returntype="void"
		hint="Store log information in database"> 
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_cmp_log = getProperty( 'beanFactory' ).getBean( 'LogComponent' )>
	
	<cfset a_cmp_log.LogMediaItemPlayed( securitycontext = application.udf.GetCurrentSecurityContext(),
						ip = cgi.REMOTE_ADDR,
						mediaitemkey = event.getArg( 'entrykey' ) ) />	
</cffunction>

<cffunction access="public" name="LogProfileVisit" output="false" returntype="void"
		hint="log visit of a profile">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 
	
	<cfset var a_str_username = event.getArg( 'username' ) />
	<cfset var a_cmp_log = getProperty( 'beanFactory' ).getBean( 'LogComponent' )>
	
	
	<!--- <cfset a_cmp_log.LogAction( securitycontext = application.udf.GetCurrentSecurityContext(),
				action = 200,
				linked_objectkey = '',
				objecttitle = a_str_username,
				private = 0) /> --->


</cffunction>

<cffunction access="public" name="logSourceReferer" output="false" returntype="void"
		hint="log the source referer">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var local = {} />
	
	<cfset local.sHTTPReferer = cgi.HTTP_REFERER />
	<cfset local.sHTTPHost = 'http://' & cgi.HTTP_HOST />
	<cfset local.sKeywords = '' />
	
	<!--- generic referer is given in the URL
		
		this can be a campain but an inviation as well
		 --->
	<cfif StructKeyExists( url, 'ref' )>
		
		
		<!--- store referer code as cookie --->
		<cfcookie expires="90" name="ref" value="#url.ref#" />
		
	</cfif>
	
	<!--- if the referer does not contain the hostname it's coming from outside --->
	
	<cfif Len( local.sHTTPReferer ) IS 0>
		<cfreturn />
	</cfif>
	
	<!--- cookie already exists --->
	<cfif StructKeyExists( cookie, 'HTTP_REFERER' )>
		<!--- <cfreturn /> --->
		
		<!--- ignore, overwrite previous source --->
	</cfif>
	
	<!--- referer is local site ... do not log --->
	<cfif FindNoCase( local.sHTTPHost, local.sHTTPReferer) IS 1>
		<cfreturn />
	</cfif>
	
	<cfcookie expires="90" name="http_referer" value="#local.sHTTPReferer#" />
	
	<!--- try to get the right keyword --->
	<cftry>
		<cfset local.StartPos = ReFindNoCase('q=.',local.sHTTPReferer) />
    	
		<cfif local.StartPos GT 0>
			<cfset local.sEndString = Mid( local.sHTTPReferer, local.startPos + 2, Len( local.sHttpReferer )) />
			
			<cfset local.sKeywords = ReReplaceNoCase(local.sEndString,'&.*','','ALL') />
			<cfset local.sKeywords = URLDecode( local.sKeywords ) />
			
		</cfif>
		
		<cfcatch type="any">
			<cflog application="false" file="tb_kw_error" log="Application" text="#cfcatch.Message#" type="information" />
		</cfcatch>
	</cftry>
	
	<!--- write to database --->
	<!--- <cfquery name="local.qInsertLog" datasource="mytunesbutlerlogging">
	INSERT INTO
		referer_log
		(
		dt_created,
		urltoken,
		ip,
		countryisocode,
		http_referer,
		keywords	
		)
	VALUES
		(
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.SessionID#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_ADDR#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#getProperty( 'beanFactory' ).getBean( 'LicenceComponent' ).IPLookupCountry( cgi.REMOTE_ADDR )#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left( local.sHTTPReferer, 500 )#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#Left( local.sKeywords, 100 )#">
		)
	;
	</cfquery> --->
	
	

</cffunction>

</cfcomponent>