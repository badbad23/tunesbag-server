<!--- 
	
	register

 --->
<cfinclude template="/common/scripts.cfm">
<cfset stConfirm = event.getArg( 'stConfirmAccount' ) />

<cfsavecontent variable="request.content.final">

<cfif NOT stConfirm.result>
	<div class="status" style="margin-right:40px">
		<cfoutput>#stConfirm.errormessage#</cfoutput>
		<br /><br />
		<a href="/rd/signup/"><cfoutput>#application.udf.GetLangValSec( 'signup_ph_signup_now_btn' )#</cfoutput></a>
	</div>
</cfif>
</cfsavecontent>