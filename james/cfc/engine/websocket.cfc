<cfcomponent>
	
	
	<cffunction name="init" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<cfset variables.aConn = [] />
	
	<cffunction name="onClientOpen" returntype="void">
		
		<!--- <cfset variables.aConn --->
		
		<!--- <cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="onclientopen" type="html">
		<cfdump var="#arguments#">
		</cfmail> --->
		
	</cffunction>
	
	<cffunction name="onMessage" returntype="void">
		
		<!--- <cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="onMessage arguments" type="html">
			<cftry>
			
			<cfdump var="#arguments#">
		<cfcatch type="any">
		<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>
		</cfmail> --->
		
		
		
	</cffunction>
	
	<cffunction name="onClientClose" returntype="void">
		<!--- <cfmail from="post@hansjoergposch.com" to="post@hansjoergposch.com" subject="onclientopen" type="html">
		<cfdump var="#arguments#">
		</cfmail> --->
	
	</cffunction>
	
</cfcomponent>