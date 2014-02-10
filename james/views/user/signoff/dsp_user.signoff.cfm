<!--- 

	leaving tunesBag

 --->

<cfinclude template="/common/scripts.cfm" />

<cfset sErrorMessage = event.getArg( 'sErrorMessage' ) />

<cfsavecontent variable="request.content.final">
<div class="div_container">

<cfoutput>
	
<h1>#application.udf.GetLangValSec( 'pref_ph_signoff_close_account' )# (#application.udf.GetCurrentSecurityContext().username#)</h1>

<cfif Len( sErrorMessage )>
	<div class="status">#htmleditformat( sErrorMessage )#</div>
</cfif>

<br />

<form action="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" method="post">
<table class="table_details table_edit">
	<tr>
		<td>
			#application.udf.GetLangValSec( 'pref_ph_signoff_enter_pwd' )#
			<br />
			<input type="password" name="password" value="" />
		</td>
	</tr>
	<tr>
		<td>
			#application.udf.GetLangValSec( 'pref_ph_signoff_reason' )#
			<br />
			<textarea name="comment"></textarea>
		</td>
	</tr>
	<tr>
		<td>
			<input type="submit" value="#application.udf.GetLangValSec( 'pref_ph_signoff_close_account' )#" class="btn btnred" />		
			<br /><br />
			#application.udf.GetLangValSec( 'pref_ph_signoff_irreversible' )#
		</td>
	</tr>
</table>

</form>
</cfoutput>
</div>
</cfsavecontent>