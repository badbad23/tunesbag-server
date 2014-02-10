
<cfset QueryAddColumn( q_select_log_items, 'content', ArrayNew(1) ) />
<cfset QueryAddColumn( q_select_log_items, 'content_link', ArrayNew(1) ) />

<cfloop query="q_select_log_items">
	<cfset a_str_link = 'http://www.tunesBag.com/' & a_cmp_log.getPublicEventLinkOfLogItem( action = q_select_log_items.action,
																objecttitle = q_select_log_items.objecttitle,
																linked_objectkey = q_select_log_items.linked_objectkey ) />
	
	<cfswitch expression="#q_select_log_items.action#">
	<cfcase value="610">
		
		<cfset a_str_text = '' />
		
		<!--- replace stars with ***** --->
		<cfloop from="0" to="#q_select_log_items.param#" index="ii" step="20">
			<cfset a_str_text = a_str_text & '* ' />
		</cfloop>
			
		<cfset QuerySetCell( q_select_log_items, 'param', a_str_text, q_select_log_items.currentrow ) />
			
		</cfcase>
	</cfswitch>
	
	
	<cfset a_replace = [ q_select_log_items.objecttitle, q_select_log_items.param ] />
	
	<cfset a_str_text = q_select_log_items.createdbyusername & ' ' & application.udf.GetLangValSec( 'log_action_' & q_select_log_items.action, a_replace ) />
	
	<cfset QuerySetCell( q_select_log_items, 'content', a_str_text, q_select_log_items.currentrow ) />
	<cfset QuerySetCell( q_select_log_items, 'content_link', a_str_link, q_select_log_items.currentrow ) />		
</cfloop>