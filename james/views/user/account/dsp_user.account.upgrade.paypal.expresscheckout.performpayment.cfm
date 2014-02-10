<!--- 

	payment has been done

 --->

<cfinclude template="/common/scripts.cfm">

<cfset oPaymentContext = event.getArg( 'oPaymentContext' ) />

<cfsavecontent variable="request.content.final">
<!--- <cfdump var="#oPaymentContext#"> --->
<div style="padding:80px">

<table>
	<tr>
		<td valign="top">
			<img src="http://cdn.tunesBag.com/images/vista/Symbol-Check.png" class="img64x64" style="" alt="Success" title="Success" />
		</td>
		<td style="padding:12px">
			<h2><cfoutput>#application.udf.GetLangValSec( 'shop_ph_account_updated' )#</cfoutput></h2>
			
			<br /><br /><br />
			<cfif oPaymentContext.getUserkey() IS application.udf.GetCurrentSecurityContext().entrykey>
			<cfoutput>
				<table class="table_details">
					<tr>
						<td class="field_name">
							#application.udf.GetLangVal( 'shop_wd_period' )#
						</td>
						<td>
							#oPaymentContext.getPeriod()#
						</td>
					</tr>
					<tr>
						<td class="field_name">
							#application.udf.GetLangValSec( 'shop_wd_amount' )#
						</td>
						<td>
							#oPaymentContext.getCurrencyCode()# #DecimalFormat( oPaymentContext.getamount() )#
						</td>
					</tr>
					<tr>
						<td class="field_name">
							#application.udf.GetLangValSec( 'cm_wd_start' )#
						</td>
						<td>
							#LSDateFormat( oPaymentContext.getrecurringdatestart(), 'dd.mm.yyyy')#
							
							<cfif DateDiff( 'd', oPaymentContext.getrecurringdatestart(), Now()) IS 0>
								<span class="tag_box">#application.udf.GetLangValSec( 'cm_wd_today' )#</span>
							<cfelse>
								<span class="tag_box">#DateDiff( 'd', Now(), oPaymentContext.getrecurringdatestart())# #application.udf.GetLangValSec( 'cm_wd_days' )#</span>
							</cfif>

						</td>
					</tr>
					<cfif DateDiff( 'd', oPaymentContext.getrecurringdatestart(), Now()) NEQ 0 AND oPaymentContext.getinitialamount() GT 0>
					<tr>
						<td class="field_name">
							#application.udf.GetLangValSec( 'shop_ph_initial_amount' )#
						</td>
						<td>
							#oPaymentContext.getCurrencyCode()# #DecimalFormat( oPaymentContext.getinitialamount() )#
						</td>
					</tr>
					</cfif>
				</table>

			</cfoutput>
			</cfif>
			<br /><br />
			<p>
			<a href="/start/"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_switch_to_library' )#</cfoutput></a>
			</p>
		</td>
	</tr>
</table>

</cfsavecontent>