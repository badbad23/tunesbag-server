<!--- //

	Module:		Add/Edit an external ID
	Action:		
	Description:	
	Modified:	$Date$

	$Id$
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_servicename = event.getArg( 'servicename' ) />

<cfset a_bol_has_been_stored = event.getArg( 'stored', false) />
<cfset a_struct_add_result = event.getArg( 'stored_external_result') />

<!--- has been stored? --->
<cfif a_bol_has_been_stored AND a_struct_add_result.result>
	<cflocation addtoken="false" url="/james/?event=user.preferences&stored=true">
</cfif>


<cfsavecontent variable="request.content.final">

<div style="padding:20px;">

<!--- did an error occur? --->	
<cfif a_bol_has_been_stored AND NOT a_struct_add_result.result>
	<cfoutput>#application.udf.WriteCommonErrorMessage( a_struct_add_result.error )#</cfoutput>
</cfif>
	
<!--- check what to do for a specific service --->	
<cfswitch expression="#a_str_servicename#">
	<cfcase value="lastfm">
		
		<h2>Add last.fm service</h2>
	
		<form action="/james/?event=user.preferences.addexternalid&stored=true" method="post">
		<input type="hidden" name="servicename" value="<cfoutput>#htmleditformat( a_str_servicename )#</cfoutput>" />
		<table class="table_details table_edit">
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput>
				</td>
				<td>
					<input type="text" name="ext_username" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_password' )#</cfoutput>
				</td>
				<td>
					<input type="password" name="ext_password" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name"></td>
				<td>
					<input class="btn" type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>">
				</td>
			</tr>
		</table>
		</form>
	
	</cfcase>	
	<cfcase value="mystrands">
		
		<h2>Add mystrands service</h2>
	
		<form action="/james/?event=user.preferences.addexternalid&stored=true" method="post">
		<input type="hidden" name="servicename" value="<cfoutput>#htmleditformat( a_str_servicename )#</cfoutput>" />
		<table class="table_details table_edit">
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_email' )#</cfoutput>
				</td>
				<td>
					<input type="text" name="ext_username" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_password' )#</cfoutput>
				</td>
				<td>
					<input type="password" name="ext_password" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name"></td>
				<td>
					<input class="btn" type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>">
				</td>
			</tr>
		</table>
		</form>
	
	</cfcase>	
	<cfcase value="twitter">
		
		<h2>Add Twitter service</h2>
	
		<form action="/james/?event=user.preferences.addexternalid&stored=true" method="post">
		<input type="hidden" name="servicename" value="<cfoutput>#htmleditformat( a_str_servicename )#</cfoutput>" />
		<table class="table_details table_edit">
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput>
				</td>
				<td>
					<input type="text" name="ext_username" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_password' )#</cfoutput>
				</td>
				<td>
					<input type="password" name="ext_password" value="" />
				</td>
			</tr>
			<tr>
				<td class="field_name"></td>
				<td>
					<input class="btn" type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>">
				</td>
			</tr>
		</table>
		</form>
	
	</cfcase>
	<cfcase value="facebook">
		
		<h2><cfoutput>#application.udf.GetLangValSec( 'cm_ph_redirecting_please_wait' )#</cfoutput></h2>
		
		
		<script type="text/javascript">
			<!--- parent.location.href = 'http://www.facebook.com/login.php?v=1.0&next=calledfrompreferencesdialog&api_key=<cfoutput>#application.udf.GetSettingsProperty( 'fb_apikey', '' )#</cfoutput>'; --->
			parent.location.href = '<cfoutput>#getFBAppBaseURL()#</cfoutput>';
		</script>

	</cfcase>
</cfswitch>
	
</div>
</cfsavecontent>

<!--- //
$Log$
//--->