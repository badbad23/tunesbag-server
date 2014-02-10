<!--- 

	dummy page

 --->

<cfinclude template="/common/scripts.cfm">


<!--- this should not happen in production --->
<cfif IsLiveServer()>
<!--- <cflocation addtoken="false" url="/"> --->
</cfif>

<cfsavecontent variable="request.content.final">

<!--- 
<h1>dev debug</h1>
<cfdump var="#cgi.QUERY_STRING#">

<cfset sURL = ListFirst( cgi.QUERY_STRING, ';')>

<cfdump var="#event.getArg( 'request' )#" label="req">
<cfdump var="#event.getargs()#">
 --->

<h1>Resource not found.</h1>

</cfsavecontent>

