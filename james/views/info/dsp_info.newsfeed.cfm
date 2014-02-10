<!---

	newsfeed

--->

<cfinclude template="/common/scripts.cfm">

<cfset q_select_log_items = event.getarg( 'q_select_log_items' ) />

<cfsavecontent variable="request.content.final">
<div class="headlinebox">
	<p class="title"><cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_news_feed' ), '' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetCurrentSecurityContext().username#</cfoutput></p>
</div>

<div class="div_container">

<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_news_feed' ), '' )#</cfoutput>
<div class="div_container">

<cfoutput>
<a href="/rss/user/#application.udf.GetCurrentSecurityContext().username#/feed/?key=123" target="_blank">#application.udf.si_img( 'feed' )# #application.udf.GetLangValSec( 'cm_wd_btn_subscribe_rss' )#</a>
</cfoutput>

<!--- <cfdump var="#q_select_log_items#"> --->
<br /><br />
<cfoutput>
#application.udf.GetLangValSec( 'cm_wd_filter' )#: 

<input type="checkbox" value="600" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_wd_playlists' )#
<input type="checkbox" value="620" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_wd_artists' )#
<input type="checkbox" value="600" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_Wd_comments' )#
<input type="checkbox" value="601" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_wd_playlists' )#
<input type="checkbox" value="610" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_wd_ratings' )#
<input type="checkbox" value="610" disabled="true" checked /> #application.udf.GetLangValSec( 'cm_wd_friends' )#
</cfoutput>
<br /><br />

<cfoutput query="q_select_log_items">
	
<cfset a_str_content = getproperty( 'beanFactory' ).getBean( 'LogComponent' ).FormatSingleLogItem( entrykey =  q_select_log_items.entrykey,
				dt_created = q_select_log_items.dt_created,
				userkey = q_select_log_items.createdbyuserkey,
				affecteduserkey = q_select_log_items.affecteduserkey,
				action = q_select_log_items.action,
				param = q_select_log_items.param,
				objecttitle = q_select_log_items.objecttitle,
				pic = q_select_log_items.pic,
				linked_objectkey = q_select_log_items.linked_objectkey,
				createdbyusername = q_select_log_items.createdbyusername,
									options =  '' ) />
				
#a_str_content#
<div class="clear"></div>
</cfoutput>

<!--- log_action_100=Created/Modified playlist {1}
log_action_600=Comment on {1}
log_action_610={3} {1} rated with {2}
log_action_620=Became a fan of {1} --->

</div>
</div>
</cfsavecontent>