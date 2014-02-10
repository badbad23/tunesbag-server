<!---

	user.mobile

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_struct_user_data = event.getArg( 'a_struct_userdata' ) />
<!--- send code? --->
<cfset a_bol_send_confirmation = event.getArg( 'DoSendConfirmationCode', false ) />
<cfset a_bol_verify_code = event.getArg( 'DoVerifyConfirmationCode', false ) />

<!--- get possible results --->
<cfset a_struct_result_send_code = event.getArg( 'a_struct_confirmation_code_send_result' ) />
<cfset a_struct_verify_confirmation_code = event.getArg( 'a_struct_verify_confirmation_code' ) />

<!--- cellphone number not yet entered --->
<cfif a_struct_user_data.getcellphone_nr() IS ''>
	<cfsavecontent variable="request.content.final">
	
	<div style="padding:12px;">
	<cfoutput>#application.udf.WriteCommonErrorMessage( 5200, '<a href="/james/?event=user.preferences">' & application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' ) & '</a>')#</cfoutput>
	</div>
	
	</cfsavecontent>
	
	<cfexit method="exittemplate">

</cfif>

<!--- number not yet confirmed --->
<cfif a_struct_user_data.getcellphone_confirmed() IS 0>

	<cfsavecontent variable="request.content.final">
	
		<div style="padding:12px;">
		<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'mob_ph_confirm_your_number' ), '' )#</cfoutput>
		<br />
		
		<cfif NOT a_bol_send_confirmation>
			<!--- send the code --->
			
			<form action="/james/?" method="get">
				<input type="hidden" name="event" value="user.mobile" />
				<!--- force sending --->
				<input type="hidden" name="DoSendConfirmationCode" value="true" />
				
				<cfoutput>
				<table class="table_details">
					<tr>
						<td class="field_name">
							#application.udf.GetLangValSec( 'cm_wd_cellphone' )#
						</td>
						<td>
							<b>#htmleditformat( a_struct_user_data.getcellphone_nr() )#</b>
							&nbsp;
							<a href="/james/?event=user.preferences">#application.udf.si_img( 'pencil')# #application.udf.GetLangVal( 'cm_wd_edit' )#</a>
						</td>
					</tr>
					<tr>
						<td class="field_name"></td>
						<td>
							<input type="submit" value="#application.udf.GetLangValSec( 'cm_wd_btn_send' )#" class="btn" />
						</td>
					</tr>
				</table>
				
				</cfoutput>
				
			</form>
			
		<cfelse>
			<!--- enter the code --->
			
			<div class="status">
				<cfoutput>#application.udf.si_img( 'key' )# #application.udf.GetLangValSec( 'mob_ph_confirm_number_hint' )#</cfoutput>
			</div>
		
			
			<form action="/james/?" method="get">
			<input type="hidden" name="event" value="user.mobile" />
			<!--- yes, check --->
			<input type="hidden" name="DoVerifyConfirmationCode" value="true" />
			
				<input type="text" name="code" /> 
				
				<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>" class="btn" />
			</form>
			
		</cfif>
		
		</div>
	
	</cfsavecontent>
	
	<cfexit method="exittemplate">
	
</cfif>

<!--- verify did not work --->
<cfif a_bol_verify_code AND NOT a_struct_verify_confirmation_code.result>

	<cfset request.content.final = application.udf.WriteCommonErrorMessage( 5210 ) />
</cfif>

<cfsavecontent variable="request.content.final">

<div style="padding:12px">
<cfif a_bol_verify_code AND a_struct_verify_confirmation_code.result>
		
	<div class="confirmation">
		<cfoutput>#application.udf.GetLangValSec( 'mob_ph_confirm_number_success' )#</cfoutput>
	</div>
		
</cfif>

Please go to http://m.tunesBag.com/ on your mobile phone.

</div>
</cfsavecontent>