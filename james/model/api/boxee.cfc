<!--- 

	boxee demo

 --->


<cfcomponent name="rest" displayname="rest" output="false" extends="MachII.framework.Listener" hint="Handle REST calls">
	
	<cfinclude template="/common/scripts.cfm">

	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
		<!--- do nothing --->
	</cffunction> 
	
	<cffunction access="public" name="BoxeeStart" output="false" returntype="void">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
		<cfset var a_username = event.getArg( 'username' ) />
		<cfset var a_remotekey = event.getArg( 'remotekey' ) />
		
		<cfif Len( a_username ) GT 0 AND Len( a_remotekey ) GT 0>
			<cflocation addtoken="false" url="/api/rest/rss.welcome&appkey=7706ECA1-F205-9A74-1C41F00931943688&username=#Urlencodedformat( a_username )#&remotekey=#urlencodedformat( a_remotekey )#">
		</cfif>
	
	</cffunction>

</cfcomponent>