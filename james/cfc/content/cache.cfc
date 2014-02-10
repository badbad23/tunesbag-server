<!--- //

	Module:		Cache component
	Action:		
	Description:	
	
// --->

<cfcomponent displayName="Cache" hint="do caching" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.cache" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="CheckAppCacheStore" output="false" returntype="void">
		<cfif NOT StructKeyExists( application, 'cache' )>
			<cfset application.cache = {} />
		</cfif>		
	</cffunction>
	
	<cffunction access="public" name="CheckAndGetStoredElement" output="false" returntype="struct"
			hint="check and return a stored cache item">
		<cfargument name="hashvalue" type="string" required="true" />
		<cfargument name="store" type="string" default="ehcache" required="false"
			hint="db or app" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var q_select_cache_item_data = 0 />
		<cfset var local = {} />
		
		<!--- database --->
		<cfif arguments.store IS 'db'>
		
			<cfinclude template="queries/cache/q_select_cache_item_data.cfm">
			
			<!--- item not found --->
			<cfif q_select_cache_item_data.recordcount IS 0>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfif>
	
			<!--- return the data --->
			<cftry>
			<cfwddx action="wddx2cfml" input="#q_select_cache_item_data.data#" output="stReturn.data">
			<cfcatch>
				<!--- error = item not found --->
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfcatch>
			</cftry>
			
			<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
			
		<cfelseif arguments.store IS 'ehcache'>
		
			<cftry>
			<cfset local.stCache = application.beanFactory.getBean( 'SimpleEHCache' ).GetCachedResult( sIdentifier = arguments.hashvalue ) />
				<cfcatch type="any">
					<!--- something happend ... --->
					<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
				</cfcatch>
			</cftry>
			
			<cfif local.stCache.bResult>
				
				<cfset stReturn.data = local.stCache.oItem />
				<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />
		
			<cfelse>
				<!--- use the simple cache routine --->
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			</cfif>
		
		<cfelse>
			
			<!--- app store --->
			<cfset CheckAppCacheStore() />
			
			<cfif NOT StructKeyExists( application.cache, arguments.hashvalue )>
				<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 999) />
			<cfelse>
				<cfreturn application.cache[ arguments.hashvalue ].data />
			</cfif>
			
			
		</cfif>

	</cffunction>
	
	<cffunction access="public" name="StoreCacheElement" output="false" returntype="struct"
			hint="store a cache element">
		<cfargument name="hashvalue" type="string" required="true">
		<cfargument name="description" type="string" required="true"
			hint="human readable description for a better identification">
		<cfargument name="system" type="string" required="false" default=""
			hint="a system name to store">
		<cfargument name="data" type="Any" required="true"
			hint="data to store">
		<cfargument name="expiresmin" type="numeric" default="9600" required="false"
			hint="timeout for this cache">
		<cfargument name="store" type="string" default="ehcache" required="false"
			hint="used store ... db or app" />
			
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oTransfer = 0 />
		<cfset var a_item = 0 />
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var a_str_data = '' />
		
		<cfif arguments.store IS 'db'>
			
			<cfset oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
			<cfset a_item = oTransfer.readByProperty( 'cache.infocache' , 'hashvalue' , arguments.hashvalue ) />
		
			<cfwddx action="cfml2wddx" input="#arguments.data#" output="a_str_data">
			
			<cfset a_item.setdt_created( Now() ) />
			<cfset a_item.setData( a_str_data ) />
			<cfset a_item.sethostsystem( arguments.system ) />
			<cfset a_item.setdescription( arguments.description ) />
			<cfset a_item.setHashValue( arguments.hashvalue ) />
			<cfset a_item.setEntrykey( a_str_entrykey ) />
			<cfset a_item.setexpiresmin( arguments.expiresmin ) />
		
			<cftry>
			<cfset oTransfer.Save( a_item ) />
			<cfcatch type="any">
				<!--- ignore any exception for now ... --->
			</cfcatch>
			</cftry>
			
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
		<cfelseif arguments.store IS 'ehcache'>
			
			<cfset application.beanFactory.getBean( 'SimpleEHCache' ).AddItemToCache( sIdentifier = arguments.hashvalue,
						oItem = arguments.data,
						iMaxAgeMinutes = arguments.expiresmin ) />
						
			<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
			
		<cfelse>
			
			<!--- app store --->
			<cfset CheckAppCacheStore() />
		
		</cfif>
		
	</cffunction>

</cfcomponent>