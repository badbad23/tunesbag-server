<!--- return the result --->

<cfset stCheckResult = event.getArg( 'stResult', StructNew() ) />

<cfset request.content.final = SerializeJSON( stCheckResult ) />