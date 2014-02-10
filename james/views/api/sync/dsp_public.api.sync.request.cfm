<!---

	API

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_struct_api_request = event.getArg( 'a_struct_api_request', StructNew() ) />

<cfif NOT a_struct_api_request.result AND Len( a_struct_api_request.errormessage ) IS 0>
	<cfset a_struct_api_request.errormessage = application.udf.GetLangValSec( 'err_ph_' & a_struct_api_request.error ) />
</cfif>

<cfcontent type="text/xml; charset=UTF-8">

<cfoutput>#application.udf.GenerateWSXML( a_struct_api_request )#</cfoutput>