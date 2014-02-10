<cfcomponent output="false" accessors="true">
	
	<cfproperty name="beans" type="struct" />
	
	<cffunction access="public" name="init" output="false" returntype="any">
		
		<!--- init using the coldspring file --->
		
		<!--- parse and create structure --->
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="getBean" output="false" returntype="any">
		<cfargument name="sBeanName" type="string" required="true"
			hint="The bean to load" />
		
		<!--- create in application.cfc.oXYZ and return --->
		
		<cfset local.bBeanExists = !IsNull( application.cfc[ arguments.sBeanName ]) />
		
		<!--- bean exists at all? --->
		<cfset local.bValidBean = false />
		
		
		<cfif local.bBeanExists>
			<cfreturn application.cfc[ arguments.sBeanName ] />
		<cfelse>
		
			<!--- create bean and return --->
			
			<!--- find out path --->
		
		</cfif>
		
	</cffunction>
	
	<cffunction access="private" name="parseColdSpringFile" output="false" returntype="struct"
			hint="Parse the coldspring file and return the structure">
	
	</cffunction>
	
</cfcomponent>