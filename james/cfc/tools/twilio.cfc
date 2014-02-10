<cfcomponent output="false" accessors="true">
	
	<cfproperty name="sAccountSID" type="string" default="AC2c677e2e603fb28879930a256f9756cd" />
	<cfproperty name="sAuthToken" type="string" default="15f2a4521f7af2e3dd70b772aaffedf2" />
	
	<cffunction access="public" name="init" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="callPerson" returntype="struct" output="false">
		<cfargument name="sTo" type="string" required="true"
			hint="Number to call in +[countrycode][network][number] format" />
		<cfargument name="sCallID" type="string" required="true"
			hint="Call ID data">
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.rootUrl = (
			"http://" &
			cgi.server_name &
			getDirectoryFromPath( cgi.script_name )
			 ) />
		
		<cfhttp result="local.outboundCall"
				method="post"
				url="https://api.twilio.com/2010-04-01/Accounts/#getsAccountSID()#/Calls"
				username="#getsAccountSID()#"
				password="#getsAuthToken()#">
				
			<cfhttpparam
				type="formfield"
				name="From"
				value="+16502671232"
				/>
				
			<cfhttpparam
				type="formfield"
				name="To"
				value="#arguments.sTo#"
				/>
				
			<cfhttpparam
				type="formfield"
				name="Url"
				value="#local.rootUrl#play.cfm?id=#arguments.sCallID#"
				/>


		</cfhttp>
		
		<cfset stReturn.stHTTP = local.outboundCall />
		
		
		<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
	
	</cffunction>

</cfcomponent>