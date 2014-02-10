<!--- 
	
	transaction failed

 --->

<cfmail from="office@tunesBag.com" to="office@tunesBag.com" subject="[PayPalTransactionFailed]" type="html">
<cfdump var="#event.getArgs()#" label="event">
<cfdump var="#session#" label="session">
<cfdump var="#cgi#">
</cfmail>

<cfsavecontent variable="request.content.final">

<div style="padding:80px">
<h1>The transaction failed</h1>
<br />
<p>
	Our staff has been notified. In case of questions, please contact us (<a href="mailto:office@tunesBag.com">office@tunesBag.com</a>)
</p>
</div>
</cfsavecontent>