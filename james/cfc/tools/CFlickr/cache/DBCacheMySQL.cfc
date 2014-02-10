<cfcomponent extends="CFlickr.cache.AbstractCache" hint="
	Caches responses from the Flickr API to a MySQL database.<br>
	Requires a table with the follow structure<br>

<blockquote>
CREATE TABLE  `table_name` (<br>
  `id` varchar(32) NOT NULL,<br>
  `date` datetime NOT NULL,<br>
  `data` text NOT NULL,<br>
  PRIMARY KEY  (`id`)<br>
) ENGINE=MyISAM DEFAULT CHARSET=utf8;<br>
</blockquote>
	
">

	<cfset variables.dsn = "">
	<cfset variables.table = "">
	<cfset variables.username = "">
	<cfset variables.password = "">
	<cfset variables.default_timeout = 3600> 

	<cffunction name="init" access="public" output="false" returntype="CFlickr.cache.AbstractCache">
		<cfargument name="dsn" type="string" required="yes" hint="name of the dsn to use">
		<cfargument name="table" type="string" required="yes" hint="name of the table to store cached data in">
		<cfargument name="username" type="string" required="no" default="" hint="username to connect to dadabase">
		<cfargument name="password" type="string" required="no" default="" hint="password to connect to dadabase">
		<cfargument name="timeout" type="numeric" required="no" default="3600" hint="seconds">
		<cfset variables.dsn = arguments.dsn>
		<cfset variables.table = arguments.table>
		<cfset variables.username = arguments.username>
		<cfset variables.password = arguments.password>
		<cfset variables.default_timeout = arguments.timeout>
		<cfreturn this>
	</cffunction>

	<cffunction name="existsInCache" access="public" output="false" returntype="boolean">
		<cfargument name="params" type="struct" required="yes">
		<cfset var key = createHash(arguments.params)>
		<cfset var qExists = "">

		<cfquery name="qExists" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT `id`, `date` FROM `#variables.table#`
		WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#key#">
		AND `date` > #createodbcdatetime(now())#
		</cfquery>
		<cfreturn yesnoformat(qExists.recordcount) />
	</cffunction>

	<cffunction name="getFromCache" access="public" output="false" returntype="any">
		<cfargument name="params" type="struct" required="yes">
		<cfset var key = createHash(arguments.params)>
		<cfset var qGetFromCache = "">
		
		<cfquery name="qGetFromCache" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		SELECT `id`, `date`, `data` FROM `#variables.table#`
		WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#key#">
		AND `date` > #createodbcdatetime(now())#
		</cfquery>
		
		<cfif qGetFromCache.recordcount EQ 0 OR datediff("s", qGetFromCache.date, now()) GT variables.default_timeout>
			<cfthrow errorcode="CFlickr.Cache.NotFoundInCache" message="The requested object could not be found in the cache">
		</cfif>

		<cfreturn qGetFromCache.data>
	</cffunction>

	<cffunction name="saveToCache" access="public" output="false" returntype="void">
		<cfargument name="params" type="struct" required="yes">
		<cfargument name="data" type="string" required="yes">
		<cfargument name="cachefor" type="numeric" required="no" default="#variables.default_timeout#" hint="cache response for this many seconds, if not supplied the default will be used">
		<cfset var key = createHash(arguments.params)>
		<cfset var qSaveToCache = "">
		
		<cfif arguments.cachefor EQ 0>
			<cfreturn />
		</cfif>

		<cfquery name="qSaveToCache" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		REPLACE INTO `#variables.table#` (`id`, `date`, `data`)
		VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#key#">, 
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateadd('s', arguments.timeout, now())#">,
				<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#data#">)
		</cfquery>
	</cffunction>

	<cffunction name="purgeCache" access="public" output="false" returntype="void">
		<cfquery name="qPurgeCache" datasource="#variables.dsn#" username="#variables.username#" password="#variables.password#">
		DELETE FROM `#variables.table#` 
		WHERE `date` < #createodbcdatetime(now())#
		</cfquery>
	</cffunction>	
	
</cfcomponent>