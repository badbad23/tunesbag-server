<!--- return a json object --->


<cfset request.content.final = SerializeJSON( event.getargs() ) />
<!--- 
<cfsavecontent variable="request.content.final">

</cfsavecontent> --->