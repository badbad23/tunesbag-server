<cfcomponent>

	<cffunction name="init" access="public" output="false" returntype="CFlickr.cache.AbstractCache">
		<cfreturn this>
	</cffunction>

	<cffunction name="existsInCache" access="public" output="false" returntype="boolean">
		<cfargument name="params" type="struct" required="yes">
		<cfreturn false>
	</cffunction>

	<cffunction name="getFromCache" access="public" output="false" returntype="string">
		<cfargument name="params" type="struct" required="yes">
		<cfreturn "">
	</cffunction>

	<cffunction name="saveToCache" access="public" output="false" returntype="void">
		<cfargument name="params" type="struct" required="yes">
		<cfargument name="data" type="string" required="yes">
		<cfargument name="cachefor" type="numeric" required="no" default="0">
	</cffunction>

	<cffunction name="purgeCache" access="public" output="false" returntype="void">
	</cffunction>

	<cffunction name="createHash" access="private" output="false" returntype="string">
		<cfargument name="params" type="struct" required="yes">
		<cfset var s = "">
		<cfset var h = "">
		<cfset var i = "">
		<cfset var paramlist = listsort(lcase(structkeylist(arguments.params)), "TEXT")>
		<cfloop list="#paramlist#" index="i">
			<cfset s = s & i & params[i]>
		</cfloop>
		<cfreturn hash(s)>
	</cffunction>
	
	
</cfcomponent>