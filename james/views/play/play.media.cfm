<!--- //

	Module:	SERVICE
	Description: 
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_bol_found = event.getarg('found', false) />

<cfif NOT a_bol_found>
	<h4><cfoutput>#application.udf.si_img( 'cross' )#</cfoutput> Media item not found.</h4>
	<cfexit method="exittemplate">
</cfif>

<cfset a_struct_item = event.getarg('a_struct_item') />

<!--- default music --->
<cfset request.eventcontext.announceEvent("play.media.music", event.getargs()) />