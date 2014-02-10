<!--- //

	Module:		Logger compnent
	Description: 
	
// --->

<cfcomponent name="storage" displayname="Upload component"output="false" extends="MachII.framework.Listener" hint="Upload handler">
	
<cfprocessingdirective pageencoding="utf-8">
	
<cfinclude template="/common/scripts.cfm">

<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures this listener as part of the Mach-II  framework"> 
	<!--- do nothing --->
</cffunction>

<cffunction access="public" name="GetProcessingQueue" output="false" returntype="void" hint="Get the upload queue">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset event.setArg( 'a_struct_processing_queue', getProperty( 'beanFactory' ).getBean( 'UploadComponent' ).GetProcessingQueue( securitycontext = application.udf.GetCurrentSecurityContext() )) />
	
</cffunction>

<cffunction access="public" name="IssueUploadAuthkey" output="false" returntype="void" hint="issue a new upload authkey">
	<cfargument name="event" type="MachII.framework.Event" required="true" />
	
	<cfset var a_runkey = createUUID() />
	<cfset var a_bol_upload_started = event.getArg('uploadrunning', false) />
	<cfset var a_info = 0 />
	
	<!--- if upload has been started, do NOT issue a new auth key --->
	<cfif a_bol_upload_started>
		<cfreturn />
	</cfif>
	
	<cfset a_info = getProperty( 'beanFactory' ).getBean( 'UploadComponent' ).IssueUploadAuthkey( securitycontext = application.udf.GetCurrentSecurityContext(),
							ip = cgi.REMOTE_ADDR,
							runkey = a_runkey ) />
	
	<cfset event.setArg( 'AuthInfo', a_info ) />
	<cfset event.setArg( 'uploadRunkey', a_runkey ) />

</cffunction>

<!--- <cffunction name="CheckUploadedFiles" access="public" output="false" returntype="void" hint="Check the uploaded files">
	<cfargument name="event" type="MachII.framework.Event" required="true" /> 

	<!--- check if an upload has happened ... parameter must be true --->
	<cfset var a_bol_upload_started = event.getArg('uploadrunning', false) />
	<cfset var ii = 0 />
	<cfset var a_str_upload_filename = '' />
	<cfset var cffile = 0 />
	<!--- <cfset var a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) /> --->
	<cfset var a_cmp_upload = getProperty( 'beanFactory' ).getBean( 'UploadComponent' ) />
	<cfset var a_struct_result_add = 0 />
	<cfset var a_str_tmp_filename = 0 />
	<cfset var a_bol_single_file_upload_available = FileExists(arguments.event.getArg('FILEDATA', '')) />
	
	<cfif NOT a_bol_upload_started>
		<cfreturn />
	</cfif>
		
	<!--- single file upload? --->
	<cfif a_bol_single_file_upload_available>
		
			
			<!--- get file info --->
			<cfset a_str_upload_filename = application.udf.GetTBTempDirectory() & 'upload_' & application.udf.GetCurrentUserkey() & '_' & createUUID() />
			
			<cffile action="upload" filefield="FILEDATA" destination="#a_str_upload_filename#" nameconflict="makeunique" result="cffile">
			
			<cfset a_str_tmp_filename = cffile.ServerDirectory & '/' & cffile.ServerFile />
			
			<!--- add the original file extension again --->
			<cffile action="rename" source="#a_str_tmp_filename#" destination="#a_str_tmp_filename#.#cffile.ClientFileExt#">
			
			<cfset a_str_tmp_filename = a_str_tmp_filename & '.' & cffile.ClientFileExt />
			
			<cfset a_struct_result_add = a_cmp_upload.InsertNewUploadItemNotification(userkey = application.udf.GetCurrentUserkey(),
						librarykey = event.getArg( 'a_str_default_library' , '' ),
						location = a_str_tmp_filename,
						source = 'webupload',
						uploadrunkey = event.getArg( 'uploadrunkey') ) />
			
			<!--- not accepted ... --->			
			<cfif NOT a_struct_result_add.result>
				<cffile action="delete" file="#a_str_tmp_filename#">
			</cfif>
				
	</cfif>
	
	<!--- multi file upload? --->
	<cfloop from="0" to="9" index="ii">
	
		<cfif FileExists(event.getArg('MultiPowUploadFileName_' & ii, ''))>
			
			<!--- get the file information ... --->
			<cfset a_str_upload_filename = application.udf.GetTBTempDirectory() & 'upload_' & application.udf.GetCurrentUserkey() & '_' & createUUID() />
			
			<cffile action="upload" filefield="frmfile#ii#" destination="#a_str_upload_filename#" nameconflict="makeunique" result="cffile">
			
			<cfset a_str_tmp_filename = cffile.ServerDirectory & '/' & cffile.ServerFile />
			
			<!--- add the original file extension again --->
			<cffile action="rename" source="#a_str_tmp_filename#" destination="#a_str_tmp_filename#.#cffile.ClientFileExt#">
			
			<cfset a_str_tmp_filename = a_str_tmp_filename & '.' & cffile.ClientFileExt />
			
			<!--- add to upload notification table ... --->
			<cfset a_struct_result_add = a_cmp_upload.InsertNewUploadItemNotification(userkey = application.udf.GetCurrentUserkey(),
													librarykey = event.getArg('a_str_default_library', ''),
													location = a_str_tmp_filename,
													source = 'webupload',
													uploadrunkey = event.getArg( 'uploadrunkey') ) />
													
			<cfif NOT a_struct_result_add.result>
				<cffile action="delete" file="#a_str_tmp_filename#">
			</cfif>
			
		</cfif>
	
	</cfloop>
	

	
</cffunction> --->

</cfcomponent>