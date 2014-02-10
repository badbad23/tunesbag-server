<cfcomponent extends="CFlickr.cache.AbstractCache" hint="
	Caches responses to the file system
">

	<cfset variables.cachepath = "">
	<cfset variables.default_timeout = 3600000> <!--- milliseconds used internally --->
	<cfset variables.java_sysobj = createObject("java", "java.lang.System")>
	<cfset variables.ps = java_sysobj.getProperty("file.separator")>

	<cffunction name="init" access="public" output="false" returntype="CFlickr.cache.AbstractCache">
		<cfargument name="cachepath" type="string" required="yes" hint="path to cache xml in">
		<cfargument name="timeout" type="numeric" required="no" default="3600" hint="seconds">
		<cfset variables.cachepath = arguments.cachepath>
		<cfset variables.default_timeout = arguments.timeout*1000>
		<cfreturn this>
	</cffunction>

	<cffunction name="existsInCache" access="public" output="false" returntype="boolean">
		<cfargument name="params" type="struct" required="yes">
		<cfset var filename = "#variables.cachepath#/#createHash(arguments.params)#">
		<cfset var cachefile = createobject("java", "java.io.File").init(filename)>
		<cfset var time = createobject("java", "java.util.Date").getTime()>
		<cfreturn cachefile.exists() AND time-cachefile.lastModified() LT variables.default_timeout>
	</cffunction>

	<cffunction name="getFromCache" access="public" output="false" returntype="any">
		<cfargument name="params" type="struct" required="yes">

		<cfset var filename = "#variables.cachepath##variables.ps##createHash(arguments.params)#">
		<cfset var xml = "">

		<cfif NOT existsInCache(params)>
			<cfthrow errorcode="CFlickr.Cache.NotFoundInCache" message="The requested object could not be found in the cache">
		</cfif>
				
		<cftry>
			<cffile action="read" file="#filename#" variable="xml">
			<cfcatch type="any"></cfcatch>
		</cftry>
		
		<cfreturn xml>
	</cffunction>

	<cffunction name="saveToCache" access="public" output="false" returntype="void">
		<cfargument name="params" type="struct" required="yes">
		<cfargument name="xml" type="string" required="yes">
		<cffile action="write" file="#variables.cachepath##variables.ps##createHash(arguments.params)#" output="#arguments.xml#" nameconflict="overwrite">
	</cffunction>

	<cffunction name="purgeCache" access="public" output="false" returntype="void">
		<cfset var cachedir = createobject("java", "java.io.File").init(variables.cachepath)>
		<cfset var aFiles = cachedir.listFiles()>
		<cfset var time = createobject("java", "java.util.Date").getTime()>
		<cfset var i = 0>
		<cfset var file = "">
		<cfloop from="1" to="#arraylen(aFiles)#" index="i">
			<cfdump var="#aFiles[i].getPath()#"><br>
			<cfif time-aFiles[i].lastModified() GT variables.default_timeout>
				<cfset aFiles[i].delete()>
			</cfif>
		</cfloop>
	</cffunction>
	

</cfcomponent>