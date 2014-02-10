<!--- //

	Module:		Deliver the media content
	Action:		
	Description:	
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_entrykey = event.getArg('entrykey', '') />
<cfset a_struct_item = event.getarg('a_struct_item') />
<cfset a_struct_deliver_information = event.getArg('deliver_info') />

<cfswitch expression="#a_struct_deliver_information.type#">

	<cfcase value="http">
		
		<!--- http redirect --->
		<cflocation addtoken="false" url="#a_struct_deliver_information.location#">
		
	</cfcase>
	
	<cfcase value="file">
		
		<!--- delive from file --->
		<cfheader name="Pragma" value="no-cache"> 
		<cfheader name="Expires" value="Thu Jan 01 00:00:00 CET 1970">
		<cfheader name="Content-Length" value="#application.udf.fileSize( a_struct_deliver_information.location )#">
		
		<!--- <cfheader name="Content-Disposition" value="inline;filename=deliver.mp3">  --->
		<cfcontent deletefile="false" file="#a_struct_deliver_information.location#" type="audio/mpeg">
	
	</cfcase>
	
</cfswitch>