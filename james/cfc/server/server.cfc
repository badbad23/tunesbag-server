<!--- server management --->

<cfcomponent output="false" hint="server management">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction name="init" returntype="any" output="false" hint="constructor">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="getStreamingEngineAssignment" output="false" returntype="struct"
			hint="return the streaming engine to use">
		<cfargument name="securitycontext" type="struct" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var qSelect = 0 />
		
		<cfquery name="qSelect" datasource="mytunesbutlerlogging" cachedwithin="#CreateTimeSpan(0, 0, 0, 30)#">
		SELECT
			hostname
		FROM
			serverpool
		WHERE
			enabled = 1
			AND
			isstreaming = 1
		/* TODO: check countryisocode to find nearest server ... */
		ORDER BY
			serverload
		LIMIT
			1
		;
		</cfquery>
		

		<cfif qSelect.recordcount IS 0>
			<cfset stReturn.sServerName = application.udf.GetSettingsProperty( 'DefaultStreamingServer' , 'streaming01.tunesBag.com' ) />
		<cfelse>
			<cfset stReturn.sServerName = qSelect.hostname />
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>
	
	<cffunction access="public" name="getUploadEngineAssignment" output="false" returntype="struct"
			hint="return the upload server to use">
		<cfargument name="securitycontext" type="struct" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var sDefaultServer = application.udf.GetSettingsProperty( 'DefaultIncomingServer' , 'streaming01.tunesbag.com' ) />
		<cfset var qSelect = 0 />
		
		<cfquery name="qSelect" datasource="mytunesbutlerlogging">
		SELECT
			hostname
		FROM
			serverpool
		WHERE
			enabled = 1
			AND
			isincoming = 1
		/* TODO: check countryisocode to find nearest server ... */
		ORDER BY
			serverload
		LIMIT
			1
		;
		</cfquery>
		
		<cfif qSelect.recordcount IS 0>
			<cfset stReturn.sServerName = sDefaultServer />
		<cfelse>
			<cfset stReturn.sServerName = qSelect.hostname />			
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

	</cffunction>


</cfcomponent>