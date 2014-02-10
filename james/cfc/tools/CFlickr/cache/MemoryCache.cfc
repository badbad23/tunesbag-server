<cfcomponent extends="CFlickr.cache.AbstractCache" hint="Caches responses from the Flickr API to memory, internally.<br> You should place an instance of this class in a persistent scope, such as application, or session so that responses are cached between requests.">

	<cfset variables.default_timeout = 3600>
	<cfset variables.data = structnew()>

	<cffunction name="init" access="public" output="false" returntype="CFlickr.cache.AbstractCache">
		<cfargument name="timeout" type="numeric" required="no" default="3600" hint="seconds">
		<cfset variables.default_timeout = arguments.timeout>
		<cfreturn this>
	</cffunction>

	<cffunction name="existsInCache" access="public" output="false" returntype="boolean">
		<cfargument name="params" type="struct" required="yes">
		<cfset var key = createHash(arguments.params)>
		<cfreturn structkeyexists(variables.data, key) AND datediff("s", variables.data[key].date, now()) LT variables.default_timeout>
	</cffunction>

	<cffunction name="getFromCache" access="public" output="false" returntype="any">
		<cfargument name="params" type="struct" required="yes">
		<cfset var key = createHash(arguments.params)>
		<cfif NOT existsInCache(params)>
			<cfthrow errorcode="CFlickr.Cache.NotFoundInCache" message="The requested object could not be found in the cache">
		</cfif>			
		<cfreturn variables.data[key].xml>
	</cffunction>

	<cffunction name="saveToCache" access="public" output="false" returntype="void">
		<cfargument name="params" type="struct" required="yes">
		<cfargument name="xml" type="string" required="yes">
		<cfset var key = createHash(arguments.params)>
		<cfset variables.data[key] = structnew()>
		<cfset variables.data[key].date = now()>
		<cfset variables.data[key].xml = xml>
	</cffunction>

	<cffunction name="purgeCache" access="public" output="false" returntype="void">
		<cfset var i = "">
		<cfloop collection="#variables.data#" item="i">
			<cfif datediff("s", variables.data[i].date, now()) GT variables.default_timeout>
				<cfset structdelete(variables.data, i)>
			</cfif>
		</cfloop>
	</cffunction>
	
</cfcomponent>