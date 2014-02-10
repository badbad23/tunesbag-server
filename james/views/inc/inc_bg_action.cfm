<!--- //

	Module:		Background Action
	Description:	
	
	Basic elements ...
	
	- success (TRUE / FALSE)
	- message ("")
	- type (type of request)
	- exec_js (JS to execute)
	
// --->

<!--- make sure the basic items are set --->
<cfset event.setArg( 'type', event.getarg( 'type') ) />
<cfset event.setArg( 'result', event.getarg( 'result', false) ) />
<cfset event.setArg( 'exec_js', event.getarg( 'exec_js', '') ) />
<cfset event.setArg( 'message', event.getarg( 'message', '') ) />
<cfset event.setArg( 'error', event.getarg( 'error', 0) ) />

<!--- return all arguments --->
<cfset a_struct_return = StructNew() />

<cfloop list="#StructKeyList( event.getArgs() )#" index="a_str_data">
	<cfset a_struct_return[ uCase( a_str_data) ] = event.getArg( a_str_data ) />
</cfloop>

<cfoutput>#SerializeJSON( a_struct_return )#</cfoutput>