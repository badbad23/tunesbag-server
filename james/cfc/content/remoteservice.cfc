<!---

	Remote uploading / streaming service

--->

<cfcomponent displayName="remote" hint="parse lib, dup check, hash check etc" output="false">
	
	<cfinclude template="/common/scripts.cfm">
	
	<cffunction access="public" name="init" returntype="james.cfc.content.remoteservice" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction access="public" name="ReturnStorageInformationToClient" output="false" returntype="struct"
			hint="tell the client where to store the given file">
		<cfargument name="userkey" type="string" required="true" />
		<cfargument name="hashvalue" type="string" required="true" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var oS3 = application.beanFactory.getBean( 'StorageComponent' ).getS3Connector() />
		<cfset var sRemotePath = application.udf.GenerateS3PathInformation( arguments.hashvalue ) />
		<cfset var stS3Info = {} />
		
		<cfif Len( arguments.hashvalue ) IS 0>
			<cfthrow message="Invalid hashvalue" />
		</cfif>
		
		<cfset stS3Info = oS3.GenerateUploadInformation( bucketName = application.udf.GetSettingsProperty( 'AWSbucketname' , '' ),
						remotepath = sRemotePath,
						remotefilename = arguments.hashvalue,
						contentType = 'audio' ) />
						
		<cfset StructAppend( stReturn, stS3Info ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
	<cffunction access="public" name="PerformRemoteIncomingRequestCheck" output="false" returntype="struct"
			hint="check if upload is OK">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="runkey" type="string" required="true">
		<cfargument name="authkey" type="string" required="true">		
		<cfargument name="librarykey" type="string" required="true">
		<cfargument name="ip" type="string" required="true">
		<cfargument name="originalFileHashValue" type="string" required="true"
			hint="the hash value of the uploaded file" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var stQuota = 0 />
		<cfset var stValidAuthKey = 0 />
		<!--- user exists? --->
		<cfset var bUserExists = application.beanFactory.getBean( 'UserComponent' ).UserkeyExists( arguments.userkey ) />
		
		<cfif NOT bUserExists>			
			<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1005, 'User does not exist') />
		</cfif>
		
		<!--- valid request (authkey etc) --->
		<cfset stValidAuthKey = application.beanFactory.getBean( 'UploadComponent' ).CheckIsValidAuthkey( ip = arguments.ip,
									runkey = arguments.runkey,
									authkey = arguments.authkey ) />
									
		<cfif NOT stValidAuthKey.result>
			<cfreturn stValidAuthKey />
		</cfif>
		
		<!--- next: quota --->
		<cfset stQuota = application.beanFactory.getBean( 'StorageComponent' ).GetQuotaDataOfUser( userkey = arguments.userkey ) />
		
		<!--- over quota? --->
		<cfif NOT stQuota.result>
			<cfreturn stQuota />
		</cfif>
		
		<cfset stReturn.stQuota = stQuota />
		
		<!--- check if the file already exists ... --->
		
		<!--- check if this item already exists in the DB .. do NOT re-add --->
		<cfif application.beanFactory.getBean( 'MediaItemsComponent').CheckOriginalHashValueExists( userkey = arguments.userkey, originalhashvalue = arguments.originalFileHashValue)>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4005, 'File with same hashvalue already exists' ) />
		</cfif>

		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	

	<cffunction access="public" name="CheckSubmittedHashData" returntype="struct" output="false"
			hint="analyze the hash values and say yes or no if the file already exists">
		<cfargument name="userkey" type="string" required="true">
		<cfargument name="filename" type="string" required="true">
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		<cfset var a_cmp_parse = application.beanFactory.getBean( 'RemoteServiceLibraryParser' ) />
		
		<!--- incoming filename ... --->
		<cfset var a_str_filename = application.udf.GetTBTempDirectory() & '/lib_hash_' & CreateUUID() & '.incoming.xml' />
		<cfset var a_struct_result_parse = 0 />
		<cfset var q_select_hash_data = 0 />
		
		<cffile action="copy" source="#arguments.filename#" destination="#a_str_filename#">
		
		<!--- perform a SAX based parsing of this (maybe huge .XML) --->
		<cfset a_struct_result_parse = a_cmp_parse.ParseHashValueData( filename = a_str_filename, userkey = arguments.userkey ) />
		
		<cfif NOT a_struct_result_parse.result>
			<cfreturn a_struct_result_parse />
		</cfif>
		
		<!--- get parsed data --->
		<cfset q_select_hash_data = a_struct_result_parse.q_select_hash_data />
		
		<!--- check against existing mediaitems now ... --->
		<cfset q_select_hash_data = UploadApplicationCheckHashValuesOfUserLibrary(userkey = arguments.userkey,
				query = q_select_hash_data) />
			
		<cfset stReturn.items = q_select_hash_data />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
	</cffunction>
	
	<!--- internal routine to check if a hash value is known in the system --->
	<cffunction access="private" name="UploadApplicationCheckHashValuesOfUserLibrary" output="false" returntype="query"
		hint="return the list of known hash values (set the statuscode to 200 if the user already has the track, set 204 is the file is available but the user does not have it)">
	<cfargument name="userkey" type="string" required="true"
		hint="entrykey of user">	
	<cfargument name="query" type="query" required="true"
		hint="holding data to check against">
		
		<cfset var a_str_entrykey = CreateUUID() />
		<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
		<cfset var q_select_result_all_hash_values = 0 />
		<cfset var q_select_result_user_hash_values = 0 />		
		<!--- select all available hashvalues (where the hashvalue is one of the uploaded ones) --->
		<cfset var a_str_basic_sql = 'SELECT mediaitem.hashvalue FROM mediaitems.mediaitem AS mediaitem WHERE mediaitem.hashvalue IN (:hashvalue)' />
		<cfset var a_str_basic_sql_own_files = 'SELECT mediaitem.hashvalue FROM mediaitems.mediaitem AS mediaitem WHERE mediaitem.hashvalue IN (:hashvalue) AND mediaitem.userkey = :userkey' />
		<cfset var a_tsql_query = 0 />
		<cfset var a_tsql_query_own = 0 />
		<cfset var q_select_own_files = 0 />
		<cfset var a_str_available_list_all_values = '' />
		<cfset var a_str_available_list_user_values = '' />
		<cfset var q_select_result = 0 />
		
		<!--- Select ALL hash values ... --->
		<cfset a_tsql_query = oTransfer.createQuery( a_str_basic_sql ) />
		<cfset a_tsql_query.setParam( 'hashvalue', ValueList( arguments.query.hashvalue ), 'string', true ) />
		<cfset q_select_result_all_hash_values = oTransfer.listByQuery( a_tsql_query ) />
		
		<!--- Select hashvalues of USER only --->
		<cfset a_tsql_query_own = oTransfer.createQuery( a_str_basic_sql_own_files ) />
		<cfset a_tsql_query_own.setParam( 'hashvalue', ValueList( arguments.query.hashvalue ), 'string', true ) />
		<cfset a_tsql_query_own.setParam( 'userkey', arguments.userkey, 'string' ) />
		<cfset q_select_result_user_hash_values = oTransfer.listByQuery( a_tsql_query_own ) />
			
		<!--- if no query has been provided, return now ... --->
		<cfset a_str_available_list_all_values = ValueList( q_select_result_all_hash_values.hashvalue ) />
		<cfset a_str_available_list_user_values = ValueList( q_select_result_user_hash_values.hashvalue ) />
		
		<!--- check the new query against the old one ... --->
		<cfloop query="arguments.query">

			<!--- if we have a hit, set to found ... track itself will not have to be transmitted again ...
					of course we will need the meta data nevertheless --->
					
			<!--- MODIFICATION : RIGHT NOW, RETURN JUST 200 AND 404 ... NO 204 RESPONSE --->
					
			<!--- <cfif ListFindNoCase( a_str_available_list_all_values, arguments.query.hashvalue ) GT 0>
				<cfset QuerySetCell( arguments.query, 'statuscode', 204, arguments.query.currentrow ) />
			</cfif> --->
			
			<!--- does the user already have the track and the meta data? in this case, do NOT send the meta data either, 
					just tell the user the file has been added --->
			<cfif ListFindNoCase( a_str_available_list_user_values, arguments.query.hashvalue ) GT 0>
				<cfset QuerySetCell( arguments.query, 'statuscode', 200, arguments.query.currentrow ) />
			</cfif>		
				
		
		</cfloop>
		
		<cfset q_select_result = arguments.query />
		
		<cfreturn q_select_result />
</cffunction>
	
	<!--- remote controller --->
	<cffunction access="public" name="sendRemoteControlCommand" output="false" returntype="struct">
		<cfargument name="stContext" type="struct" />
		<cfargument name="sAction" type="string"
			hint="Action to send to client" />
		<cfargument name="stParams" type="struct"
			hint="Params to send to client" />
		
		<cfset var stReturn = application.udf.GenerateReturnStruct() />
		
		<cfset local.stCommand = {
			action	= arguments.sAction,
			params	= arguments.stParams
			} />
		
		<cfset local.stData = { message = SerializeJSON( stCommand ), username = arguments.stContext.username } />
		
		<!--- send gw message --->
		<cfset stReturn.stSend = SendGatewayMessage( application.const.S_GATEWAY_REMOTECONTROL, stData ) />
		
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
		
	</cffunction>
	
</cfcomponent>