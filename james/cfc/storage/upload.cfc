<!--- //

	Module:		Handle file stuff of uploading
	
// --->

<cfcomponent name="upload" displayname="upload component"output="false" hint="upload handler">

<cfprocessingdirective pageencoding="utf-8">
<cfinclude template="/common/scripts.cfm">

<cffunction name="init" access="public" output="false" returntype="james.cfc.storage.upload"> 
	<cfreturn this />
</cffunction>

<cffunction access="public" name="CheckIsValidAuthkey" returntype="struct" output="false" hint="check if an auth key is valid">
	<cfargument name="authkey" type="string" required="true">
	<cfargument name="runkey" type="string" required="true">
	<cfargument name="ip" type="string" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<!--- ignore the IP for now ... ip = arguments.ip --->
	<cfset var a_map = { authkey = arguments.authkey, runkey = arguments.runkey } />
	<cfset var q_select_valid = oTransfer.listByPropertyMap( 'api.uploadauthkeys', a_map ) />

	<!--- valid request? --->
	<cfif q_select_valid.recordcount IS 0>
		<cfset stReturn.args = arguments />
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1001) />
	<cfelse>
		<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	</cfif>
	
</cffunction>

<cffunction access="public" name="IssueUploadAuthkey" returntype="struct" output="false" hint="issue a new upload key">
	<cfargument name="securitycontext" type="struct" required="true">
	<cfargument name="ip" type="string" required="true">
	<cfargument name="runkey" type="string" required="true"
		hint="a self defined identification of this upload run">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'LogTransfer' ).getTransfer() />
	<cfset var a_authkey = CreateUUID() />
	<cfset var a_item = oTransfer.new( 'api.uploadauthkeys' ) />
	
	<cfset a_item.setdt_created( Now() ) />
	<cfset a_item.setuserkey( arguments.securitycontext.entrykey ) />
	<cfset a_item.setrunkey( arguments.runkey ) />
	<cfset a_item.setip( arguments.ip ) />
	<cfset a_item.setauthkey( a_authkey ) />
	<cfset oTransfer.create( a_item ) />
	
	<!--- return the auth key --->
	<cfset stReturn.authkey = a_authkey />
	<cfset stReturn.runkey = arguments.runkey />
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<cffunction access="public" name="getProcessingQueueSizeForUser" output="false" returntype="numeric"
		hint="return the number of items waiting to be processed">
	<cfargument name="userkey" type="string" required="true">
	
	<cfset var q_select_processing_queue_items_count_user = 0 />
	<cfinclude template="queries/q_select_processing_queue_items_count_user.cfm">

	<cfreturn Val( q_select_processing_queue_items_count_user.count_items ) />

</cffunction>

<cffunction access="public" name="GetProcessingQueue" output="false" returntype="struct"
		hint="Get the uploading queue of a certain user">
	<cfargument name="securitycontext" type="struct" required="true">
	
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var q_select_items = oTransfer.listByProperty( 'storage.uploaded_items_status', 'userkey', arguments.securitycontext.entrykey ) />
	
	<cfset stReturn.q_select_items = q_select_items />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction>

<cffunction access="public" name="DoHttpUpload" returntype="struct" output="false"
		hint="Get an external http file">
	<cfargument name="url" type="string" required="true">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_location = application.udf.GetTBTempDirectory() & CreateUUID() & '.mp3' />
	<cfset var cfhttp = 0 />
	
	<cftry>
	
			<cfhttp method="get" url="#arguments.url#" timeout="80" redirect="false" getasbinary="yes"></cfhttp>
			
			<!--- not 200, no audio --->
			<cfif (cfhttp.ResponseHeader.Status_code NEQ 200) OR (cfhttp.MimeType NEQ 'audio/mpeg')>

				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4001 ) />
			</cfif>
			
		<cfcatch type="any">
			
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4001 ) />
			
		</cfcatch>
	</cftry>

	<cffile action="write" output="#cfhttp.FileContent#" file="#a_str_location#">
	
	<cfset stReturn.location = a_str_location />

	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
</cffunction>

<cffunction access="public" name="CheckPointToURLData" output="false" returntype="struct"
		hint="check a http location if the file is OK">
	<cfargument name="location" type="string" required="true"
		hint="location to URL">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_url = Trim( arguments.location ) />
	<cfset var cfhttp = 0 />
	<cfset var a_bol_error = true />
		
	<cfif FindNoCase( 'http://', a_str_url ) IS 0>
		<cfset a_str_url = 'http://' & a_str_url />
	</cfif>
		
	<cftry>

		<cfhttp method="head" url="#a_str_url#" timeout="5" redirect="true" result="cfhttp"></cfhttp>
		
		<!--- not 200, no audio and too big --->
		<cfset a_bol_error = (cfhttp.ResponseHeader.Status_code NEQ 200) OR
							 (ListFirst(cfhttp.MimeType, '/') NEQ 'audio') OR
							 (cfhttp.ResponseHeader['Content-Length'] GT 18749312) />
							 
		<cfset stReturn.cfhttp = cfhttp />
		
	<cfcatch type="any">
		
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4001 ) />
		
	</cfcatch>
	</cftry>
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />

</cffunction>

<!--- <cffunction access="public" name="InsertNewUploadItemNotification" output="false" returntype="struct"
		hint="insert a new item in the notification table">
	<cfargument name="userkey" type="string" required="true"
		hint="the entrykey of the user">
	<cfargument name="location" type="string" required="true"
		hint="where to find the file (point to a local file or http://)">
	<cfargument name="location_metainfo" type="string" required="false" default=""
		hint="where to find the file with meta information">
	<cfargument name="source" type="string" required="false" default=""
		hint="source of this file">
	<cfargument name="uploadrunkey" type="string" required="false" default=""
		hint="runkey of this upload (optional)">
	<cfargument name="librarykey" type="string" required="false" default=""
		hint="the entrykey of the library">
	<cfargument name="autoadd2plist" type="string" required="false" default=""
		hint="automatically add to a certain plist">
	<cfargument name="priority" type="numeric" default="0" required="false"
		hint="priority of upload">
		
	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_new_item = oTransfer.new( 'storage.uploaded_items' ) />
	<cfset var a_str_entrykey = CreateUUID() />
	<cfset var a_bol_error = false />
	<cfset var a_int_filesize = 0 />	
	<cfset var a_str_url = '' />
	<cfset var a_str_original_hashvalue = '' />
	<cfset var a_cmp_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	
	<!--- check if the file exists (or if it is a valid http file ) --->
	<cfif FindNoCase( 'http://', arguments.location) IS 0 AND NOT FileExists( arguments.location )>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4000 ) />
	</cfif>
	
	<!--- is it a http file? if yes, check for certain basic criteria right now --->
	<cfif FindNoCase( 'http://', arguments.location) GT 0>
		
		<cfset a_bol_error = NOT CheckPointToURLData( arguments.location ).result />
		
		<!--- return error --->
		<cfif a_bol_error>
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4001 ) />
		</cfif>
		
	</cfif>
	
	<!--- valid file extension? --->
	<cfif ListFindNoCase( 'mp3,wma,m4a,ogg,mp4', ListLast(arguments.location, '.')) IS 0>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4101 ) />
	</cfif>
	
	<!--- get *original* hash value of the file / URL location --->
	<cfif arguments.source IS 'pointtourl'>
		<cfset a_str_original_hashvalue = Hash( arguments.location, 'SHA' ) />
	<cfelse>
		<cfset a_str_original_hashvalue = application.beanFactory.getBean( 'Tools' ).getFileHash( arguments.location ) />
	</cfif>
		
	<!--- check if this item already exists in the DB .. do NOT re-add --->
	<cfif a_cmp_mediaitems.CheckOriginalHashValueExists( userkey = arguments.userkey, originalhashvalue = a_str_original_hashvalue)>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4005 ) />
	</cfif>
	
	<!--- set DB data --->
	<cfset a_new_item.setentrykey( a_str_entrykey ) />
	<cfset a_new_item.setdt_created(Now()) />
	<cfset a_new_item.setUserkey( arguments.userkey ) />
	<cfset a_new_item.setlocation( arguments.location ) />
	<cfset a_new_item.setlocation_metainfo( arguments.location_metainfo ) />
	<cfset a_new_item.setlibrarykey( arguments.librarykey) />
	<cfset a_new_item.setSource( arguments.source ) />
	<cfset a_new_item.setuploadrunkey( arguments.uploadrunkey ) />
	<cfset a_new_item.setpriority( arguments.priority ) />
	<cfset a_new_item.setautoaddtoplaylist( arguments.autoadd2plist ) />
	<!--- the original hash value of the just uploaded file --->
	<cfset a_new_item.setoriginalhashvalue( a_str_original_hashvalue ) />
	
	<!--- save it --->
	<cfset oTransfer.save(a_new_item) />
	
	<cfset stReturn.entrykey = a_str_entrykey />
	
	<cfreturn application.udf.SetReturnStructSuccessCode(stReturn) />
	
</cffunction> --->

<!--- <cffunction access="public" name="CheckUploadedFile" output="false" returntype="struct">
	<cfargument name="entrykey" type="string" required="true"
		hint="entrykey of item in the upload queue">

	<cfset var stReturn = application.udf.GenerateReturnStruct() />
	<cfset var a_str_filename_only = '' />	
	<cfset var oTransfer = application.beanFactory.getBean( 'ContentTransfer' ).getTransfer() />
	<cfset var a_item = oTransfer.get( 'storage.uploaded_items', arguments.entrykey ) />
	<cfset var a_str_librarykey = a_item.getLibraryKey() />
	<cfset var a_str_userkey = a_item.getuserkey() />
	<cfset var a_cmp_mediaitems = application.beanFactory.getBean( 'MediaItemsComponent' ) />
	<cfset var a_str_filename_meta = '' />
	<cfset var a_bol_meta_data_exists = FileExists( a_item.getlocation_metainfo() ) />
	<cfset var a_struct_meta_infos = StructNew() />
	<cfset var a_str_meta_info_file_content = '' />
	<cfset var a_struct_result_add = 0 />
	<!--- check quota --->
	<cfset var a_struct_quota = application.beanFactory.getbean( 'StorageComponent' ).GetQuotaDataOfUser( userkey = a_item.getuserkey() ) />
	<cfset var a_bol_check_file = FileExists( a_item.getlocation() ) AND
			( application.udf.fileSize( a_item.getlocation() ) LTE 62914560 ) AND
			( application.udf.fileSize( a_item.getlocation() ) GT 0 ) />
	<cfset var a_str_format = lCase( ListLast( a_item.getlocation(), '.' )) />
	<cfset var a_struct_parse_mp3 = 0 />
	<cfset var a_struct_parse_m4a = 0 />
	<cfset var a_struct_parse_wma = 0 />
	<cfset var a_struct_parse_ogg = 0 />
	<cfset var a_str_wddx_ids3 = '' />
	<cfset var a_struct_create_convert_job = 0 />
	<!--- check if the file already exists with the original hashvalue --->
	<cfset var a_bol_file_exists = a_cmp_mediaitems.CheckOriginalHashValueExists( userkey = a_item.getUserkey(),
											originalhashvalue = a_item.getoriginalhashvalue() ) />
				
	<!--- upload item not found --->
	<cfif NOT a_item.getispersisted()>
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 1002 ) />
	</cfif>

	<!--- we handled this one! --->
	<cfset a_item.setHandled( 1 ) />
	<cfset oTransfer.save( a_item ) />	
								
	<!--- file already exists in the database --->
	<cfif a_bol_file_exists>
		<cfset oTransfer.delete( a_item ) />
		<cfreturn application.udf.SetReturnStructErrorCode(stReturn, 1002) />
	</cfif>
	
	<!--- over quota? --->
	<cfif NOT a_struct_quota.result>
		<cfset oTransfer.delete( a_item ) />		
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4100 ) />
	</cfif>
	
	<!--- run a basic check --->
	<cfif NOT a_bol_check_file>
		<cfset oTransfer.delete( a_item ) />
		<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4101 ) />
	</cfif>
		
	<!--- check the format --->
	<cfswitch expression="#a_str_format#">
	
		<cfcase value="mp3">
		
			<!--- a MP3 file ... get bitrate ... too high, so is there a need to convert? --->
			<cfset a_struct_parse_mp3 = application.beanFactory.getBean( 'MP3ID3Parser' ).ParseMP3File( filename = a_item.getlocation() ) />
						
			<cfif NOT a_struct_parse_mp3.result>
				<!--- seems to be an invalid file --->
				
				<cfset a_item.sethandleerrorcode( 4101 ) />
				<cfset oTransfer.save( a_item ) />
				
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4101 ) />
			</cfif>
			
			<!--- in case bitrate is too high, reduce, otherwise apply MP3 gain on the file --->
			<cfif a_struct_parse_mp3.metainformation.bitrate GT 320>
			
				<!--- we need to convert this one! --->
				<cfset a_struct_create_convert_job = application.beanFactory.getBean( 'AudioConverter' ).CreateConvertFileJob( operation = 1,
															userkey = a_item.getuserkey(),
															source = a_item.getlocation(),
															id3tags = a_struct_parse_mp3.metainformation ) />
				
				<!--- job creation failed --->
				<cfif NOT a_struct_create_convert_job.result>
					
					<cfset a_item.sethandleerrorcode( 4101 ) />
					<cfset oTransfer.save( a_item ) />
					
					<!--- invalid? --->
					<cfreturn a_struct_create_convert_job />
				</cfif>
				
				<!--- save the convert job ... store original ID3 tags for later use (we will apply them to the new file again) --->
				<cfwddx input="#a_struct_parse_mp3.metainformation#" output="a_str_wddx_ids3" action="cfml2wddx">
		
				<cfset a_item.setoriginalid3tags( a_str_wddx_ids3 ) />
				<cfset a_item.setconvertjobkey( a_struct_create_convert_job.jobkey ) />
				<!--- 1 = converting --->
				<cfset a_item.setstatus( 1 ) />
				<cfset oTransfer.save( a_item ) />
				
				<!--- return that we are preparing the file ... --->
				<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4200 ) />
				
			<!--- check further possible actions --->
			<cfelseif a_item.getaudionormalizedone() IS 0>
			
				<!--- apply mp3gain to file? ... TODO: lookup user preference on this one --->
				<cfset a_struct_create_convert_job = application.beanFactory.getBean( 'MP3ID3Parser' ).ApplyMP3GainOnFile( source = a_item.getlocation() ) />
				
				<cfif NOT a_struct_create_convert_job.result>
					<cfreturn a_struct_create_convert_job />
				</cfif>
				
				<!--- save the item - audio normalization has been done! --->
				<cfset a_item.setaudionormalizedone( 1 ) />
				<cfset oTransfer.save( a_item ) />
			
			</cfif>
			
			<!--- allright, continue as usal ... --->
					
		
		</cfcase>
		<cfcase value="m4a">
				
			<!--- we need to convert this file --->
				<cflog application="false" file="tb_m4a" text="next: #a_item.getlocation()#" log="Application" type="information">
								
				<!--- a M4A file ... get bitrate ... too high, so is there a need to convert? --->
				<cfset a_struct_parse_m4a = application.beanFactory.getBean( 'M4AParser' ).ParseM4aFile( filename = a_item.getlocation() ) />
				
				<!--- invalid file ... --->
				<cfif NOT a_struct_parse_m4a.result>
					<cflog application="false" file="tb_m4a" text="could not parse file: #a_item.getlocation()#" log="Application" type="information">
					<cfreturn a_struct_parse_m4a />
				</cfif>
				
				<cfset a_struct_create_convert_job = application.beanFactory.getBean( 'AudioConverter' ).CreateConvertFileJob( operation = 2,
																userkey = a_item.getuserkey(),
																source = a_item.getlocation(),
																id3tags = a_struct_parse_m4a.metainformation ) />
																
																
				<!--- job creation failed --->
				<cfif NOT a_struct_create_convert_job.result>
					
					<cfset a_item.sethandleerrorcode( 4101 ) />
					<cfset oTransfer.save( a_item ) />
					
					<!--- invalid? --->
					<cfreturn a_struct_create_convert_job />
				</cfif>
				
				<!--- save the convert job ... store original ID3 tags for later use (we will apply them to the new file again) --->
				<cfwddx input="#a_struct_parse_m4a.metainformation#" output="a_str_wddx_ids3" action="cfml2wddx">
		
				<cfset a_item.setoriginalid3tags( a_str_wddx_ids3 ) />
				<cfset a_item.setconvertjobkey( a_struct_create_convert_job.jobkey ) />
				
				<!--- 1 = converting --->
				<cfset a_item.setstatus( 1 ) />
				<cfset oTransfer.save( a_item ) />															
			
			<!--- return that we are preparing the file ... --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4200 ) />
		
		</cfcase>		
		<cfcase value="wma">
		
			<!--- file need to be converted --->
			<!--- a WMA file ... get bitrate ... too high, so is there a need to convert? --->
			<cfset a_struct_parse_wma = application.beanFactory.getBean( 'WMAParser' ).ParseWMAFile( filename = a_item.getlocation() ) />
			
			<!--- invalid file ... --->
			<cfif NOT a_struct_parse_wma.result>
				<cfreturn a_struct_parse_wma />
			</cfif>
			
			<cfset a_struct_create_convert_job = application.beanFactory.getBean( 'AudioConverter' ).CreateConvertFileJob( operation = 3,
																userkey = a_item.getuserkey(),
																source = a_item.getlocation(),
																id3tags = a_struct_parse_wma.metainformation ) />			
				
			<!--- job creation failed --->
			<cfif NOT a_struct_create_convert_job.result>
				
				<cfset a_item.sethandleerrorcode( 4101 ) />
				<cfset oTransfer.save( a_item ) />
				
				<!--- invalid? --->
				<cfreturn a_struct_create_convert_job />
			</cfif>
			
			<!--- save the convert job ... store original ID3 tags for later use (we will apply them to the new file again) --->
			<cfwddx input="#a_struct_parse_wma.metainformation#" output="a_str_wddx_ids3" action="cfml2wddx">
		
			<cfset a_item.setoriginalid3tags( a_str_wddx_ids3 ) />
			<cfset a_item.setconvertjobkey( a_struct_create_convert_job.jobkey ) />
				
			<!--- 1 = converting --->
			<cfset a_item.setstatus( 1 ) />
			<cfset oTransfer.save( a_item ) />															
			
			<!--- return that we are preparing the file ... --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4200 ) />
		
		</cfcase>	
		
		<cfcase value="ogg">
		
			<!--- ogg vorbis --->
			<!--- a WMA file ... get bitrate ... too high, so is there a need to convert? --->
			<cfset a_struct_parse_ogg = application.beanFactory.getBean( 'OGGParser' ).ParseOGGFile( filename = a_item.getlocation() ) />
			
			<!--- invalid file ... --->
			<cfif NOT a_struct_parse_ogg.result>
				<cfreturn a_struct_parse_ogg />
			</cfif>
			
			<cfset a_struct_create_convert_job = application.beanFactory.getBean( 'AudioConverter' ).CreateConvertFileJob( operation = 4,
																userkey = a_item.getuserkey(),
																source = a_item.getlocation(),
																id3tags = a_struct_parse_ogg.metainformation ) />			
				
			<!--- job creation failed --->
			<cfif NOT a_struct_create_convert_job.result>
				
				<cfset a_item.sethandleerrorcode( 4101 ) />
				<cfset oTransfer.save( a_item ) />
				
				<!--- invalid? --->
				<cfreturn a_struct_create_convert_job />
			</cfif>
			
			<!--- save the convert job ... store original ID3 tags for later use (we will apply them to the new file again) --->
			<cfwddx input="#a_struct_parse_ogg.metainformation#" output="a_str_wddx_ids3" action="cfml2wddx">
		
			<cfset a_item.setoriginalid3tags( a_str_wddx_ids3 ) />
			<cfset a_item.setconvertjobkey( a_struct_create_convert_job.jobkey ) />
				
			<!--- 1 = converting --->
			<cfset a_item.setstatus( 1 ) />
			<cfset oTransfer.save( a_item ) />															
			
			<!--- return that we are preparing the file ... --->
			<cfreturn application.udf.SetReturnStructErrorCode( stReturn, 4200 ) />
		
		</cfcase>
	
	</cfswitch>
	
	<!--- meta information provided or do we have to find it out ourselves? --->
	<cfif a_bol_meta_data_exists>
		<cffile action="read" charset="utf-8" file="#a_item.getlocation_metainfo()#" variable="a_str_meta_info_file_content">
	</cfif>
	
	<!--- check if it is valid XML --->
	<cfset a_bol_meta_data_exists = IsXML( a_str_meta_info_file_content ) />
	
	<!--- if meta data exists, pass it it on ... --->
	<cfif a_bol_meta_data_exists>
		<cfset a_struct_meta_infos = GenericMetaInfoXMLToStruct( a_str_meta_info_file_content ) />
	</cfif>
	
	<!--- check for empty library key --->
	<cfif Len( a_str_librarykey ) IS 0>
		<cfset a_str_librarykey = a_cmp_mediaitems.GetDefautLibraryEntrykey( a_str_userkey ) />
	</cfif>
	
	<!--- tell the user that we're finishing ... --->
	<cfset a_item.setstatus( 2 ) />
	<cfset oTransfer.save( a_item ) />
	
	<!--- does not exist, so proceed ... --->
	<cfset a_struct_result_add = a_cmp_mediaitems.AddMediaLibraryItem(securitycontext = application.beanFactory.getBean( 'SecurityComponent' ).GetUserContextByUserkey( a_str_userkey ),
									librarykey = a_str_librarykey,
									originalhashvalue = a_item.getoriginalhashvalue(),
									filename = a_item.getLocation(),
									metainformation = a_struct_meta_infos,
									autoaddtoplaylist = a_item.getautoaddtoplaylist() ) />
									
	<cfif NOT a_struct_result_add.result>
		<cfreturn a_struct_result_add />
	</cfif>						

	<!--- success --->
	<cfreturn application.udf.SetReturnStructSuccessCode( stReturn ) />

</cffunction> --->

<cffunction access="private" name="GenericMetaInfoXMLToStruct" returntype="struct" output="false"
		hint="convert the generic XML to struct ... this generic XML is uploaded by the tunesBag uploading application">
	<cfargument name="content" type="string" required="true"
		hint="raw xml content (string)">
		
	<cfset var stReturn = StructNew() />
	<cfset var a_xml_obj = XmlParse(arguments.content) />
	<cfset var a_xml_data = XMLSearch(a_xml_obj, '//data/') />
	<cfset var ii = 0 />
	
	<cfset a_xml_data = a_xml_data[1].xmlchildren />
			
	<cfloop from="1" to="#ArrayLen(a_xml_data)#" index="ii">
		<cfset stReturn[a_xml_data[ii].xmlname]  = a_xml_data[ii].xmltext />
	</cfloop>
	
	<cfreturn stReturn />
</cffunction>

</cfcomponent>