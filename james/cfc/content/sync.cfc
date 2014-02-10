<!--- 

	handle sync tasks with other sources

 --->

<cfcomponent output="false">
	
	<cfinclude template="/common/scripts.cfm" />

	<cffunction access="public" name="init" output="false" returntype="any">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="forceSyncNow" output="false" returntype="struct"
			hint="Force a sync process now. Perform this by setting lastupdate to NULL so that the sync routine will catch up">
		<cfargument name="stContext" type="struct" />
		<cfargument name="sServicename" type="string" required="true" />
		<cfargument name="bResetSyncinfo" type="boolean" default="false" required="false"
			hint="Reset the stored sync information as well?" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qUpdate" datasource="mytunesbutlercontent">
		UPDATE	sourcessyncstate
		SET		dt_lastupdate = NULL
		
				<!--- e.g. dropbox: scan entire tree no matter if there have been any updates --->
				<cfif arguments.bResetSyncinfo>
					,syncinfo = ''
				</cfif>
				
		WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
				AND
				servicename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sServiceName#" />
		</cfquery>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="storeSyncInfo" output="false" returntype="struct"
			hint="Store the provided sync information">
		<cfargument name="stContext" type="struct" />
		<cfargument name="sServicename" type="string" required="true" />
		<!--- todo: query for certain services / source ids
			
			this is necessary in order to make sources unique, image
			three harddisks connected to the service
			!!!
			
		 --->
		 <cfargument name="stSyncInfo" type="struct" required="true"
			hint="The information to store" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.oInfo = entityLoad( 'sourcessyncstate', { user_ID = arguments.stContext.userid, servicename = arguments.sServiceName }, true ) />
		
		<!--- a new item? --->
		<cfif IsNull( local.oInfo )>
			<cfset local.oInfo = entityNew( 'sourcessyncstate' ) />
			
			<cfset local.oInfo.setUser_ID( arguments.stContext.userid ) />
			<cfset local.oInfo.setservicename( arguments.sServicename ) />			
			<cfset local.oInfo.setdt_created( Now() ) />
		</cfif>
		
		<cfset local.oInfo.setSyncInfo( SerializeJSON( arguments.stSyncInfo )) />
		<cfset local.oinfo.setdt_lastupdate( Now() ) />
		
		<cfset entitySave( local.oInfo ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="getAllSyncSources" output="false" returntype="struct"
			hint="Return all sync sources of an user">
		<cfargument name="stContext" type="struct" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfquery name="local.qSyncSources" datasource="mytunesbutlercontent">
		SELECT	service_ID,servicename,dt_created,dt_lastupdate,source_ID,status
		FROM	sourcessyncstate
		WHERE	user_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.stContext.userid#" />
		</cfquery>
		
		<cfset stReturn.qSyncSources = local.qSyncSources />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="getSyncInfo" output="false" returntype="struct"
			hint="Return information about the sync state of a certain service or device">
		<cfargument name="stContext" type="struct" />
		<cfargument name="sServicename" type="string" required="true" />
		<!--- todo: query for certain services / source ids
			
			this is necessary in order to make sources unique, image
			three harddisks connected to the service
			!!!
			
		 --->
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<!--- unique! --->
		<cfset local.oInfo = entityLoad( 'sourcessyncstate', { user_ID = arguments.stContext.userid, servicename = arguments.sServiceName }, true ) />
		
		<cfif IsNull( local.oInfo )>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 404, 'No information available for the given source' ) />
		</cfif>
		
		<!--- deserialize information --->
		<cfset stReturn.stInfo = {} />
		
		<!--- but only in case we have a valid JSON string --->
		<cfif IsJSON( local.oInfo.getsyncinfo() )>
			<cfset stReturn.stInfo = deserializejson( local.oInfo.getsyncinfo() ) />
		</cfif>
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>


</cfcomponent>