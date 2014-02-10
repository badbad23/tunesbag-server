<!--- deliver a file --->
<cfinclude template="/common/scripts.cfm">

<!--- get the information and check if the file exists --->
<cfset a_info = event.getArg( 'a_info' ) />
<cfset a_bol_force_dl = event.getArg( 'forcedl', false ) />

<cfif NOT a_info.getisPersisted()>
	<cfabort>
</cfif>

<!--- just a redirector? --->
<cfif FindNoCase( 'http://', a_info.getFilename() ) IS 1>
	<cflocation addtoken="false" url="#a_info.getFileName()#">
</cfif>

<!--- continue, ordinary file --->
<cfif NOT FileExists( a_info.getfilename() )>
	<cfabort>
</cfif>

<cfheader name="Pragma" value="no-cache"> 
<cfheader name="Expires" value="Thu Jan 01 00:00:00 CET 1970">
<cfheader name="Content-Length" value="#application.udf.fileSize( a_info.getFilename() )#">

<!--- force download? --->
<cfif a_bol_force_dl>
	<cfheader name="Content-Disposition" value="attachment; filename=audio.mp3">
</cfif>

<cfcontent deletefile="false" file="#a_info.getFileName()#" type="#a_info.getContentType()#">