<!--- 

	change the password

 --->

<cfinclude template="/common/scripts.cfm">

<cfset stResult = event.getArg( 'stPasswordChangeResult' ) />

<cfsavecontent variable="request.content.final">
<div class="div_container">
<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec('cm_ph_change_password'), '')#</cfoutput>

<cfif IsStruct( stResult )>
	
	<cfif stResult.result>
		<div class="confirmation"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_success_update' )#</cfoutput></div>
	<cfelse>
		<div class="status"><cfoutput>#stResult.errormessage#</cfoutput></div>
	</cfif>

</cfif>

<cfoutput>
<form action="#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#" method="post">
<input type="hidden" name="PasswordChangeRequest" value="true" />
</cfoutput>
<table class="table_details table_edit change_pwd_dlg">
	<tr>
		<td class="field_name">
			<cfoutput>#application.udf.GetLangValSec( 'cm_ph_old_password' )#</cfoutput>
		</td>
		<td>
			<input type="password" name="frmoldpwd" value="" />
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<cfoutput>#application.udf.GetLangValSec( 'cm_ph_new_password' )#</cfoutput>
		</td>
		<td>
			<input type="password" name="frmnewpwd1" value="" />
		</td>
	</tr>
	<tr>
		<td class="field_name">
			<cfoutput>#application.udf.GetLangValSec( 'cm_ph_repeat_new_password' )#</cfoutput>
		</td>
		<td>
			<input type="password" name="frmnewpwd2" value="" />
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="<cfoutput>#application.udf.GetLangValSec('cm_ph_change_password')#</cfoutput>" class="btn" />
		</td>
	</tr>
</table>
</form>
</div>
</cfsavecontent>