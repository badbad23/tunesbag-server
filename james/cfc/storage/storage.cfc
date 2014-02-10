<!--- //

	Module:		Handle storage issues
	Action:		
	Description:	
	
// --->

<cfcomponent name="upload" displayname="upload component"output="false" hint="upload handler">

<cfinclude template="/common/scripts.cfm">

<cfsetting requesttimeout="200">

<cffunction name="init" access="public" output="false" returntype="james.cfc.storage.storage"> 
	
	<cfset variables.aBucketName = application.udf.GetSettingsProperty( 'AWSbucketname' , '' ) />
	
	<cfreturn this />
</cffunction>

<cffunction access="public" name="CreateDownloadTicketForFile" output="false" returntype="struct"
		hint="create a DL ticket for a given file">
	<cfargument name="delivery_information" type="struct" required="true"
		hint="the delivery information with filename,contenttype etc">
		
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.new( 'api.downloadtickets' ) />
	
	<cfset a_item.setentrykey( a_str_entrykey ) />
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setip( cgi.REMOTE_ADDR ) />
	<cfset a_item.setcontenttype( arguments.delivery_information.contenttype ) />
	<cfset a_item.setfilename( arguments.delivery_information.location ) />
	
	<cfset oTransfer.save( a_item ) />
	
	<cfset stReturn.entrykey = a_str_entrykey />
	<cfset stReturn.url = 'http://' & cgi.SERVER_NAME & ':' & cgi.SERVER_PORT & '/james/?event=public.deliver.ticket&entrykey=' & a_str_entrykey />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="SetMaxSizeQUotaOfUser" output="false" returntype="void"
		hint="adapt the user quota">
	<cfargument name="userkey" type="string" required="true">
	<cfargument name="iQuota" type="numeric" required="true"
		hint="quota in bytes" />
		
	<cfset var oCheck = GetQuotaDataOfUser( arguments.userkey ) />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var oItem = oTransfer.get( 'users.quota', arguments.userkey ) />
	
	<cfset oItem.setmaxsize( arguments.iQuota ) />
	
	<cfset oTransfer.update( oItem ) />

</cffunction>

<cffunction access="public" name="GetQuotaDataOfUser" output="false" returntype="struct"
		hint="return the current size + total size">
	<cfargument name="userkey" type="string" required="true">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var iTotalsize = RecalcTotalsizeOfUserdata( userkey = arguments.userkey ) />
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var oItem = oTransfer.get( 'users.quota', arguments.userkey ) />
	
	<cfset stReturn.maxsize = oItem.getmaxsize() />
	<cfset stReturn.currentSize = oItem.getCurrentsize() />
	<cfset stReturn.maxfilesize = oItem.getMaxfileSize() />
	
	<cfif Val( stReturn.maxsize ) IS 0>
		<!--- default quota --->
		<cfset stReturn.maxsize = application.udf.GetSettingsProperty( 'DefaultQuota' , '1073741824' ) />
	</cfif>
	
	<cfif Val( stReturn.maxfilesize ) IS 0>
		<!--- default filesize to 12 MB --->
		<cfset stReturn.maxfilesize = application.udf.GetSettingsProperty( 'DefaultMaxFileSize' , '12582912' ) />
	</cfif>
	
	<!--- perform the check --->
	<cfif stReturn.currentSize GTE stReturn.maxsize>
		<!--- over quota --->
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 4100) />
	<cfelse>
		<!--- we're done --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="RecalcTotalsizeOfUserdata" output="false" returntype="numeric"
		hint="re-calculate the size of the data of the user and return the number">
	<cfargument name="userkey" type="string" required="true">
	
	<cfset var oTransfer = application.beanFactory.getBean( 'UsersTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'users.quota', arguments.userkey ) />
	<cfset var q_select_total_size = 0 />
	<cfset var local = {} />
	
	<cfinclude template="queries/q_select_total_size.cfm">
	
	<cfset a_item.setUserkey( arguments.userkey ) />
	<cfset a_item.setCurrentSize( Val( q_select_total_size.totalsize )) />
	
	<cfif NOT a_item.getIsPersisted()>
		<cfset a_item.setMaxSize( application.udf.GetSettingsProperty( 'DefaultQuota' , '3221225472' )  ) />
	</cfif>
	
	<cfset oTransfer.save( a_item ) />
	
	<cfreturn Val( q_select_total_size.totalsize ) />

</cffunction>

<cffunction access="public" name="getS3Connector" returntype="Any"
		hint="return the S3 component with the correct access credentials">
			
	<cfset var accessKey = application.AWSAccessKeyId />
	
	<cfif !Len( accessKey )>
		<cfthrow message="getS3Connector call failed with empty Access key" />
	</cfif>
			
	<cfreturn application.beanFactory.getBean( 'AWSS3' ).init( accessKeyId = accessKey,
												   secretAccessKey = application.AWSsecretAccessKey  ) />
												   
</cffunction>

<cffunction access="public" name="saveStorageMetaInfo" output="false" returntype="struct"
		hint="save meta info about storage">
	<cfargument name="userkey" type="string" required="true" />
	<cfargument name="mediaitemkey" type="string" required="true" />
	<cfargument name="hashvalue" type="string"
		hint="hashvalue of the file" />
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<!--- info item --->
	<cfset var oInfo = oTransfer.new( 'storage.storageinformation' ) />
	<cfset var stLocal = {} />
	
	<!--- does a file with this hash value *generally* exist in the system? --->
	<cfset var bHashvalueExists = FileWithSameHashValueAlreadyExists(hashvalue = arguments.hashvalue) />
	
	<!--- calculate S3 path --->
	<cfset stLocal.sS3Path = application.udf.GenerateS3PathInformation( arguments.hashvalue ) />
	
	<!--- insert common information --->	
	<cfset oInfo.setHashValue( arguments.hashvalue ) />	
	<cfset oInfo.setUserkey( arguments.userkey ) />	
	<cfset oInfo.setMediaItemkey( arguments.mediaitemkey ) />							
	<cfset oInfo.setdt_created( Now() ) />
	<cfset oInfo.sets3_bucketname( application.udf.GetSettingsProperty( 'AWSbucketname' , '' ) ) />
	<cfset oInfo.sets3_path( stLocal.sS3Path )/>
	<cfset oInfo.sets3_filename( arguments.hashvalue )/>
		
	<!--- save the information --->
	<cftry>
	<cfset oTransfer.save(oInfo) />
		<cfcatch type="any">
			<!--- maybe duplicate error? --->
		</cfcatch>
	</cftry>
	
	<!--- update / insert counter --->
	<cflock type="exclusive" timeout="30" name="lck_#arguments.hashvalue#">
		<cfinclude template="queries/q_set_update_storage_counter.cfm">
	</cflock>	
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="FileWithSameHashValueAlreadyExists" output="false" returntype="boolean"
		hint="Check if a file with the very same hash value already is stored in the storage ... this way we only have to add a reference">
	<cfargument name="hashvalue" type="string" required="true">
	<cfargument name="userkey" type="string" default="" required="false"
		hint="check the userkey as well?">

	<cfset var q_select_count = 0 />
	
	<cfquery name="q_select_count" datasource="mytunesbutleruserdata">
	SELECT
		COUNT(id) AS counter
	FROM
		storageinformation
	WHERE
		(hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">)
		
		<cfif Len(arguments.userkey) GT 0>
			AND
			(userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">)
		</cfif>
		
	;
	</cfquery>
		
	<cfreturn (Val(q_select_count.counter) GT 0) />

</cffunction>

<cffunction access="public" name="GenerateFullS3PathInformation" output="false" returntype="string"
		hint="return the full path including the filename">
	<cfargument name="hashvalue" type="string" required="true">	
	
	<cfreturn application.udf.GenerateS3PathInformation(arguments.hashvalue) & '/' & ReplaceNoCase(arguments.hashvalue, 'hash_', '') />

</cffunction>

<cffunction access="public" name="GetHTTPS3LinkToObject" output="false" returntype="string"
		hint="return the full link to the file stored on S3 (tmp download)">
	<cfargument name="hashvalue" type="string" required="true"
		hint="hash value of the file">
		
	<cfset var a_cmp_s3 = getS3Connector() />
	<cfset var a_str_filelink = GenerateFullS3PathInformation(arguments.hashvalue) />
	<cfset var a_str_timedLink = a_cmp_s3.getObject( application.udf.GetSettingsProperty( 'AWSbucketname' , '' ), a_str_filelink ) />
	
	<cfreturn a_str_timedLink />

</cffunction>

<cffunction access="public" name="DeleteStorageItem" output="false" returntype="struct"
		hint="Check if we should delete only the reference or the file itself as well">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="hashvalue" type="string" required="true"
		hint="hash value of item">
	<cfargument name="mediaitemkey" type="string" required="true"
		hint="entrykey of media item">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<!--- get number of items with this hash value --->
	<cfset var a_counter_item = oTransfer.get( 'storage.storagecounters', arguments.hashvalue ) />
	<cfset var a_int_count = Val( a_counter_item.getCounter() ) />	
	<!--- get storage info item to delete --->
	<cfset var a_map_q = { userkey = arguments.securitycontext.entrykey,
						   hashvalue = arguments.hashvalue } />
	<cfset var a_info_item = oTransfer.readByPropertyMap( 'storage.storageinformation', a_map_q ) />
	<cfset var a_str_path_to_file = '' />
	
	<!--- item does not exist --->
	<cfif NOT a_counter_item.getIsPersisted()>
		
		<!--- <cfset stReturn.args = arguments />
		<cfset stReturn.error_read = 'storage counter item does not exist' />
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1001 ) /> --->
		
		<!--- ignore this error and return --->
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cfif>
	
	<cfif a_int_count IS 1>
		
		<!--- delete from S3 --->
		<cfset a_str_path_to_file = GenerateFullS3PathInformation( arguments.hashvalue ) />
		
		<cfset stReturn.a_str_path_to_file = a_str_path_to_file />
		
		<!--- call delete --->
		<cfset stReturn.a_bol_delete = getS3Connector().deleteObject( bucketName = application.udf.GetSettingsProperty( 'AWSbucketname' , '' ),
							fileKey = a_str_path_to_file) />
							
							
		<cflog application="false" text="s3 delete: #a_str_path_to_file#" type="information" file="s3_cleanup" />
		
	</cfif>
	
	<!--- update counter ... reduce by 1 --->
	<cfif a_counter_item.getIsPersisted()>
		
		<cfif a_int_count GT 1>
			
			<!--- subtract one --->
			<cfset a_counter_item.setCounter( a_counter_item.getCounter() -1 ) />
			<cfset oTransfer.update( a_counter_item ) />
			
		<cfelse>
		
			<!--- delete record alltogether --->
			<cfset oTransfer.delete( a_counter_item ) />
		
		</cfif>
		
	</cfif>
	
	<!--- delete info item --->
	<cfif a_info_item.getIsPersisted()>
		<cfset oTransfer.delete( a_info_item ) />
	</cfif>
	
	<cfset stReturn.counter = a_int_count />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

</cfcomponent>