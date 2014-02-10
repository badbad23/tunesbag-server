<!--- 
	
	execute order

 --->

<cfinclude template="/common/scripts.cfm">

<cfset stDetails = event.getArg( 'ExpressCheckoutDetails' ) />

<cfif NOT stDetails.result>
	<cfsavecontent variable="request.content.final">
		<div class="status">
			An error occured. Please try again
		</div>
	</cfsavecontent>
	
	<cfmail from="office@tunesBag.com" to="office@tunesBag.com" subject="[PAYPAL] An error occured" type="html">
	<cfdump var="#stDetail#">
	</cfmail>
	
	<cfexit method="exittemplate" />
</cfif>

<cfset stResponse = stDetails.RESPONSE />

<cfsavecontent variable="request.content.final">
<div class="div_container">



<cfoutput>
<!---  	<cfdump var="#event.getargs()#">  --->
<!--- <div class="confirmation">
	#application.udf.GetLangValSec( 'shop_ph_please_authorize_continue' )#
</div> --->

<div style="padding:120px;text-align:center;font-weight:bold">
	<img alt="" style="border:0px" src="http://cdn.tunesBag.com/images/img_circle_loading.gif" width="32" height="32" class="img_wait" />
	
	<br /><br />
	#application.udf.GetLangValSec( 'cm_ph_redirecting_please_wait' )#
	<br /><br />
	<a href="##" id="idlinkProceed" onclick="$('##idFormUpgrade').submit();return false" class="hidden">#application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' )#</a>
</div>
	
<form action="/james/?event=user.account.upgrade.paypal.expresscheckout.performpayment" method="post" style="display:none" id="idFormUpgrade">

<input type="hidden" name="payerId" value="#htmleditformat( stResponse.payerId )#" />
<input type="hidden" name="token" value="#htmleditformat( stResponse.token )#" />
<input type="hidden" name="currencycode" value="#htmleditformat( stResponse.currencycode )#" />
<!--- SALE! --->
<input type="hidden" name="paymentaction" value="sale" />
<input type="hidden" name="amount" value="#Tobase64( Encrypt( stResponse.amt, '+sdgks8df3?&$sibdu' ))#" />
<input type="hidden" name="paymentkey" value="#htmleditformat( stResponse.custom )#" />

<table class="table_details table_edit">
	<tr>
		<td class="field_name">
			#application.udf.GetLangValSec( 'shop_wd_amount' )#
		</td>
		<td>
			#htmleditformat( stResponse.currencycode )# #stResponse.amt#
		</td>
	</tr>
	<tr>
		<td class="field_name">
			#application.udf.GetLangVal( 'shop_wd_period' )#
		</td>
		<td>
			per #stDetails.OPAYMENTCONTEXT.getPeriod()#
			/
			#application.udf.GetLangValSec( 'shop_ph_cancel_anytime' )#
		</td>
	</tr>
	<tr>
		<td class="field_name"></td>
		<td>
			<input type="submit" value="#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#" class="btn" />
		</td>
	</tr>
</table>


</form>
</cfoutput>

</div>

<script type="text/javascript">
	$('#idFormUpgrade').submit();
	
	window.setTimeout( 2000, function() { $('#idlinkProceed').fadeIn() });
</script>
</cfsavecontent>