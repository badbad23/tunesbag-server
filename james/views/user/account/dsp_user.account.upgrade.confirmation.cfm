<!--- target URL --->

<cfinclude template="/common/scripts.cfm">

<cfset sURL = event.getArg( 'url' ) />

<cfset stUserData = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserData( application.udf.GetCurrentSecurityContext().entrykey )>

<cfsavecontent variable="request.content.final">

<br />
<h4><cfoutput>#application.udf.GetLangValSec( 'cm_wd_confirmation' )#</cfoutput></h4>

<p>
	<a href="#" onclick="openPreferencesDialog();return false">Please check your entered data or click here to modify them.</a>
</p>

<cfoutput>
<table class="table_details">
	<tr>
		<td>
			#application.udf.GetLangValSec( 'cm_wd_firstname' )#
		</td>
		<td>
			#htmleditformat( stUserData.a_STRUCT_ITEM.getfirstname() )#
		</td>
	</tr>
	<tr>
		<td>
			#application.udf.GetLangValSec( 'cm_wd_surname' )#
		</td>
		<td>
			#htmleditformat( stUserData.a_STRUCT_ITEM.getsurname() )#
		</td>
	</tr>
	<tr>
		<td>
			#application.udf.GetLangValSec( 'cm_wd_country' )#
		</td>
		<td>
			#htmleditformat( stUserData.a_STRUCT_ITEM.getcountryisocode() )#
		</td>
	</tr>
	<tr>
		<td>
			#application.udf.GetLangValSec( 'cm_wd_email' )#
		</td>
		<td>
			#htmleditformat( stUserData.a_STRUCT_ITEM.getemail() )#
		</td>
	</tr>
</table>

<form id="idCheckout">
<div class="status">
	<input type="checkbox" id="frmcatc" name="frmcatc" value="true" /> <label for="frmcatc">#application.udf.GetLangValSec( 'signup_ph_accept_ctac' )#</label> (<a href="/rd/terms/" target="_blank">#application.udf.GetLangValSec( 'nav_wd_terms' )#</a>)
	<br />
	<br />
	<input type="button" value="Continue with Checkout ..." onclick="checkCheckoutForm('#JsStringFormat( sURL )#')" />
</div>
</form>

<script type="text/javascript">
	function checkCheckoutForm(targeturl) {
		if ($('##frmcatc').attr( 'checked' ) == false) {
			alert('#JSStringFormat( application.udf.GetLangValSec( 'err_ph_5005'))#');
			return false;
			} else {
				window.open( targeturl );
				}
		}
</script>

</cfoutput>

</cfsavecontent>