<!--- 

	forward to paypal

 --->

<cfset a_ok = event.getArg( 'ok', false ) />

<cfinclude template="/common/scripts.cfm">

<cfif NOT a_ok>

	<cfsavecontent variable="request.content.final">
		<div class="status">
			Invalid request. Please try again.
		</div>
	</cfsavecontent>
	
	<cfexit method="exittemplate">
	
<cfelse>

	<cfif application.udf.IsDevelopmentServer() AND cgi.REMOTE_ADDR IS '::1--INVALID'>
		<cfsavecontent variable="request.content.final">
	
		<cfoutput><a href="#event.getArg( 'PayPalRedirect' )#">continue</a></cfoutput>
		<br /><br />
		<cfdump var="#event.getargs()#">
		</cfsavecontent>
	<cfelse>
		
		<cfif Len( event.getArg( 'PayPalRedirect' ) ) IS 0>
			<cfmail from="hp@inbox.cc" to="hp@inbox.cc" subject="pp req" type="html">
			<cfdump var="#event.getargs()#">
			</cfmail>
		</cfif>

		<cflocation addtoken="false" url="#event.getArg( 'PayPalRedirect' )#" />
	</cfif>

</cfif>