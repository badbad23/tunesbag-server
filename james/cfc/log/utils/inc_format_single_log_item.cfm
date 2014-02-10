<cfsavecontent variable="a_str_return">

<cfswitch expression="#arguments.action#">
	<cfcase value="610">
		
		<!--- replace stars with ***** --->
		<cfloop from="0" to="#arguments.param#" index="ii" step="20">
			<cfset a_str_text = a_str_text & '* ' />
		</cfloop>
		
		<cfset arguments.param = a_str_text />
		
	</cfcase>
</cfswitch>

<cfset a_replace = [ '<bb>' & arguments.objecttitle & '</bb>', arguments.param ] />

<cfset a_str_date = '<a class="addinfotext" href="/status/#arguments.entrykey#" target="_blank">#LSDateFormat( arguments.dt_created, 'mmm dd')#</a>' />

<cfif NOT StructKeyExists( request, 'tmp_a_int_smart_date_diff' )>
	<cfset request.tmp_a_int_smart_date_diff = -1 />
</cfif>

<cfset a_bol_display_date = (request.tmp_a_int_smart_date_diff NEQ a_dt_diff) />

<cfoutput>
	
<cfif ListFindNoCase( arguments.options, 'smartdate' )>

	<cfset a_str_date = '' />

	<cfif a_bol_display_date>
		<div class="addinfotext" style="padding-bottom:8px">
			
			<cfswitch expression="#a_dt_diff#">
				<cfcase value="3">
					#application.udf.GetLangValSec( 'cm_ph_news_feed_last_few_days' )#
				</cfcase>
				<cfcase value="21">
					#application.udf.GetLangValSec( 'cm_ph_news_feed_last_few_weeks' )#
				</cfcase>
				<cfcase value="99">
					#application.udf.GetLangValSec( 'cm_ph_news_feed_last_long_time_ago' )#
				</cfcase>
			</cfswitch>
	
		</div>
		
		<cfset request.tmp_a_int_smart_date_diff = a_dt_diff />
	</cfif>
</cfif>

<!--- create DIV --->
<cfif ListFindNoCase( arguments.options, 'small' ) IS 1>
	<div style="margin-bottom:10px;line-height:200%;text-indent: -28px; padding-left: 28px;">
<cfelse>
	<div class="div_container_small lightbg" style="margin-bottom:20px;line-height:200%">
</cfif>

<cfif ListFindNoCase( arguments.options, 'nouserimage' ) IS 0>
	<a href="/user/#UrlEncodedFormat( arguments.createdbyusername )#" title="#htmleditformat( arguments.createdbyusername )#" class="add_as_tab"><img src="#arguments.pic#" width="40" height="40" style="border:0px;float:left;padding-right:10px;padding-bottom:10px" /></a>
</cfif>
		
<cfset a_str_img_name = getImageNameForLogEvent( arguments.action ) />

#application.udf.si_img( a_str_img_name )#
<cfif arguments.action IS 802>
	<!--- display username of user becoming friend with this one --->
	<cfif arguments.userkey NEQ arguments.affecteduserkey AND ListFindNoCase( arguments.options, 'small' ) IS 1>
		
		<!--- #application.udf.WriteDefaultUserNameProfileLink( arguments.createdbyusername )# --->
	</cfif>
</cfif>

<cfif ListFindNoCase( arguments.options, 'small' ) IS 1>
	#a_str_date#
</cfif>

<cfif ListFindNoCase( arguments.options, 'small' ) IS 1>
	#application.udf.WriteDefaultUserNameProfileLink( arguments.createdbyusername )#
</cfif>

<cfswitch expression="#arguments.action#">
	<cfcase value="100,110">
		<a href="#getPublicEventLinkOfLogItem( action = arguments.action, objecttitle = arguments.objecttitle, linked_objectkey = arguments.linked_objectkey )#" class="add_as_tab" title="#htmleditformat( arguments.objecttitle )#">
	</cfcase>
	<cfcase value="610,600,500">
		<a href="#getPublicEventLinkOfLogItem( action = arguments.action, objecttitle = arguments.objecttitle, linked_objectkey = arguments.linked_objectkey )#" onclick="DoRequest( 'lookupitem', { 'artist' : '#Trim( ListFirst( arguments.objecttitle, '-' ) )#', 'name' : '#JsStringFormat( Trim( ListLast( arguments.objecttitle, '-' ) ))#'});return false;">
	</cfcase>
	<cfcase value="601">
		<!--- comment on playlist --->
		<a href="#getPublicEventLinkOfLogItem( action = arguments.action, objecttitle = arguments.objecttitle, linked_objectkey = arguments.linked_objectkey )#"  class="add_as_tab" title="#htmleditformat( arguments.objecttitle )#">		
	</cfcase>
	<cfcase value="620">
		<a href="#getPublicEventLinkOfLogItem( action = arguments.action, objecttitle = arguments.objecttitle, linked_objectkey = arguments.linked_objectkey )#" class="add_as_tab" title="#htmleditformat( arguments.objecttitle )#">
	</cfcase>
	<cfcase value="802">
		<a href="#getPublicEventLinkOfLogItem( action = arguments.action, objecttitle = arguments.objecttitle, linked_objectkey = arguments.linked_objectkey )#" class="add_as_tab" title="#htmleditformat( arguments.objecttitle )#">
	</cfcase>
</cfswitch>

<span <cfif ListFindNoCase( arguments.options, 'small' ) IS 0>style="font-size:13px"</cfif>>#application.udf.GetLangValSec( 'log_action_' & arguments.action, a_replace )#

<cfif arguments.action IS 600 OR arguments.action IS 601>
	"#htmleditformat( arguments.param )#"
</cfif></span>
</a>

<cfif arguments.action IS 500 AND ListFindNoCase( arguments.options, 'small' ) IS 0>
	[#application.udf.WriteDefaultUserNameProfileLink( arguments.param )#]
</cfif>

<cfif ListFindNoCase( arguments.options, 'small' ) IS 0>
	<br />
	<img src="http://cdn.tunesBag.com/images/space1x1.png" class="si_img" />
	<a href="/user/#UrlEncodedFormat( arguments.createdbyusername )#" title="#htmleditformat( arguments.createdbyusername )#" class="add_as_tab">#arguments.createdbyusername#</a>
	#a_str_date#
</cfif>

</div>
</cfoutput>
</cfsavecontent>