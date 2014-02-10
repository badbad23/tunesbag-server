<!---

	explore users

--->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_name = event.getArg( 'name' ) />
<cfset q_select_users = event.getArg( 'a_struct_explore' ).q_select_explore_users />

<cfsavecontent variable="request.content.final">

<div class="div_container">

<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_users'),  '')#</cfoutput>

<cfif q_select_users.recordcount IS 0>
	
<div class="status">
<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
</div>

<cfelse>

<div class="div_container">
	<cfoutput query="q_select_users" startrow="1" maxrows="20">
		
		<div style="margin-right:12px;margin-bottom:12px;float:left;width:auto;">
			<a href="##" onclick="AddNewTab( '#htmlEditformat( q_select_users.username )#', '/james/?event=user.info&amp;username=#urlEncodedFormat( q_select_users.username )#');return false"><img src="#q_select_users.pic#" width="30" height="36" style="vertical-align:middle;padding:2px;border:0px" /> #htmlEditformat( q_select_users.username )#</a>
		</div>
	
		
								
	</cfoutput>
	
	<div style="clear:both"></div>
	
	
</div>


</cfif>

</div>
</cfsavecontent>