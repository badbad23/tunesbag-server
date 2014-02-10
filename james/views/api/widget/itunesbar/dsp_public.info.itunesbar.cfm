<!--- test --->

<cfinclude template="/common/scripts.cfm">

<cfset a_struct_social_infos = event.getArg( 'a_struct_social_infos' ) />
<cfset a_search_track_result = event.getArg( 'a_search_track_result' ) />
<cfset q_select_search_items = a_search_track_result.q_select_items />

<cfset a_common_artist_info = event.getArg( 'a_common_artist_info' ) />
<cfset Q_SELECT_PLISTS_WITH_THIS_TRACK = a_struct_social_infos.Q_SELECT_PLISTS_WITH_THIS_TRACK />

<cfsavecontent variable="request.content.final">

<!--- <h4>Please log in</h4> --->
<div class="lightbg" style="position:absolute;bottom:0px;left:0px;width:100%;text-align:center">
	<a href="/rd/start/" target="_blank"><img src="http://cdn.tunesBag.com/images/tunesbag-logo-140px.png" style="padding:8px;border:0px" /></a>
</div>

<div style="background-image:URL(http://cdn.tunesBag.com/images/skins/default/bg_top_header.png);">
	
<table>
	<tr>
<cfif a_common_artist_info.result>
		<td>
		
	<cfoutput>
	<img width="50" src="/res/images/artists/#htmleditformat( event.getArg( 'artist' ) )#.jpg" style="float:left;padding:8px" />
	</cfoutput>

		</td>
		</cfif>
		<td>
		<h2 style="color:white"><cfoutput>#event.getArg( 'name' )#</h3>
	<h4 style="color:##EEEEEE">#event.getArg( 'artist' )#</cfoutput></h4>
		</td>
	</tr>
</table>
		
	<div class="clear"></div>
</div>




<cfif q_select_search_items.recordcount IS 0>
<div class="status">
	Want to access this track from anywhere?
	<br />
	<a href="tunesbag://copytracktolibrary/" style="font-weight:bold">Copy this track now to your tunesBag</a>
</div>
</cfif>

<cfif Q_SELECT_PLISTS_WITH_THIS_TRACK.recordcount GT 0>

<div class="widget_itunesbar_header">
<cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlists' )#</cfoutput>
</div>

<table class="table_overview">
<cfoutput query="Q_SELECT_PLISTS_WITH_THIS_TRACK">
	<tr><td>
<a href="/playlist/#Q_SELECT_PLISTS_WITH_THIS_TRACK.entrykey#" target="_blank" style="font-weight:bold">#Q_SELECT_PLISTS_WITH_THIS_TRACK.name#</a>
<br />
#htmleditformat( Q_SELECT_PLISTS_WITH_THIS_TRACK.description )#
<!---  --->
</td>
<td>

#Q_SELECT_PLISTS_WITH_THIS_TRACK.username#
</td>
	</tr>
</cfoutput>
</table>

</cfif>

<div class="widget_itunesbar_header">
<cfoutput>#application.udf.GetLangValSec( 'cm_wd_fans' )#</cfoutput>
</div>
<div style="padding:8px">
	<img src="http://profile.ak.facebook.com/v224/1404/79/s500410453_2859.jpg" width="40" height="40" />
	<img src="http://profile.ak.facebook.com/profile5/1117/97/s508336782_5323.jpg" width="40" height="40" />
	<img src="http://profile.ak.facebook.com/v225/573/14/s523658434_9226.jpg" width="40" height="40" />
</div>

<div class="widget_itunesbar_header">
<cfoutput>#application.udf.GetLangValSec( 'cm_wd_action' )#</cfoutput>
</div>

<div style="padding:8px">
	<a href="##"><cfoutput>#application.udf.si_img( 'comment' )# #application.udf.GetLangValSec( 'lib_ph_add_comment_long')#</cfoutput></a>
	<br />
	<a href="##"><cfoutput>#application.udf.si_img( 'star' )# #application.udf.GetLangValSec( 'cm_ph_recommend_to_friend' )#</cfoutput></a>
</div>

</cfsavecontent>