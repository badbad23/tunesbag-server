<cfcomponent
	extends="MachII.mach-ii"
	output="false">

	<!---
	PROPERTIES - APPLICATION SPECIFIC
	
	every domain has it's own app scope, but make sure www. and . are the same app
	--->
	
	<cfset variables.sSpiderBots = 'Railo,CFSCHEDULE,msnbot,Feedfetcher-Google,Twiceler,slurp,Googlebot,jeeves,YoudaoBot,Mediapartners-Google,Baiduspider,Teoma,Ask.com,facebookexternalhit' />
	<cfset request.bIsSpiderRequest = false />
	
	<!--- Check for bots - give a short lifespan --->
	<cfif Len(CGI.HTTP_USER_AGENT)>
		<cfloop list="#variables.sSpiderBots#" index="bot" delimiters=",">
			
			<cfif findnocase(bot, CGI.HTTP_USER_AGENT)>
				<!--- just a minute --->
				<cfset this.sessionTimeout = createtimespan(0,0,1,0) />
				<cfset request.bIsSpiderRequest = true />
				
				<cfbreak />
			</cfif>
			
		</cfloop>
	</cfif>
	
	<!--- app data --->	
	<cfset this.name = "tbSEO" & Hash( Replace( cgi.SERVER_NAME, 'www.', '' )) />
	<cfset this.loginStorage = "session" />
	
	
	<!--- no session management for spiders --->
	<cfif request.bIsSpiderRequest>
		<cfset this.sessionManagement = false />
	<cfelse>

		<!--- 
		
			enable session management, use cache and internal session type instead of j2ee
		
		 --->
		<cfset this.sessionManagement = true />
		
		<cfset this.sessionStorage = 'sessioncache' />
		
		<!--- https://issues.jboss.org/browse/RAILO-1163 --->
		<cfset this.sessionType = 'cfml' />
		
		<!--- https://issues.jboss.org/browse/RAILO-1213 --->
		<cfset this.sessionCluster = true  />
	</cfif>
	
	<cfset this.clientManagement = false />
	<cfset this.setClientCookies = true />
	<cfset this.setDomainCookies = false />
	
	<!--- 1 hour by default --->
	<cfset this.sessionTimeOut = CreateTimeSpan(0, 1, 0, 0) />
	
	<cfset this.applicationTimeOut = CreateTimeSpan(1,0,0,0) />
	
	<cfinclude template="../common/scripts.cfm">
	
	<!--- facebook fix (http://www.coldfusionjedi.com/index.cfm/2007/9/21/Fixing-the-Facebook-Problem-and-why-one-ColdFusion-feature-needs-to-die) --->
	<cfif structKeyExists(form, "FB_SIG")>
		<cfset form.FB_SIG_FB = form.FB_SIG />
		<cfset form.FB_SIG = '' />
	</cfif>
	
	<!--- default (=ORM) datasource --->
	<cfset this.datasource = 'mytunesbutlercontent' />
	
	<!--- enable ORM --->
	<cfset this.ormEnabled = true /> 
	
	<!--- logSQL = false, useDBForMapping = true, c --->
	<cfset this.ormSettings = { dialect = 'MySQLwithInnoDB', cfclocation = 'james.cfc.orm' } />

	<!---
	PROPERTIES - MACH-II SPECIFIC
	--->
	<!---Set the path to the application's mach-ii.xml file --->
	<cfset MACHII_CONFIG_PATH = ExpandPath("./config/mach-ii.xml") />
	<!--- Set the app key for sub-applications within a single cf-application. --->
	<cfset MACHII_APP_KEY =  GetFileFromPath(ExpandPath(".")) />
	<!--- Set the configuration mode (when to reinit): -1=never, 0=dynamic, 1=always --->
	<cfset MACHII_CONFIG_MODE = -1 /> <!--- GetSettingsProperty( 'MACHII_CONFIG_MODE',  '-1' ) /> --->
	<!--- Whether or not to validate the configuration XML before parsing. Default to false. --->
	<cfset MACHII_VALIDATE_XML = FALSE />
	<!--- Set the path to the Mach-II's DTD file. --->
	<cfset MACHII_DTD_PATH = ExpandPath("/MachII/mach-ii_1_1_1.dtd") />
	

	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="onApplicationStart" returnType="void" output="false"
		hint="Only runs when the App is started.">
		<cfsetting requesttimeout="120" />
		<cfset application.startTime = Now() />
		
		<cfset LoadFramework() />
	</cffunction>

	<cffunction name="onApplicationEnd" returntype="void" output="false"
		hint="Only runs when the App is shut down.">
		<cfargument name="ApplicationScope" required="true"/>
	</cffunction>

	<cffunction name="onSessionStart" returntype="void" output="false"
		hint="Only runs when a session is created.">
		<!---
		Example onSessionStart in a Session Facade
		<cfset getProperty("sessionFacade").onSessionStart() />
		--->
	</cffunction>

	<cffunction name="onSessionEnd" returntype="void" output="false"
		hint="Only run when a session ends.">
		<cfargument name="SessionScope" required="true"/>
		<!---
		Example onSessionEnd
		<cfset getProperty("sessionFacade").onSessionEnd(arguments.SessionScope) />
		--->
	</cffunction>
	
	<cffunction name="onError" returnType="void">
	   <cfargument name="Exception" required=true/>
	   <cfargument name="EventName" type="String" required=true/>
	  
	 <!---  <cfdump var="#Exception#"> --->
	  
	   <cftry>
	   <cfmail from="hp@inbox.cc" to="hp@inbox.cc" subject="tunesBag unhandled exception" type="html">
			<cfdump var="#arguments#">
		</cfmail>
		<cfcatch type="any">
			<!--- no mail server defined --->
		</cfcatch>
		</cftry>
	   
	  <cfdump var="#arguments#"> 
	</cffunction>

	<cffunction name="onRequestStart" returnType="void" output="true"
		hint="Run at the start of a page request.">
		<cfargument name="targetPage" type="string" required="true" />
		
		<cfset var bLangLoaded = false />
		<cfset var a_str = '' />
		<cfset var tc_start = getTickCount() />
		
		<cfset request.tc_start = tc_start />
		
		<!--- include UDFs --->
		<cfinclude template="inc_udf.cfm" />
		
		<!--- include consts --->
		<cfinclude template="inc_consts.cfm" />
		
		<!--- make sure cfcs are running --->
		<cfinclude template="inc_cfc.cfm" />
				
		<!--- <cflock scope="application" type="readonly" timeout="3"> --->
			<cfset bLangLoaded = StructKeyExists(application, 'langdata') />
		<!--- </cflock> --->
		
		<cfif NOT bLangLoaded AND StructKeyExists( application, 'beanFactory' )>
			<cflock scope="Application" type="exclusive" timeout="30">
				<cfset application.beanFactory.getBean( 'translang' ) />
			</cflock>
		</cfif>
				
		<!--- split special javascript arguments to default url variables --->
		<cfif StructKeyExists(url, 'params')>
			<cfloop list="#url.params#" delimiters="&" index="a_str">
				<cfif ListLen(a_str, '=') IS 2>
					<cfset url[ListGetAt(a_str, 1, '=')] = ListGetAt(a_str, 2, '=') />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- copy security context to request scope ... in case a session management has been enabled --->
		<cfif application.udf.SessionManagementEnabled()>
		
				<cfif StructKeyExists(session, 'a_struct_usercontext')>
					<cfset request.a_struct_usercontext = Duplicate(session.a_struct_usercontext) />
				</cfif>
			
		</cfif>
		
		<!--- init environments --->
		<cftry>
		<cfset application.beanFactory.getBean( 'Environments' ) /> 
			<cfcatch type="any">
			
			</cfcatch>
		</cftry>
		
		<!--- Request Scope Variable Defaults --->
		<cfset request.self = "index.cfm" />

		<!--- Set per session cookies if not using J2EE session management --->
		<!--- <cfif StructKeyExists(session, "cfid") AND (NOT StructKeyExists(cookie, "cfid") OR NOT StructKeyExists(cookie, "cftoken"))>
			<cfcookie name="cfid" value="#session.cfid#" />
			<cfcookie name="cftoken" value="#session.cftoken#" />
		</cfif> --->

		<!--- Temporarily override the default config mode
			Set the configuration mode (when to reinit): -1=never, 0=dynamic, 1=always --->
		<cfif StructKeyExists(url, "reinit")>
			<cfsetting requesttimeout="120" />
			<cfset MACHII_CONFIG_MODE = 1 />
		</cfif>

		<!--- Handle the request. Make sure we only process Mach-II requests. --->
		<cfif findNoCase('index.cfm', listLast(arguments.targetPage, '/'))>
			<cfset handleRequest() />
		</cfif>
		
		<!--- <cflog application="false" file="tb_runtime" log="Application" text="#( getTickCount() - tc_start )# #cgi.SCRIPT_NAME#?#cgi.query_string#"> --->
		
	</cffunction>

</cfcomponent>