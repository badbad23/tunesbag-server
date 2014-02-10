
<!--- div with actions for recommended item --->
<div id="id_menu_recommendations" class="lightbg b_all div_container_small" style="position: absolute; display: none;">
	<cfoutput>

	<ul>
		<li>
			<a href="##" onclick="CallItemPlayer( $('##id_menu_recommendations').data( 'mediaitemkey' ), '', 4 );return false">#application.udf.si_img( 'control_play_blue' )# #application.udf.GetLangValSec( 'cm_wd_play' )#</a>
		</li>
		<li>
			<a href="##">#application.udf.si_img( 'table_row_insert' )# #application.udf.GetLangValSec( 'cm_wd_enqueue' )#</a>
		</li>

		<li>
			<a href="##">#application.udf.si_img( 'page_white_add' )# #application.udf.GetLangValSec( 'cm_wd_playlist' )#</a>
		</li>		
	</ul>	
	</cfoutput>
</div>

<!--- div holding the default and the preview media player --->
<div id="id_default_mplayer_container">
	<div id="id_default_mediaplayer"></div>
	<div id="id_preview_mediaplayer"></div>
</div>

<!--- rating --->
<div id="id_popup_rating" class="b_all popupmenu" style="display:none">
	<ul>
		<cfloop from="1" to="5" index="ii">		
		<li onclick="var entrykey = $('#id_popup_rating').data( 'entrykey' );SetRating(0, entrykey, <cfoutput>#( ii * 2 * 10 )#</cfoutput>, '')" style="cursor:pointer">

			<cfloop from="1" to="#ii#" index="rating">
				<img src="http://cdn.tunesBag.com/images/si/rating.png" alt="Rating" />
			</cfloop>
			
			<cfloop from="#(ii + 1)#" to="5" index="rating">			
				<img src="http://cdn.tunesBag.com/images/si/rating-none.png" alt="Rating" />
			</cfloop>

		</li>
		</cfloop>
	</ul>
</div>

<!--- user popup menu on top --->
<div class="b_all popupmenu" id="id_popup_user" style="display:none">
<cfoutput>
<ul>
	<li>
		<a title="#application.udf.GetLangValSec( 'nav_preferences' )#" href="/james/?event=user.preferences&amp;TB_iframe=true&amp;height=500&amp;width=840" class="thickbox">#application.udf.GetLangValSec( 'nav_preferences' )#</a>
	</li>
	<!--- <li>
		<a href="##/user/#application.udf.GetCurrentSecurityContext().username#">#application.udf.GetLangValSec( 'nav_profile' )#</a>
	</li>	 --->		
	<!--- <li>
		<a href="##tb:friends" title="#application.udf.GetLangValSec( 'cm_wd_friends' )#">#application.udf.GetLangValSec( 'nav_friends' )#</a>
	</li> --->
	<li>
		<a href="##tb:apps" title="#application.udf.GetLangValSec( 'cm_wd_applications_short' )#">#application.udf.GetLangValSec( 'cm_wd_applications_short' )#</a>
	</li>
	<!--- <li>
		<a href="/james/?event=messages.overview&amp;height=420&amp;width=840" title="#application.udf.GetLangValSec( 'cm_wd_messages' )#" class="thickbox">#application.udf.GetLangValSec( 'cm_wd_messages' )# (#event.getArg( 'a_int_unread_messages', 0 )#)</a>
	</li> --->
	<!--- <li>
		<a href="##/james/?event=info.newsfeed" title="#application.udf.GetLangValSec( 'cm_ph_news_feed' )#">#application.udf.GetLangValSec( 'cm_ph_news_feed' )#</a>
	</li> --->
	<li>
		<a href="##/james/?event=info.charts" title="#application.udf.GetLangValSec( 'cm_wd_charts' )#">#application.udf.GetLangValSec( 'cm_wd_charts' )#</a>		
	</li>
	<li>
		<a href="/james/?event=user.logout"><span>#application.udf.GetLangValSec( 'nav_logout' )#</span></a>
	</li>
</ul>
</cfoutput>
</div>

<!--- // item properties // --->
<div class="b_all popupmenu" id="id_item_properties_mini" style="display:none">
	<ul>
		<li class="item_property_add_to_plist bb">
			<a href="#" class="noclose" onclick="var entrykey = $('#id_item_properties_mini').data( 'entrykey');$('.popupmenu').hide();DoRequest( 'item.addtoplist', { 'entrykey' : entrykey } );return false;return false;return false"><cfoutput>#application.udf.si_img( 'table_add' )# #application.udf.GetLangValSec( 'lib_ph_edit_add_to_playlist' )#</cfoutput></a>
		</li>
		<li>
			<a title="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_share' )#</cfoutput>" href="#" onclick="var entrykey = $('#id_item_properties_mini').data( 'entrykey');CallShareDlg( this, 1, entrykey );return false;"><cfoutput>#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'cm_wd_share' )#</cfoutput></a>
		</li>		
		<li>
			<a title="<cfoutput>#application.udf.GetLangValSec( 'cm_ph_show_information' )#</cfoutput>" href="#" onclick="var entrykey = $('#id_item_properties_mini').data( 'entrykey');DoRequest( 'item.info' , { 'entrykey' : entrykey });return false;"><cfoutput>#application.udf.si_img( 'information' )# #application.udf.GetLangValSec( 'cm_wd_information' )#</cfoutput></a>
		</li>		
		<li>
			<a title="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_action_download_track' )#</cfoutput>" href="#" onclick="var entrykey = $('#id_item_properties_mini').data( 'entrykey');DoRequest( 'item.download' , { 'entrykey' : entrykey });return false;"><cfoutput>#application.udf.si_img( 'arrow_down' )# #application.udf.GetLangValSec( 'lib_ph_action_download_track' )#</cfoutput></a>
		</li>		
		<li class="bb">
			<a title="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_action_delete_from_library' )#</cfoutput>" href="#" onclick="var entrykey = $('#id_item_properties_mini').data( 'entrykey');DoRequest( 'item.delete' , { 'entrykey' : entrykey });return false;"><cfoutput>#application.udf.si_img( 'delete' )# #application.udf.GetLangValSec( 'lib_ph_action_delete_from_library' )#</cfoutput></a>
		</li>
	</ul>

</div>
