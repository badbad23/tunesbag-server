<!--- 

	
	upgrade account


 --->

<cfinclude template="/common/scripts.cfm">

<cfprocessingdirective pageencoding="utf-8">

<!--- <cfsavecontent variable="request.content.final">
<div class="headlinebox bb">
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetLangValSec( 'shop_ph_checkout_hint' )#</cfoutput></p>
</div>
<div class="div_container">
	<h4>Our premium services are coming soon to your country as well!</h4>
</div>
</cfsavecontent>
<cfexit method="exittemplate"> --->

<cfset stPlans = event.getArg( 'stPlans' ) />
<cfset oUserdata = event.getArg( 'a_struct_userdata' ) />
<cfset bSpecialOffer = false />
<cfset sAddSpecial = '' />
<cfset sSpecialName = '' />

<cfsavecontent variable="request.content.final">
<div class="headlinebox bb">
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetLangValSec( 'shop_ph_checkout_hint' )#</cfoutput></p>
</div>
<div class="div_container">


<!--- <cfdump var="#oUserdata.getdt_created()#"> --->
<!--- check if we can make a special offer --->
<!--- <cfif oUserdata.getdt_created() LT CreateDate( 2010, 02, 03 )>
	<div class="status">
		<cfoutput>
		<img src="http://cdn.tunesBag.com/images/vista/Symbol-Information.png" style="height:48px;float:left;margin-right:12px" alt="" title="Special Offer" />
		
		<b style="text-transform:uppercase"><!--- #application.udf.si_img( 'lightning' )#  --->Special offer for long-time customers</b>
		</cfoutput>
		<br />
		<p>
		You've signed up for the closed beta of tunesBag some time ago and your feedback and support was key for our success!
		<br />
		We would like to say thank you and offer you <b>all plans for 1 EUR for the <i>whole</i> first year</b>! The regular price applies after the first year *****

		</p>
	</div>
	
	<!--- set special! --->
	<cfset bSpecialOffer = true />
	
	<!--- add to links ... --->
	<cfset sAddSpecial = '&amp;special=betauserupgrade' />
	<cfset sSpecialName = 'betauserupgrade' />
	 --->
<cfif getCurrentSecurityContext().stplan.accounttype IS 0>
	
	<div class="status">
		<cfoutput>
		<img src="http://cdn.tunesBag.com/images/vista/Symbol-Information.png" style="height:48px;float:left;margin-right:12px" alt="" title="Special Offer" />
		
		<b style="text-transform:uppercase">Special offer for our long-term customers</b>
		</cfoutput>
		<br />
		We would like to say thank you and offer you <b>all plans for 1 EUR for the first two months</b>! The regular price applies afterwards. *****

		</p>
	</div>
	
	<!--- set special! --->
	<cfset bSpecialOffer = true />
	<cfset sSpecialName = 'freeuser' />	
	
	<!--- add to links ... --->
	<cfset sAddSpecial = '&amp;special=freeuser' />

</cfif>

<style type="text/css">
	table.packages {
		border-collapse:collapse;
		width:100%;
		border: silver solid 0px;
		border-bottom: silver solid 1px;
		}
	table.packages th {
		padding: 10px;
		font-size:14px;
		text-align:center;
		background-color:#EEEEEE;
		border-top: silver solid 1px;
		}
	table.packages td {
		padding: 12px;
		font-size:12px;
		text-align:center;
		line-height: 200%;
		}
		
	table.packages td.property {
		text-align: right;
		font-weight:bold;
		width:200px;
		}
		
	.small .property, .small td {
		font-size: 12px !important;
		}
	.property .addinfotext {
		font-size: 12px;
		}
		
	<!--- the normal price --->
	.normalprice {
		<cfif bSpecialOffer>
		text-decoration:line-through;
		</cfif>
		}
		
	<!--- the special price (one year) --->
	.specialprice_1year {
		<cfif bSpecialOffer AND sSpecialName IS 'freeuser'>
		display: block;
		<cfelse>
		display: none;
		</cfif>
		font-weight:bold;
		color:  rgb(172, 36, 5); 
		}
		
	<!--- the special price (six months) --->
	.specialprice_6months {
		<cfif bSpecialOffer AND sSpecialName IS 'iphoneuser'>
		display: block;
		<cfelse>
		display: none;
		</cfif>
		font-weight:bold;
		color:  rgb(172, 36, 5); 
		}
</style>

<cfset sUserPlan = 'basic' />

<cfloop list="#StructKeyList( stPlans)#" index="sPlan">
	<cfif stPlans[ sPlan ].accounttype IS application.udf.GetCurrentSecurityContext().ACCOUNTTYPE>
		<cfset sUserPlan = sPlan />
	</cfif>
</cfloop>

<!---  --->
<script type="text/javascript">
	function confirmOrderData( targeturl ) {
		SimpleInpagePopup( langSet.getTrans( 'cm_wd_confirmation' ), '/james/?event=user.account.upgrade.confirmation&height=400&width=440&url=' + encodeURIComponent( targeturl ), false, '' );
		}
</script>

<div style="padding:20px">

	<div style="text-align:right;float:right">
		<cfoutput>#application.udf.GetLangValSec( 'shop_wd_currency' )#</cfoutput> 
		<select name="frmcurrency" disabled="true">
			<option value="EUR">EUR</option>
			<option value="USD">USD</option>
			<option value="GBP">GBP</option>
		</select>
	</div>
	
	
	<cfoutput>#application.udf.GetLangValSec( 'shop_ph_your_plan' )# <span class="tag_box">#sUserPlan#</span></cfoutput>
</div>

<div class="clear"></div>
<table class="packages" id="idFeatureComparison" border="1" style="margin-left:auto;margin-right:auto">
	<thead>
	<tr>
		<th>
			
		</th>
		<th>
			Basic
		</th>
		<th style="font-size:14px">
			Small
		</th>
		<th style="font-size:14px">
			Medium
		</th>
		<th style="font-size:14px">
			Large
		</th>
	</tr>
	</thead>
	<tbody>
		<tr>
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_wd_storage' )#</cfoutput> (GB)
				<br />
				<span class="addinfotext"><cfoutput>#application.udf.GetLangValSec( 'shop_ph_number_tracks' )#</cfoutput>*</span>
			</td>
			<td style="font-weight:bold">
				<!--- <cfoutput>#(stPlans.basic.quota / 1024 / 1024 / 1024)#</cfoutput>
				<br />
				<span class="addinfotext"><cfoutput>#(Int( stPlans.basic.quota / (5 * 1024 * 1024 ) / 100 ) * 100)#</cfoutput></span> --->
				
				<a href="/dropbox/" target="_blank">Free Dropbox account</a>: 2 GB, max 500 media files.
			</td>
			<td style="font-weight:bold">
				<cfoutput>#(stPlans.s.quota / 1024 / 1024 / 1024)#</cfoutput>
				<br />
				<span class="addinfotext"><cfoutput>#(Int( stPlans.s.quota / (5 * 1024 * 1024 ) / 1000 ) * 1000)#</cfoutput></span>
			</td>
			<td style="font-weight:bold">
				<cfoutput>#(stPlans.m.quota / 1024 / 1024 / 1024)#</cfoutput>
				<br />
				<span class="addinfotext"><cfoutput>#(Int( stPlans.m.quota / (5 * 1024 * 1024 ) / 1000 ) * 1000)#</cfoutput></span>
			</td>
			<td style="font-weight:bold">
				<cfoutput>#(stPlans.l.quota / 1024 / 1024 / 1024)#</cfoutput>
				<br />
				<span class="addinfotext"><cfoutput>#(Int( stPlans.l.quota / (5 * 1024 * 1024 ) / 1000 ) * 1000)#</cfoutput></span>
			</td>
		</tr>
		<!--- <tr>
			<td class="property">
				Best for
			</td>
			<td>
				Occasional users
			</td>
			<td>
				Large collection with a lot of time and money invested.
			</td>
			<td>
				Our plan that fits for most people
			</td>
			<td>
				Large collection with a lot of time and money invested.
			</td>
		</tr> --->
		<tr>
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_ad_free' )#</cfoutput>
			</td>
			<td>
			
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
		</tr>		
		<tr>
			<td class="property"></td>
			<td colspan="4" style="text-align:center">
				<a href="#" onclick="$('#idFeatureComparison .hidden').removeClass('hidden');return false">+ <cfoutput>#application.udf.GetLangValSec( 'shop_ph_expand_feature_matrix' )#</cfoutput></a>
			</td>
		</tr>
		<tr class="hidden">
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_desktop_uploader' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
		</tr>
		<!--- <cfif application.udf.GetCurrentSecurityContext().rights.playlist.radio IS 1>
		<tr class="hidden">
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_plist_other_users' )#</cfoutput>****
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
			<td>
				<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>
			</td>
		</tr>
		</cfif>		 --->
		<tr class="hidden">
			<td class="property ">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_streaming_bitrates' )#</cfoutput>
			</td>
			<td>
				128 kb/sec
			</td>
			<td colspan="3">
				Up to 320 kb/sec**
			</td>
		</tr>
		<tr class="hidden">
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_max_filesize_audio' )#</cfoutput> (MB)
			</td>
			<td>
				10
			</td>
			<td colspan="3" style="text-align:center">
				50
			</td>
		</tr>			
		<!--- <tr class="hidden">
			<td class="property">
				<cfoutput>#application.udf.GetLangValSec( 'shop_ph_max_holdback_time' )#</cfoutput>
			</td>
			<td>
				360 days***
			</td>
			<td colspan="3">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_unlimited' )#</cfoutput>
			</td>
		</tr> --->
		<tr>
			<td class="property">
				€/month
				<br />
				<span style="font-weight:normal"><cfoutput>#application.udf.GetLangValSec( 'shop_ph_recurring_info_cancel' )#</cfoutput></span>
			</td>
			<td>
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_free' )#</cfoutput>
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.s.prices_month.EUR )#</cfoutput></span>
				<br />
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				

				<input type="button" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_upgrade' )#</cfoutput>" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=s&amp;period=month<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.m.prices_month.EUR )#</cfoutput></span><br />
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				
				<input type="button" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_upgrade' )#</cfoutput>" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=m&amp;period=month<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.l.prices_month.EUR )#</cfoutput></span><br />
				
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				
				<input type="button" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_upgrade' )#</cfoutput>" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=l&amp;period=month<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
		</tr>
		<tr>
			<td class="property">
				€/year <span class="tag_box">2 months free!</span>
				<br />
				<span style="font-weight:normal"><cfoutput>#application.udf.GetLangValSec( 'shop_ph_recurring_info_cancel' )#</cfoutput></span>
			</td>
			<td>
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_free' )#</cfoutput>
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.s.prices_year.EUR )#</cfoutput></span><br />
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_Wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				
				<input type="button" value="Upgrade" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=s&amp;period=year<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.m.prices_year.EUR )#</cfoutput></span><br />
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_Wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				
				<input type="button" value="Upgrade" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=m&amp;period=year<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
			<td>
				<span class="normalprice"><cfoutput>#DecimalFormat( stPlans.l.prices_year.EUR )#</cfoutput></span><br />
				<span class="specialprice_freeuser">1,00 / 2 <cfoutput>#application.udf.GetLangValSec( 'cm_Wd_months' )#</cfoutput></span>
				<span class="specialprice_6months">1,00 / 6 <cfoutput>#application.udf.GetLangValSec( 'cm_wd_months' )#</cfoutput></span>
				
				<input type="button" value="Upgrade" class="btn" onclick="confirmOrderData( '/james/?event=user.account.upgrade&amp;plan=l&amp;period=year<cfoutput>#sAddSpecial#</cfoutput>' );return false" />
			</td>
		</tr>
		<!--- <tr>
			<td class="property">
			
			</td>
			<td>
			</td>
			<td colspan="3">
				<a href="#" onclick="$('#idFeatureComparison .familypackage').removeClass('hidden');return false">+ Want to make friends, family or collegues happy with a premium account as well?</a>
			</td>
		</tr>
		<tr class="familypackage hidden">
			<td class="property">
				Three accounts
				<br />
				€/year
				<br />
				<span class="tag_box">2 months free!</span>
			</td>
			<td>
				
			</td>
			<td>
				49,00
			</td>
			<td>
				99,00
			</td>
			<td>
				279,00
			</td>
		</tr> --->
	</tbody>
</table>
<img src="http://cdn.tunesbag.com/images/partner/services/paypal-support-253x80.gif" height="80" width="253" alt="Checkout via PayPal" title="Checkout via PayPal" style="vertical-align:middle;float:right;padding:8px" />
<br />
<cfoutput>
<b>#application.udf.GetLangValSec( 'cm_wd_Remarks' )#</b>
<br />
* #application.udf.GetLangValSec( 'shop_ph_remark_filesize' )#
<br />
** #application.udf.GetLangValSec( 'shop_ph_remark_streamingquality' )#
<br />
*** #application.udf.GetLangValSec( 'shop_ph_remark_deleteold' )#
<br />
**** #application.udf.GetLangValSec( 'shop_ph_remark_legal_licence' )#
<br />
***** Offer is only valid if you don't cancel the contract until the first payment of the regular plan, otherwise your featureset will be reset to the Basic package. In this case EUR 1 will be retained as handling fees.
</div>
</cfoutput>
</cfsavecontent>