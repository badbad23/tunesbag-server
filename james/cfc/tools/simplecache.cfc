<!--- 

	a simple caching routine ... the cache is stored
	in the variables scope of the component and consists
	of simple key / value / timeout contructions
	
	the cache is automatically flushed if the component is re-created
	
	by hpo
	
--->


<cfcomponent output="false" hint="component responsible for caching">

	<!--- structure holding the cached data --->
	<cfset variables.stCache = {} />
	<cfset variables.sEngine = 'component' />
	<cfset variables.sCacheName = 'cache' />
	
	<cffunction access="public" name="init" returntype="any" hint="constructor">
		<cfargument name="sEngine" type="string" required="false" default="component"
			hint="component, ehcache" />
		<cfargument name="sCacheName" type="string" required="false" default="cache"
			hint="name of the cache" />
			
		<!--- FIX: use component only at the moment --->
		<!--- <cfset arguments.sEngine = 'component' /> --->
			
		<cfset variables.sEngine = arguments.sEngine />	
		<cfset variables.sCacheName = arguments.sCacheName />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="getEngine" returntype="string" output="false"
			hint="return the engine used">
		<cfreturn variables.sEngine />
	</cffunction>
	
	<cffunction access="private" name="getCacheName" returntype="string" output="false"
			hint="return the cache name">
		<cfreturn variables.sCacheName />
	</cffunction>
	
	<cffunction access="public" name="GetCacheStruct" returntype="struct"
			hint="return the structure holding the cached elements">
		<cfreturn variables.stCache />
	</cffunction>
	
	<cffunction access="public" name="GetCachedResult" returntype="struct"
			hint="cache if a cached version exists">
		<cfargument name="sIdentifier" type="string" required="true"
			hint="Cache Identifier" />
		
		<cfset var stReturn = { bResult = false, sRequestedIdentifier = arguments.sIdentifier } />
		<cfset var local = {} />
		
		<cfswitch expression="#getEngine()#">
			<cfcase value="ehcache">
				<cftry>
				<cfset local.oCache = cacheGet( arguments.sIdentifier, getCacheName()) />
				
				<!--- no exception, item exists! --->
				
				<cfset stReturn.oItem = local.oCache />
				
				<cfset stReturn.bResult = true />
				
				<cfcatch type="any">
					<!--- does not exist --->
				</cfcatch>
				</cftry>
			</cfcase>
			<cfdefaultcase>
				
				<cfif StructKeyExists( GetCacheStruct(), arguments.sIdentifier )>
					
					<!--- check if the cache item is too old ...
						
						compare the minutes since this item has been created and if bigger than maxage, kick the item from cache
						
						LTE is necessary to be compatible with 0 timeouts (item will never time out)
						
						--->
					<cfif Abs( DateDiff( 'n', GetCacheStruct()[ arguments.sIdentifier ].dCreated, Now() )) LTE GetCacheStruct()[ arguments.sIdentifier ].iMaxAgeMinutes>
						
						<cfset stReturn[ 'oItem' ] = GetCacheStruct()[ arguments.sIdentifier ].oItem />
						<cfset stReturn.bResult = true />
					
					<cfelse>
						<!--- remove item from cache --->
						<cfset StructDelete( GetCacheStruct(), arguments.sIdentifier ) />
						
					</cfif>
				</cfif>
			
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn stReturn />
	
	</cffunction>
	
	<cffunction access="public" name="removeItemFromCache" returntype="void" output="false"
			hint="delete a certain item from the cache if it exists">
		<cfargument name="sIdentifier" type="string" required="true"
			hint="Cache Identifier" />
			
		<cfif StructKeyExists( GetCacheStruct(), arguments.sIdentifier )>
			<cfset StructDelete( GetCacheStruct(), arguments.sIdentifier ) />
		</cfif>

	</cffunction>
	
	<cffunction access="public" name="AddItemToCache" returntype="void"
			hint="store object in the cache">
		<cfargument name="sIdentifier" type="string" required="true"
			hint="the unique key for this item" />
		<cfargument name="oItem" type="any" required="true"
			hint="stuff to cache" />
		<cfargument name="iMaxAgeMinutes" type="numeric" default="0"
			hint="how long should we cache this item?">
		
		<cfswitch expression="#getEngine()#">
			<cfcase value="ehcache">
				<!--- cachePut(string id,object value,[timespan timeSpan[,timespan idleTime[,string cacheName]]]) --->
				
				<cfif arguments.iMaxAgeMinutes IS 0>
					<!--- use the default life time --->
					<cfset cachePut( arguments.sIdentifier, arguments.oItem ) />
				<cfelse>
					<cfset cachePut( arguments.sIdentifier, arguments.oItem, CreateTimeSpan( 0, 0, arguments.iMaxAgeMinutes, 0 ) ) />
				</cfif>
				
			</cfcase>
			<cfdefaultcase>
		
				<!--- add item to cache with identifier when it has been created --->
				<cfset GetCacheStruct()[ arguments.sidentifier ] = { oItem = arguments.oItem,
															 dCreated = Now(),
															 iMaxAgeMinutes = arguments.iMaxAgeMinutes } />
															 
			</cfdefaultcase>
		</cfswitch>
		
	</cffunction>
	
	<cffunction access="public" name="FlushCache" returntype="void"
			hint="clear the cache completly">
				
		<cfset StructClear( GetCacheStruct() ) />
	
	</cffunction>

</cfcomponent>