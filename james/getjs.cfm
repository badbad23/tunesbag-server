<!---

	deliver javascript file
	
	... compress if the filesize has changed

--->

<cfparam name="url.f" type="string" default="">

<!--- filter out invalid requests --->
<cfif Len( url.f ) IS 0>
	<cfabort>
</cfif>

<cfinclude template="/common/scripts.cfm">

<cfset a_str_temp_directory = application.udf.GetTBTempDirectory() />
<cfset a_str_valid_files = 'james.data.js,james.db.js,james.interface.js' />

<cfif NOT ListFindNoCase( a_str_valid_files, url.f )>
	<!--- invalid file --->
	<cfexit method="exittemplate">
</cfif>

<cfset a_str_directory = GetDirectoryFromPath( GetBaseTemplatePath() ) />

<!--- get the right directory --->
<cfset a_str_base_directory = ReplaceNoCase( a_str_directory, 'james/', '' ) />
<cfset a_str_src_directory = a_str_base_directory & '/res/js/james/' />
<cfset a_str_tools_directory = a_str_base_directory & '/tools/' />

<cfset a_str_cur_file = a_str_src_directory & url.f />

<cfif NOT FileExists( a_str_cur_file )>
	<cfexit method="exittemplate">
</cfif>

<!--- make sure for working properly --->
<cfheader name="Content-Disposition" value="inline; filename=#url.f#">

<!--- on a develop machine, deliver the real file --->
<cfif application.udf.IsDevelopmentServer()>
	<cfcontent type="text/x-javascript" deletefile="false" file="#a_str_cur_file#">
</cfif>

<!--- use the filesize for the caching stuff --->
<cfset a_int_filesize_cur_file = application.udf.fileSize( a_str_cur_file ) />

<!--- the cached file --->
<cfset a_str_cache_file = a_str_temp_directory & '/' & a_int_filesize_cur_file & '_compressed_' & url.f & '.js' />

<!--- exec compressor if needed --->
<cfif NOT FileExists( a_str_cache_file )>
	<cfexecute name="#application.udf.GetJavaPath()#" arguments="-jar #a_str_tools_directory#yuicompressor-2.3.5.jar -o #a_str_cache_file# #a_str_cur_file#" timeout="30"></cfexecute>
</cfif>

<!--- deliver compressed file --->
<cfcontent type="text/x-javascript" deletefile="false" file="#a_str_cache_file#">