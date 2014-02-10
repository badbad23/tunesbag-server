<!--- //

	Module:		User preferences
	Description: 
	
// --->

<cfprocessingdirective pageencoding="utf-8">

<cfinclude template="/common/scripts.cfm">

<cfset a_str_facebook_uid = event.getArg( 'a_struct_userdata' ).getfb_uid() />
<cfset a_str_language = event.getArg( 'a_struct_userdata' ).getlang_id() />
<cfset a_str_picture = event.getArg( 'a_struct_userdata' ).getpic() />
<cfset a_userdata = event.getArg( 'a_struct_userdata' ) />
<cfset a_photo_upload_result = event.getArg( 'a_struct_photo_upload_result' ) />
<cfset a_background_upload_result = event.getArg( 'a_struct_background_upload_result' ) />

<!--- external IDs --->
<cfset stExtDropBox = event.getArg( 'external_dropbox' ) />
<cfset a_struct_external_lastfm = event.getArg( 'external_lastfm' ) />
<cfset a_struct_external_blogger = event.getArg( 'external_blogger' ) />
<cfset a_struct_external_facebook = event.getArg( 'external_facebook' ) />

<cfset iEnableArtistBGRotation = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey, name = 'ui.artistbgrot', defaultvalue = 1 ) />

<!--- design --->
<cfset a_str_design_skin = event.getArg( 'pref_skin', '' ) />

<!--- get result --->
<cfset a_bol_properties_stored = event.getArg( 'stored', false ) />

<!--- default web streaming bitrate --->
<cfset a_int_web_streaming_quality = event.getArg( 'web_streaming_quality', '128' ) />

<cfset iStreamingQualitySqueezebox = event.getArg( 'sqbn_streaming_quality', '128' ) />

<!--- get list of countries --->
<cfset q_select_countries = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetCountryList() />

<cfsavecontent variable="request.content.final">

<div class="div_container" id="id_div_preferences_container">

<div class="confirmation" style="display:none" id="id_status_processing">
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_loading_please_wait' )#</cfoutput>
	<br /><br />
	<img src="http://cdn.tunesBag.com/images/loadingAnimation.gif" />
</div>


<!--- has been stored? --->
<cfif a_bol_properties_stored>
	
	<div class="confirmation" id="id_confirmation_data_stored">
		<cfoutput>#application.udf.GetLangValSec( 'cm_ph_data_has_been_stored' )#</cfoutput>
		<br /><br />
		<a target="_top" href="/rd/start/" style="font-weight:bold;"><cfoutput>#application.udf.GetLangValSec( 'pref_ph_click_here_to_reload_service' )#</cfoutput></a>
	</div>
	
	<cfif IsStruct( a_photo_upload_result ) AND NOT a_photo_upload_result.result>
		<cfoutput>#application.udf.WriteCommonErrorMessage( a_photo_upload_result.error )#</cfoutput>
	</cfif>
	
	<cfif IsStruct( a_background_upload_result ) AND NOT a_background_upload_result.result>
		<cfoutput>#application.udf.WriteCommonErrorMessage( a_background_upload_result.error )#</cfoutput>
	</cfif>		
	
</cfif>


<!--- tabs --->
<div id="id_tabs_container_preferences" class="bb">
	<ul>
		<li><a href="#tab_customize"><span><cfoutput>#application.udf.GetLangValSec( 'pref_wd_customize' )#</cfoutput></span></a></li>
		<li><a href="#tab_design"><span><cfoutput>#application.udf.GetLangValSec( 'pref_wd_design' )#</cfoutput></span></a></li>
		<li><a href="#tab_integrated_services"><span><cfoutput>#application.udf.GetLangValSec( 'cm_ph_integrated_services' )#</cfoutput></span></a></li>
		<li><a href="#tab_widgets"><span><cfoutput>#application.udf.GetLangValSec( 'cm_wd_widgets' )#</cfoutput></span></a></li>
		<li><a href="#tab_personal_data"><span><cfoutput>#application.udf.GetLangValSec( 'pref_ph_personal_data' )#</cfoutput></span></a></li>
		<li><a href="#tab_privacy"><span><cfoutput>#application.udf.GetLangValSec( 'cm_wd_privacy' )#/#application.udf.GetLangValSec( 'cm_wd_security' )#</cfoutput></span></a></li>		
		<!--- <li><a href="#tab_api"><span>API</span></a></li> --->
		<!--- <li><a href="#tab_home2"><span><cfoutput>#application.udf.GetLangValSec( 'cm_wd_mobile' )#</cfoutput></span></a></li>		 --->
	</ul>
</div>

<!--- customize --->
<form action="/james/?event=user.preferences&amp;stored=true" method="post" enctype="multipart/form-data" onsubmit="$('#id_confirmation_data_stored').hide();$('#id_status_processing').fadeIn();">
<div id="tab_customize" class="div_container bb bl br">
	<div class="div_container">
	<table class="table_details table_edit">
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput>
			</td>
			<td>
				<b><cfoutput>#htmleditformat( a_userdata.getusername() )#</cfoutput></b>
			</td>
		</tr>	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_photo' )#</cfoutput>
			</td>
			<td>
			
				<cfif Len(a_str_picture) GT 0>
					<img src="<cfoutput>#application.udf.getUserImageLink( application.udf.GetCurrentSecurityContext().username, 75 )#?#CreateUUID()#</cfoutput>" border="0" style="width:75px;vertical-align:middle" />
					
				</cfif>
				&nbsp;&nbsp;
				<a href="##" onclick="$(this).hide();$('#id_photo_upload').fadeIn();return false"><cfoutput>#application.udf.si_img( 'pencil' )# #application.udf.GetLangValSec( 'cm_wd_edit' )#</cfoutput></a>
				
				<div style="display:none" id="id_photo_upload">
					<input type="file" name="userphotoupload" value="" />
					<br />
					<cfoutput>#application.udf.GetLangValSec( 'pref_ph_photo_user_hints' )#</cfoutput>
				</div>
				
			</td>
		</tr>
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_ph_about_me' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="about_me" value="<cfoutput>#htmleditformat( a_userdata.getabout_me() )#</cfoutput>" />
			</td>
		</tr>	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_homepage' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="homepage" value="<cfoutput>#htmleditformat( a_userdata.gethomepage() )#</cfoutput>" />
			</td>
		</tr>	

		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_ph_rss_newsfeed' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="rsslink" value="<cfoutput>#htmleditformat( a_userdata.getrsslink() )#</cfoutput>" />
			</td>
		</tr>				
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_language' )#</cfoutput>
			</td>
			<td>
				<select name="lang_id">
					<option value="en" <cfif a_userdata.getlang_id() IS 'en'>selected</cfif>>English (EN)</option>
					<option value="de" <cfif a_userdata.getlang_id() IS 'de'>selected</cfif>>German (DE)</option>
					<option value="es" <cfif a_userdata.getlang_id() IS 'es'>selected</cfif>>Español (ES)</option>
					<option value="fr" <cfif a_userdata.getlang_id() IS 'fr'>selected</cfif>>Français (FR)</option>
					<option value="it" <cfif a_userdata.getlang_id() IS 'it'>selected</cfif>>Italiano (IT)</option>
					<option value="tr" <cfif a_userdata.getlang_id() IS 'tr'>selected</cfif>>Türkçe (TK)</option>
					<option value="et" <cfif a_userdata.getlang_id() IS 'et'>selected</cfif>>Eesti keel (ET)</option>
					<option value="ru" <cfif a_userdata.getlang_id() IS 'ru'>selected</cfif>>русский язык (RU)</option>
					<option value="zh_cn" <cfif a_userdata.getlang_id() IS 'zh_cn'>selected</cfif>>Simplified Chinese (ZH_CN)</option>
					<option value="nl" <cfif a_userdata.getlang_id() IS 'nl'>selected</cfif>>Dutch (NL)</option>
					<option value="zh_tw" <cfif a_userdata.getlang_id() IS 'zh_tw'>selected="true"</cfif>>Traditional Chinese (TW)</option>
					<option value="pl" <cfif a_userdata.getlang_id() IS 'pl'>selected="true"</cfif>>język polski (PL)</option>
					<option value="pt_br" <cfif a_userdata.getlang_id() IS 'pt_br'>selected="true"</cfif>>Português  (PT_BR)</option>
				</select>
			</td>
		</tr>
		<tr style="display:none">
			<td class="field_name">
				Streaming bitrate
			</td>
			<td>
				<select name="streaming_bitrate" <cfif application.udf.GetCurrentSecurityContext().accounttype IS 0>disabled="true"</cfif>>

					<option value="96" <cfif a_int_web_streaming_quality IS 96>selected="true"</cfif>>96 kb/sec</option>
					<option value="128" <cfif a_int_web_streaming_quality IS 128>selected="true"</cfif>>128 kb/sec</option>
					<option value="192" <cfif a_int_web_streaming_quality IS 192>selected="true"</cfif>>192 kb/sec</option>
					<option value="320" <cfif a_int_web_streaming_quality IS 320>selected="true"</cfif>>320 kb/sec</option>
					
				</select>
				
				<cfif application.udf.GetCurrentSecurityContext().accounttype IS 0>
					<br />
					<cfoutput>
					<a href="/rd/upgrade/" target="_blank">#application.udf.GetLangValSec( 'cm_ph_upgrade_available_now' )#</a>
					</cfoutput>
				</cfif>
			</td>
		</tr>
		<tr>
			<td class="field_name">
				Streaming Quality Squeezebox
			</td>
			<td>
				<select name="streaming_bitrate_sqbn">
					<option value="128" <cfif iStreamingQualitySqueezebox IS 128>selected="true"</cfif>>128 kb/sec</option>
					<option value="192" <cfif iStreamingQualitySqueezebox IS 192>selected="true"</cfif>>192 kb/sec</option>
					<option value="320" <cfif iStreamingQualitySqueezebox IS 320>selected="true"</cfif>>320 kb/sec</option>
				</select>
				&nbsp;&nbsp;
				<cfoutput><a href="/squeezenetwork/" target="_blank">#application.udf.GetLangValSec( 'cm_wd_information' )#</a></cfoutput>
			</td>
		</tr>
		<tr>
			<td class="field_name"></td>
			<td>
				<input type="submit" class="btn" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" />
			</td>
		</tr>		
	</table>
	
	</div>
</div>

<!--- widgets --->
<div id="tab_widgets" class="div_container bb bl br">
	
	<table class="table_details table_edit tbl_td_top">
		<!--- <tr>
			<td class="field_name bb">
				Popup Player
			</td>
			<td class="bb">
				<cfoutput>#application.udf.GetLangValSec( 'wgt_ph_drag_popuplink' )#</cfoutput>
				<br /><br />
				<cfoutput>
				<span class="lightbg b_all" style="width:auto;padding:4px">
				<a href="javascript:window.open('http://#cgi.SERVER_NAME#:#cgi.server_port#/james/?event=play.miniplayer&autologin_username=#UrlEncodedFormat( a_userdata.getUsername() )#&autologin_password=#Hash( a_userdata.getPwd() )#','tunesbagminiplayer','toolbar=0,resizable=0,status=1,width=450,height=430');void(0);">tunesBag Player</a>
				</span>
				</cfoutput>
			</td>
		</tr>	 --->
		<tr>
			<td class="field_name bb">
				<cfoutput>#application.udf.GetLangValSec( 'wget_ph_recently_played' )#</cfoutput>
			</td>
			<td class="bb">
				<cfoutput>
				#application.udf.GetLangValSec( 'wgt_ph_recently_played_description' )#
				<br /><br />
				
<cfsavecontent variable="a_str_js"><div style="width:auto">
<script charset="utf-8" src="http://#cgi.server_name#:#cgi.server_port#/api/widgets/simple/?username=#application.udf.GetCurrentSecurityContext().username#&amp;bgcolor=white" type="text/javascript"></script>
<div style="clear:both"></div>
<a href="http://www.tunesBag.com/?ref=widget">tunesBag - Online Music &amp; Playlists</a>
</div>
</cfsavecontent>
				
				<textarea rows="4" cols="70" style="width:700px"><!-- tunesBag.com recently played -->#htmleditformat( a_str_js )#</textarea>
				</cfoutput>
				<br />
				<a href="#" onclick="$('#id_recently_played_example').slideDown();return false" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'wget_ph_see_an_example' )#</cfoutput></a>
				<div id="id_recently_played_example" style="display:none">
				<cfoutput>#a_str_js#</cfoutput>
				</div>
			</td>
		</tr>
		<tr>
			<td class="field_name bb">
				<cfoutput>#application.udf.GetLangValSec( 'wget_ph_email_signature' )#</cfoutput>	
			</td>
			<td class="bb">
					<cfoutput>
				#application.udf.GetLangValSec( 'wget_ph_email_signature_description' )#
				<br />
				
<cfsavecontent variable="a_str_js"><div style="margin:0px;padding:0px">
<a href="/user/#application.udf.GetCurrentSecurityContext().username#/?ref=widget" target="_blank"><img src="http://#cgi.server_name#:#cgi.server_port#/api/widgets/lastplayedimage/#application.udf.GetCurrentSecurityContext().username#/" width="500" height="45" border="0" /></a>
</div>
</cfsavecontent>
				
				<textarea rows="4" cols="70" style="width:700px;display:none" id="id_widget_signature">#htmleditformat( a_str_js )#</textarea>
				</cfoutput>
				<br />
				<a href="##" onclick="$('#id_widget_signature').fadeIn();return false"><cfoutput>#application.udf.GetLangValSec( 'wget_ph_see_code' )#</cfoutput></a>
				<cfoutput>#application.udf.GetLangValSec( 'wget_ph_see_an_example' )#</cfoutput>: <cfoutput>#a_str_js#</cfoutput>
				
			</td>
		</tr>
		<!--- <tr>
			<td class="field_name">
				Add to Bag - Button
			</td>
			<td>
				<cfsavecontent variable="a_str_js"><!-- edit the tunesbag_add2bag_url variable to reflect the location of your audio file -->
<a href="#" onclick="tunesbag_add2bag_url = 'http://www.soundpark.at/mp3/2007-12/77bastian77_instr_astorybyyou_160606.mp3'; add2bag(this);return false;" target="_blank"><img style="vertical-align:middle;border:0px" src="/res/images/widgets/add2bag/button1-share.png" width="82" height="16" alt="Add to your tunesBag" /></a>

<!-- add this script once to your page -->
<script type="text/javascript" src="http://<cfoutput>#cgi.server_name#:#cgi.server_port#</cfoutput>/api/widgets/add2bag/add2bag.cfm?v=1"></script></cfsavecontent>
	
	
				<cfoutput>
				<textarea rows="4" cols="70" style="width:700px;display:none" id="id_widget_code_bag">#htmleditformat( a_str_js )#</textarea>
				</cfoutput>
				<br />
				
				<a href="##" onclick="$('#id_widget_code_bag').fadeIn();return false"><cfoutput>#application.udf.GetLangValSec( 'wget_ph_see_code' )#</cfoutput></a>
				
				<cfoutput>#application.udf.GetLangValSec( 'wget_ph_see_an_example' )#</cfoutput>: <cfoutput>#a_str_js#</cfoutput>
				
			</td> --->
		</tr>
	</table>
	
</div>


<!--- design --->
<div id="tab_design" class="div_container bb bl br">

	<table class="table_details table_edit">
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'pref_wd_skin' )#</cfoutput>
			</td>
			<td>
				<select name="skin">
					<option value="">Default</option>
					<option <cfif a_str_design_skin IS 'minimal'>selected</cfif> value="minimal">Minimal</option>
					<!--- <option <cfif a_str_design_skin IS 'dark'>selected</cfif> value="dark">Dark</option> --->
				</select>
			</td>
		</tr>	
		<tr>
			<td class="field_name">
				
			</td>
			<td>	
				<input type="checkbox" value="true" name="design_reset_all" style="width:auto" /> 
				
				<cfoutput>#application.udf.GetLangValSec( 'pref_ph_design_reset_default' )#</cfoutput>
				
			</td>
		</tr>
		<tr style="background-image:URL(<cfoutput>#a_userdata.getbgimage()#?#CreateUUID()#</cfoutput>)">
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'pref_ph_bg_image' )#</cfoutput>
			</td>
			<td>
				<input type="file" name="design_bg_image" value="" id="design_bg_image" />
				<br />
				<cfoutput>#application.udf.GetLangValSec( 'pref_ph_background_image_user_hints' )#</cfoutput>
			</td>
		</tr>		
		<tr>
			<td class="field_name" style="float:right">
				
			</td>
			<td>
				<input type="checkbox" value="1" name="rotateArtistBGImage" <cfif iEnableArtistBGRotation IS 1>checked="true"</cfif> />
				<cfoutput>#application.udf.GetLangValSec( 'pref_ph_rotate_images_bg' )#</cfoutput>
			</td>
		</tr>		
		<tr>
			<td class="field_name"></td>
			<td>
				<input type="submit" class="btn" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" />
			</td>
		</tr>
	</table>

</div>

<!--- API --->
<!--- <div id="tab_api" style="display:none" class="div_container bb bl br">

<div class="div_container">
<h4>Join the tunesBag Developer area</h4>
<a href="/james/?event=">
</div>

</div> --->

<!--- <script type="text/javascript">
	jQuery(function($) {
   		
   		$("#design_bg_color").attachColorPicker();
   		$("#design_text_color").attachColorPicker();
   		$("#design_link_color").attachColorPicker();
   		$("#design_content_bg_color").attachColorPicker();
   		$("#design_content_bg_sidebar").attachColorPicker();
   	});
</script> --->


<!--- perosnal data --->

<div id="tab_personal_data" class="div_container bb bl br">

	<div class="div_container">
	
	<table class="table_details table_edit">
	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_firstname' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="firstname" value="<cfoutput>#htmleditformat( a_userdata.getfirstname() )#</cfoutput>" />
			</td>
		</tr>
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_surname' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="surname" value="<cfoutput>#htmleditformat( a_userdata.getsurname() )#</cfoutput>" />
			</td>
		</tr>	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_email' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="email" value="<cfoutput>#htmleditformat( a_userdata.getemail() )#</cfoutput>" />
			</td>
		</tr>	
	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_zipcode' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="zipcode" value="<cfoutput>#htmleditformat( a_userdata.getzipcode() )#</cfoutput>" />
			</td>
		</tr>		
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_city' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="city" value="<cfoutput>#htmleditformat( a_userdata.getcity() )#</cfoutput>" />
			</td>
		</tr>	
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_country' )#</cfoutput>
			</td>
			<td>
				
				<cfset a_str_cur_country = a_userdata.getcountryisocode() />
	
				<select name="countryisocode">
					<cfoutput query="q_select_countries">
						<option <cfif CompareNoCase( a_str_cur_country, q_select_countries.iso ) IS 0>selected</cfif> value="#q_select_countries.iso#">#htmleditformat( q_select_countries.printable_name )#</option>
					</cfoutput>
				</select>
	
			</td>
		</tr>		
		<tr>
			<td class="field_name">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_cellphone' )#</cfoutput>
			</td>
			<td>
				<input type="text" name="cellphone_nr" value="<cfoutput>#htmleditformat( a_userdata.getcellphone_nr() )#</cfoutput>" />
				<br />
				<span style="color:gray"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_sample' )#</cfoutput>: +43 664 1234567</span>
			</td>
		</tr>			
		<tr style="display:none">
			<td class="field_name">
				
			</td>
			<td>
				<input type="checkbox" value="1" name="public_profile" checked="true" style="width:auto" />
				
				<cfoutput>#application.udf.GetLangValSec( 'pref_public_profile' )#</cfoutput>
			</td>
		</tr>
		<!--- <tr>
			<td class="field_name">
				Google Gears
			</td>
			<td>
				Musikdateien lokal speichern
			</td>
		</tr> --->
		<tr>
			<td class="field_name"></td>
			<td>
				<input type="submit" class="btn" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" />
			</td>
		</tr>
	</table>

	
	</div>
</div>

<div id="tab_integrated_services" class="div_container bb bl br">
	
<div class="div_container_small">
<div class="confirmation">
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_integrated_services_description' )#</cfoutput>
</div>
</div>

<table class="table_details table_edit" style="width:auto">
<tr>
	<td class="field_name" valign="top">
		<!--- <cfif a_struct_external_facebook.result>
			<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>	
		<cfelse>
			<cfoutput>#application.udf.si_img( 'cross' )#</cfoutput>	
		</cfif> --->
	</td>
	<td>
		<a href="<cfoutput>#getFBAppBaseURL()#</cfoutput>" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/facebook_login.gif" style="vertical-align:middle;padding:8px;border:0px" alt="Facebook" /></a>
	</td>
	<td>
		<!--- <cfif NOT a_struct_external_facebook.result> --->
			<input type="button" class="btn" onclick="location.href = '/james/?event=user.preferences.addexternalid&servicename=facebook'" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>" />
	</td>
</tr>
<tr>
	<td class="field_name" valign="top">
		<cfif stExtDropBox.result>
			<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>	
		<cfelse>
			<cfoutput>#application.udf.si_img( 'cross' )#</cfoutput>	
		</cfif>
	</td>
	<td>
		<img src="/res/images/partner/services/dropbox-110x37.png" width="110" height="37" alt="DropBox" />
	</td>
	<td>
		<cfif NOT stExtDropBox.result>
			
			<input type="button" class="btn" onclick="window.open('/dropbox'); return false" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>" />
		<cfelse>
			
			<cfoutput>
				#application.udf.GetLangValSec( 'cm_wd_username' )#: #htmleditformat( stExtDropBox.a_item.getusername() )#
			</cfoutput>
			</td>
			<td>
				<cfoutput>
				<a href="##" onclick="SimpleBGOperation( 'preference.3prdparty.removeservice', 'servicename=dropbox', function() { location.reload() });return false">#application.udf.si_img( 'delete' )# #application.udf.GetLangValSec( 'pref_ph_remove_acc_integration' )#</a>
				</cfoutput>
		</cfif>
	</td>
</tr>
<tr>
	<td class="field_name" valign="top">
		<cfif a_struct_external_lastfm.result>
			<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>	
		<cfelse>
			<cfoutput>#application.udf.si_img( 'cross' )#</cfoutput>	
		</cfif>
	</td>
	<td>
		<b><img src="http://cdn.tunesBag.com/images/partner/lastfm-icon.png" style="vertical-align:middle;border:0px;padding:4px" /> last.fm / AudioScrobbler</b>
<!--- 		<br />
		Submit data to the AudioScrobbler --->
	</td>
	<td>
		
		<cfif NOT a_struct_external_lastfm.result>
			
			<input type="button" class="btn" onclick="location.href = '/james/?event=user.preferences.addexternalid&servicename=lastfm'"  value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_activate_now' )#</cfoutput>" />
			
		<cfelse>
		
			<cfoutput>
				
			<a href="http://www.last.fm/user/#htmleditformat( a_struct_external_lastfm.a_item.getusername() )#/" target="_blank">#application.udf.GetLangValSec( 'cm_wd_username' )#: #htmleditformat( a_struct_external_lastfm.a_item.getusername() )#</a>
			</td>
			<td>
				
			<a href="##" onclick="SimpleBGOperation( 'preference.3prdparty.removeservice', 'servicename=lastfm', function() { location.reload() });return false">#application.udf.si_img( 'delete' )# #application.udf.GetLangValSec( 'pref_ph_remove_acc_integration' )#</a>
			
			
			</cfoutput>
				
		
		</cfif>
	</td>
</tr>
<!--- <tr>
	<td class="field_name" valign="top">
		<cfif a_struct_external_blogger.result>
			<cfoutput>#application.udf.si_img( 'tick' )#</cfoutput>	
		<cfelse>
			<cfoutput>#application.udf.si_img( 'cross' )#</cfoutput>	
		</cfif>
	</td>
	<td>
		<b>Blogger.com</b>
		<br />
		Post playlists to your blog.
	</td>
</tr> --->
</table>


</div>

<div id="tab_privacy" class="div_container bb bl br">
	<div class="div_container">
		<h3><cfoutput>#application.udf.GetLangValSec( 'cm_wd_privacy' )#</cfoutput></h3>
	
		<cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_access_plist' )#</cfoutput>
		<br /><br />
		<input type="radio" value="0" name="privacy_playlists" <cfif Val( a_userdata.getprivacy_playlists() ) IS 0>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_all_users' )#</cfoutput>
		&nbsp;&nbsp;
		<input type="radio" value="1" name="privacy_playlists" <cfif Val( a_userdata.getprivacy_playlists() ) IS 1>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_friends' )#</cfoutput>
		<div class="addinfotext div_container">
			If you mark a playlist as private, only you will be able to access it.
		</div>

		<cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_access_newsfeed' )#</cfoutput>
		<br /><br />
		<input type="radio" value="0" name="privacy_newsfeed" <cfif Val( a_userdata.getprivacy_newsfeed() ) IS 0>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_all_users' )#</cfoutput>
		&nbsp;&nbsp;
		<input type="radio" value="1" name="privacy_newsfeed" <cfif Val( a_userdata.getprivacy_newsfeed() ) IS 1>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_friends' )#</cfoutput>
		
		<br /><br />
		<cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_access_profile' )#</cfoutput>
		<br /><br />
		<input type="radio" value="0" name="privacy_profile" <cfif Val( a_userdata.getprivacy_profile() ) IS 0>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_all_users' )#</cfoutput>
		&nbsp;&nbsp;
		<input type="radio" value="1" name="privacy_profile" <cfif Val( a_userdata.getprivacy_profile() ) IS 1>checked="true"</cfif> /> <cfoutput>#application.udf.GetLangValSec( 'pref_ph_privacy_friends' )#</cfoutput>
	</div>
	
		<div class="div_container">
		<input type="submit" class="btn" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" />
	</div>
	<!--- change password  --->
	<div class="div_container">
		<h3><cfoutput>#application.udf.GetLangValSec('cm_ph_change_password')#</cfoutput></h3>
		<a href="/james/?event=user.preferences.changepassword"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' )#</cfoutput></a>
	</div>
	
	<div class="div_container">
		<h3><cfoutput>#application.udf.GetLangValSec( 'pref_ph_autologin' )#</cfoutput></h3>
		
		<cfoutput>
			
		#application.udf.GetLangValSec( 'pref_ph_autologin_description' )#
			
		<div class="div_container">
		<textarea rows="1" cols="60" style="width:700px" name="autologin">http://www.tunesBag.com/rd/autologin/?username=#UrlEncodedFormat( a_userdata.getUsername() )#&password=#Hash( a_userdata.getPwd() )#</textarea>
		</div>
		
		</cfoutput>
		
	</div>
	
	<div class="div_container">
		<h3><cfoutput>#application.udf.GetLangValSec( 'pref_ph_signoff_close_account' )#</cfoutput></h3>
		<div class="div_container">
		<a href="/rd/signoff" target="_top"><cfoutput>#application.udf.GetLangValSec( 'pref_ph_signoff_close_account' )#</cfoutput></a>
		</div>
	</div>
	

</div>



</form>

<script type="text/javascript">
$("#id_tabs_container_preferences").tabs();
</script>


<!--- <cfif Len( event.getArg( 'a_struct_userdata' ).getcellphone_nr() ) GT 0 AND ( event.getArg( 'a_struct_userdata' ).getcellphone_confirmed() IS 0 )>
	<div class="confirmation">
		<cfoutput>
		<a href="/james/?event=user.mobile">#application.udf.GetLangValSec( 'mob_ph_confirm_your_number' )#</a>
		</cfoutput>
	</div>
</cfif> --->

</div>
</cfsavecontent>