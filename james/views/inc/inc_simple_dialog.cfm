<!--- //

	Module:		Simple dialog
	Description:Various simpe actions
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_str_type = event.getArg('type', '') />
<cfset a_struct_external_facebook = event.getArg( 'external_facebook' ) />
<cfset q_select_friends = event.getArg( 'q_select_friends' ) />
<cfset a_bol_own_container = event.getArg( 'ownContainer', true ) />

<!--- no container at all - testing --->
<cfset a_bol_own_container = false />

<cfsavecontent variable="request.content.final">
	
<!--- build an own container by default around it --->
<cfif a_bol_own_container>
	
	<div class="div_container">
</cfif>

<cfswitch expression="#a_str_type#">
	<cfcase value="items.tags">
		
		<cfset a_str_itemkey = event.getArg( 'entrykey' ) />
		<!--- 
		function GenerateTagSelector(entrykey, curtags) {
	var a_str_content = '<div style="padding-bottom:10px"><img onclick="_handleClick(this, \'rat\', 0)"; src="/res/images/si/bullet_gray.png" class="si_img" />';
	
	a_str_content += '<img src="/res/images/si/emoticon_waii.png" class="si_img" /> ';
	a_str_content += '<img src="/res/images/si/emoticon_unhappy.png" class="si_img" /> ';
	a_str_content += '<img src="/res/images/si/emoticon_smile.png" class="si_img" /> ';
	a_str_content += '<img src="/res/images/si/emoticon_happy.png" class="si_img" /> ';	
	a_str_content += '<img src="/res/images/si/emoticon_grin.png" class="si_img" />';		
	a_str_content += '<br /><br /><img src="http://deliver.tunesbagcdn.com/images/space1x1.png" class="si_img" />';
	a_str_content += '<input type="checkbox" class="noborder" name="" /> <a href="#" onclick="return false;">Apply to whole album</a>';
	a_str_content += '</div>';
	
	return a_str_content;
	} --->
	
		
		<form action="/james/?event=bgaction&amp;type=items.tags.set" onsubmit="DoAjaxSubmit( {
							'formid': this.id,
							'target': '#id_status_operation'
							} );return false;" id="id_set_item_tags">

		<input type="hidden" name="frmlibrarykey" value="<cfoutput>#event.getArg('librarykey')#</cfoutput>" />
		
		<table class="table_details table_edit" style="width:100%">
			<!--- <tr>
				<td class="field_name">
					Moods
				</td>
				<td>
					<a href="$('##frmtags').val( jQuery.trim( $('##frmtags').val() + ' ' + $(this).text() ) );return false"><img src="/res/images/si/emoticon_waii.png" class="si_img" /></a>
						<img src="/res/images/si/emoticon_unhappy.png" class="si_img" />
				</td>
			</tr> --->
			<tr>
				<td class="field_name">
					<cfoutput>#application.udf.GetLangValSec( 'cm_wd_tags' )#</cfoutput>
				</td>
				<td>
					<input type="text" name="frmtags" id="frmtags" value="<cfoutput>#htmleditformat( event.getArg( 'playlist_tags' ) )#</cfoutput>" />
					&nbsp;
					<cfoutput>#application.udf.GetLangValSec( 'cm_ph_tags_enter_hint' )#</cfoutput>
					<br />
					
					<cfinclude template="queries/q_select_popular_playlist_tags.cfm">
					
					<div id="id_playlist_tag_cloud" style="margin-top:10px;">
					<cfoutput query="q_select_tags" maxrows="20">
						<div class="b_all" style="padding:2px;float:left;margin:2px"><a href="##" onclick="$('##frmtags').val( jQuery.trim( $('##frmtags').val() + ' ' + $(this).text() ) );return false" style="text-decoration:none"><cfif Len( q_select_tags.image ) GT 0>#application.udf.si_img( q_select_tags.image )#<cfelse>#application.udf.si_img( 'tag_blue' )#</cfif> #htmleditformat( q_select_tags.tag )#</a></div>
					</cfoutput>
					
				</td>
			</tr>
			<tr>
				<td>
				</td>
				<td>
					<input type="checkbox" style="width:auto" />					
					<cfoutput>#application.udf.GetLangValSec( 'lib_ph_apply_tags_to_whole_album' )#</cfoutput>
				</td>
			</tr>
			<tr>
				<td class="field_name"></td>
				<td>
					<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" class="btn" />
				</td>
			</tr>
		</table>
		
		</form>

	
	</cfcase>
	<cfcase value="searchinternet">
		<!--- perform a search for the track on the net --->
		<cfset a_struct_search_result = event.getArg( 'a_struct_search_result' ) />
		
		<cfoutput><div class="div_right_small_link"><a href="##" onclick="$( '##id_top_lookup_info' ).slideUp();">#application.udf.GetLangValSec( 'cm_wd_action_hide' )#</a></div></cfoutput>
		
		<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_search_query_other_sources' ), '' )#</cfoutput>
		
		<div class="status"><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_webload_copyright' )#</cfoutput></div>
		
		<cfif a_struct_search_result.result AND a_struct_search_result.q_select_items.recordcount GT 0>
		
			<cfset q_select_items = a_struct_search_result.q_select_items />
			
			
			
			<cfoutput query="q_select_items" maxrows="3">

			<h4>#htmleditformat( q_select_items.name )# - #htmleditformat( q_select_items.artist )#</h4></a>
			
			<div class="div_container_small bb">
			
				<table class="table_overview" style="width:auto">
					<tr>
						<td style="vertical-align:top">
							<a href="##" onclick="SimpleBGOperation( 'add_webupload', 'location=#UrlEncodedFormat( q_select_items.href )#');$('##id_top_lookup_info').html( '<img src=\'http://deliver.tunesbagcdn.com/images/si/accept.png\' class=\'si_img\' /> #JsStringFormat( application.udf.GetLangValSec( 'lib_upload_type_webload_success_description' ))#' );return false">#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'lib_ph_edit_add_to_my_library' )#</a>
		
						</td>
						<td style="vertical-align:top">
							#application.udf.GetLangValSec( 'cm_wd_duration' )#: #htmleditformat( q_select_items.duration )# #application.udf.GetLangValSec( 'cm_wd_bitrate' )#: #htmleditformat( Val(Int( q_select_items.bitrate / 1000 )) )#
							<br />
							<span style="color:green">#htmleditformat( application.udf.ShortenString( q_select_items.host, 35 ) )#</span>
						</td>
					</tr>
					<tr>
						<td colspan="2" style="padding-left:20px" >
							
							<embed
								src="/res/flash/mediaplayer.swf"
								width="470"
								height="20"
								allowscriptaccess="always"
								allowfullscreen="true"
								flashvars="height=20&width=470&file=#UrlEncodedFormat( q_select_items.href )#&type=mp3"
							/>
							
						</td>
					</tr>
				</table>
				
			</div>
			</cfoutput>
			
			<!--- add mplayer --->
			<!--- <script type="text/javascript">
				var flashvars = {};
				var params = {};
				var attributes = {};
				
				attributes.id = "defaultmplayerlookup";
				
				flashvars.file = '<cfoutput>#UrlEncodedFormat( q_select_items.href )#</cfoutput>';
				flashvars.enablejs = 'true';
				flashvars.type = 'mp3';
				flashvars.autostart = 'true';
				flashvars.height = '20';
				flashvars.width = '470';
				flashvars.javascriptid = 'defaultmplayerlookup';
				
				swfobject.embedSWF("/res/flash/mediaplayer.swf", "id_default_mediaplayer_lookup", "470", "20", "9.0.0", false, flashvars, params, attributes);	
				alert('123');
			</script> --->
			
		
		
		
		<cfelse>
			<div class="status"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput></div>
		</cfif>
	
	</cfcase>
	<cfcase value="findytvideo">
	
		<!--- perform a search for the youtube video --->
		<cfset a_struct_search_result = event.getArg( 'a_struct_search_result' ) />
		
		<cfif a_struct_search_result.result AND a_struct_search_result.q_select_items.recordcount GT 0>
			
			<cfset q_select_items = a_struct_search_result.q_select_items />
			
			<div style="text-align:center;margin-top:16px">
			<object width="425" height="355">
				<param name="movie" value="http://www.youtube.com/v/<cfoutput>#q_select_items.id#</cfoutput>&rel=1&autoplay=1"></param><param name="wmode" value="transparent"></param>
			<embed src="http://www.youtube.com/v/<cfoutput>#q_select_items.id#</cfoutput>&rel=1&autoplay=1" type="application/x-shockwave-flash" wmode="transparent" width="425" height="355"></embed></object>
			</div>
			
			<script type="text/javascript">
				// stop playing in the bg
				parent.PlayerTogglePlayPause();
				
				// set black background
				$('.body_iframe').css( 'backgroundColor', 'black' );
			</script>
			
		<cfelse>
			<div class="status"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput></div>
		</cfif>		
	
	</cfcase>
	<cfcase value="friend.requestfriendship">
		
		<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_request_friendship' ), 'user_add' )#</cfoutput>
		
		<cfset a_str_data = event.getArg( 'username' ) />
		
		<cfquery name="q_select_friend_already_exists" dbtype="query">
		SELECT
			COUNT(entrykey) AS count_id
		FROM
			q_select_friends
		WHERE
			displayname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_data#">
			AND NOT
			otheruserkey = ''
		;
		</cfquery>
		
		<!--- already exists --->
		<cfif q_select_friend_already_exists.count_id GT 0>
			<div class="status">
				<cfoutput>#application.udf.GetLangValSec( 'social_ph_already_friend' )#</cfoutput>
			</div>
		<cfelse>
		
			<form action="/james/?event=bgaction&amp;type=friend.requestfriendship" onsubmit="DoAjaxSubmit( {
								'formid': this.id,
								} );tb_remove();return false;" id="id_frm_req_friendship">
								
			<input type="hidden" name="username" value="<cfoutput>#event.getArg( 'username' )#</cfoutput>" />
								
					<table class="table_details table_edit">
						<tr>
							<td><cfoutput>#application.udf.GetLangValSec( 'cm_wd_username' )#</cfoutput></td>
							<td>
								<cfoutput>#htmleditformat( event.getArg( 'username' ))#</cfoutput>
							</td>
						</tr>
						<tr>
							<td>
								<cfoutput>#application.udf.GetLangValSec( 'cm_wd_text')#</cfoutput>:
							</td>
							<td>
								<textarea name="customtext" rows="2" cols="30"></textarea>
							</td>
						</tr>
						<tr>
							<td></td>
							<td>
								<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_send' )#</cfoutput>" class="btn" />
							</td>
						</tr>					
					</table>								
								
			</form>	
		
		</cfif>
	
	</cfcase>
	<cfcase value="addressbookimport">
		<!--- address book importer --->
		
		<cfoutput>
		<div class="div_container" id="idaddressbookimporteraccessdata">
		Das Durchsuchen deines E-Mail-Kontos ist der schnellste Weg, um deine Freunde auf tunesBag zu finden und einzuladen
		
		<form action="/james/?event=bgaction&amp;type=addressbookimportergetcontacts" onsubmit="DoAjaxSubmit( {
								'formid': this.id,
								success: function(data) {
									$('##idaddressbookimporterresult').html( data.CONTENT );
									}
								} );$('##idaddressbookimporteraccessdata').hide();$('##idaddressbookimporterresult').html( sImgLoadingStatus ).fadeIn();return false" id="idformaddressbookimporter">
		<table class="table_details table_edit">
			<tr>
				<td class="field_name">
					#application.udf.GetLangValSec( 'cm_ph_supported_services' )#
				</td>
				<td>
					GMail, Hotmail, Yahoo, AOL, Lycos, GMX, Web.de, Mail.com, ...
				</td>
			</tr>
			<tr>
				<td class="field_name">
					#application.udf.GetLangValSec( 'cm_wd_email' )#
				</td>
				<td>
					<input type="text" name="username" />
				</td>
			</tr>
			<tr>
				<td class="field_name">
					#application.udf.GetLangValSec( 'cm_wd_password' )#
				</td>
				<td>
					<input type="password" name="password" />
				</td>
			</tr>
			<tr>
				<td>
				
				</td>
				<td>
					<input type="submit" value="Freunde finden" class="btn" />
				</td>
			</tr>
			<tr>
				<td>
				</td>
				<td>
					#application.udf.si_img( 'key' )# tunesBag speichert Dein Passwort nicht.
				</td>
			</tr>
		</table>	
		</form>
		</div>
		<div id="idaddressbookimporterresult" class="hidden">
			lala
		</div>
		</cfoutput>
		
	</cfcase>	
	<cfcase value="addfriend">

		<!--- add a new friend --->
		
		<!--- get invitations --->
		<cfset a_struct_invitations = getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetInvitationsSentByUser( securitycontext = application.udf.GetCurrentSecurityContext() ) />
	
		<cfset q_select_invitations = a_struct_invitations.q_select_invitations />
		
		<!--- <cfset a_int_invitations_left = ( Val(getAppManager().getPropertyManager().getProperty('invitations_per_user')) - q_select_invitations.recordcount) /> --->
		
		<cfif application.udf.GetCurrentSecurityContext().username IS 'funkymusic'>
			<cfset a_int_invitations_left = 999 />
		</cfif>
		
		<div id="id_send_invitation_form_reload">
		
		<!--- & ' (' & application.udf.GetLangValSec( 'social_ph_invite_friends_left_no', a_int_invitations_left ) & ')' --->
		<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangVal( 'social_ph_send_invitation_header' ) , 'star' )#</cfoutput>
		
			<!--- <cfif NOT a_struct_external_facebook.result AND NOT event.getArg( 'source' ) IS 'social.friends'>
			
				<div class="status">
					<cfoutput>
					<table>
						<tr>
							<td style="vertical-align:middle">
								<a href="/james/?event=user.preferences.addexternalid&servicename=facebook"><img src="/res/images/partner/facebook_login.gif" width="109" height="24" border="0" alt="Facebook Login" align="absmiddle" /></a>
							</td>
							<td style="padding-left:10px">
								<b>#application.udf.GetLangValSec( 'pref_fb_please_activate' )#</b>
								<br />
								<a href="/james/?event=user.preferences.addexternalid&amp;servicename=facebook">#application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' )#</a>
			
							</td>
								</tr>
					</table>
					</cfoutput>
				</div>	
	
			</cfif> --->
			
		<!--- <cfif a_int_invitations_left LTE 0>
			
			<div class="status">
				<cfoutput>#application.udf.GetLangValSec( 'social_ph_invite_friends_no_tickets_left' )#</cfoutput>
			</div>
		<cfelse> --->
			
			<cfset a_str_cur_page_url = cgi.SCRIPT_NAME & '?' & cgi.QUERY_STRING />
			
			<form action="/james/?event=bgaction&amp;type=sendinvitation" onsubmit="$('#id_send_invitation').hide();DoAjaxSubmit( {
								'formid': this.id,
								'target': '#id_status_operation'
								} );
								$.get('<cfoutput>#JsStringFormat( a_str_cur_page_url )#</cfoutput>', function(data){ $('#id_send_invitation_form_reload').html(data); });
								return false;" id="id_form_send_invitation">
	
			<input type="hidden" name="frmlibrarykey" value="<cfoutput>#event.getArg('librarykey')#</cfoutput>" />
			
				<table class="table_details table_edit">
					<tr>
						<td class="field_name">
							<cfoutput>#application.udf.GetLangValSec( 'cm_wd_email' )#</cfoutput>
						</td>
						<td>
							<input type="text" name="frmemail" value="" />
						</td>
					</tr>
					<!--- <cfif a_struct_external_facebook.result>
						<tr>
							<td class="field_name">
								Facebook
							</td>
							<td>
								<a href="##" onclick="parent.SimpleInpagePopup( '<cfoutput>#application.udf.GetLangValSec( 'cm_wd_friends' )#</cfoutput>', '/james/?event=user.social.friends.edit&width=840&height=500', false );return false"><cfoutput>#application.udf.GetLangValSec( 'social_ph_ask_fb_friend_to_join' )#</cfoutput></a>
							</td>
						</tr>
					</cfif> --->
					<tr>
						<td class="field_name">
							<cfoutput>#application.udf.GetLangValSec( 'cm_wd_text' )#<br />(#application.udf.GetLangValSec( 'cm_ph_read_only' )#)</cfoutput>
						</td>
						<td>
							<div style="height:100px;overflow:auto;padding:2px" class="b_all">
							<cfoutput>
							#ReplaceNoCase( getProperty( 'beanFactory' ).getBean( 'SocialComponent' ).GetPreparedInvitationText( securitycontext = application.udf.GetCurrentSecurityContext(), invitationkey = CreateUUID() ).text, Chr(10), '<br />', 'ALL' )#
							</cfoutput>
							</div>
						</td>
					</tr>
					<tr>
						<td class="field_name"></td>
						<td>
							<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_send' )#</cfoutput>" class="btn" />
						</td>
					</tr>
				</table>
				
			</form>
		
		<!--- </cfif>		 --->
		
		<table class="table_overview" style="margin-top:20px">
			<cfoutput>
			<thead>
				<tr>
				<th>
					#application.udf.GetLangValSec( 'cm_wd_recipient' )#
				</th>
				<th>
					#application.udf.GetLangValSec( 'cm_wd_created' )#
				</th>
				<th>
					#application.udf.GetLangValSec( 'cm_wd_accepted' )#
				</th>
				<th>
					#application.udf.GetLangValSec( 'cm_wd_delete' )#
				</th>
				</tr>
			</thead>
			</cfoutput>
			<cfoutput query="q_select_invitations">
				<tr>
					<td>
						<cfif q_select_invitations.recipient_type IS 0>
							#application.udf.si_img( 'email' )# <a href="mailto:#htmleditformat( q_select_invitations.recipient )#?subject=tunesBag">#htmleditformat( q_select_invitations.recipient )#
						</cfif>
					</td>
					<td>
						#htmleditformat( LSDateFormat( q_select_invitations.dt_created, 'dd/mm/yy' ))#
					</td>
					<td>
						<cfif q_select_invitations.accepted IS 1>
							#application.udf.si_img( 'tick' )#
						</cfif>
					</td>
					<td>
						<cfif q_select_invitations.accepted IS 0>
							<a href="##" onclick="SimpleBGOperation( 'invitation.delete', 'entrykey=#urlEncodedFormat( q_select_invitations.entrykey )#');$(this).parents('tr').fadeOut();return false" title="#application.udf.GetLangValSec( 'cm_wd_delete' )#">#application.udf.si_img( 'bin' )#</a>
						</cfif>
					</td>
				</tr>
			</cfoutput>
		</table>
		
		</div>
		
	</cfcase>
	<cfcase value="playlist.delete">
		<!--- delete a playlist --->
		<form action="/james/?event=bgaction&amp;type=playlist.delete" onsubmit="DoAjaxSubmit( {
							'formid': this.id,
							'target': '#id_status_operation',
							'success': function() {ReloadPlaylists()}
							} );tb_remove();return false;" name="id_delete_playlist" id="id_delete_playlist">
			<input type="hidden" name="playlistkey" value="<cfoutput>#event.getArg( 'playlistkey' )#</cfoutput>" />
			<div style="text-align:center;">
			<cfoutput>#application.udf.GetLangValSec( 'cm_ph_are_you_sure' )#</cfoutput>
			<br /><br />
			<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_yes' )#</cfoutput>" name="frmsubmit" class="btn" />
			&nbsp;&nbsp;
			<input type="button" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_no' )#</cfoutput>" class="btn" onclick="parent.tb_remove();" />
			</div>
		</form>
		
		
	</cfcase>
	<cfcase value="playlist.new,playlist.edit">

		<!--- edit operation? --->
		<cfif a_str_type IS 'playlist.edit'>
			
			<cfset a_struct_filter.entrykeys = event.getArg( 'playlistkey' ) />
			
			<!--- try to load plist --->
			<cfset a_struct_playlist = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = application.udf.GetCurrentSecurityContext(),
									librarykeys = event.getArg( 'librarykey' ),
									filter = a_struct_filter,
									type = 'playlists') />
									
			<cfif NOT a_struct_playlist.result>
				<h4>Access forbidden</h4>
				<cfexit method="exittemplate">
			</cfif>
			
			<cfset q_select_playlist = a_struct_playlist.q_select_items />
			
			<cfif q_select_playlist.userkey NEQ application.udf.GetCurrentSecurityContext().entrykey>
				
				<h4>Access forbidden</h4>
				<cfexit method="exittemplate">
			</cfif>
			
			<!--- set properties --->
			<cfset event.setArg( 'playlist_entrykey', q_select_playlist.entrykey ) />
			<cfset event.setArg( 'librarykey', q_select_playlist.librarykey ) />
			<cfset event.setArg( 'playlist_name', q_select_playlist.name ) />
			<cfset event.setArg( 'playlist_description', q_select_playlist.description ) />	
			<cfset event.setArg( 'playlist_tags', q_select_playlist.tags ) />		
			<cfset event.setArg( 'playlist_public', q_select_playlist.public ) />	
			<cfset event.setArg( 'playlist_dynamic', q_select_playlist.dynamic ) />	
			<cfset event.setArg( 'playlist_dynamic_criteria', q_select_playlist.dynamic_criteria ) />
			<cfset event.setArg( 'playlist_imageset', q_select_playlist.imageset ) />
			

			<!--- is it a playlist which is still temporary? --->
			<cfif q_select_playlist.istemporary>
			
				<!--- don't use the UUID name --->
				<cfset event.setArg( 'playlist_name', application.udf.GetLangValSec( 'cm_wd_playlist' ) & ' (' & DateFormat( Now(), 'dd.mm.yy') &')' ) />
				<cfset event.setArg( 'playlist_description', '') /> 
			</cfif>	
			
		<cfelse>
		
			<cfoutput>
			<div class="div_container_small">
				<form style="margin:0px">
				<input type="radio" value="default" name="selecttype" id="id_select_simple_plist" checked="true" onclick="$('##id_create_smart_plist').hide();$('##id_create_default_plist').fadeIn();" style="vertical-align:middle" /> <label for="id_select_simple_plist">#application.udf.GetLangValSec( 'cm_ph_create_new_playlist' )#</label>
				<input type="radio" value="smart" name="selecttype" id="id_select_smart_plist" onclick="$('##id_create_default_plist').hide();$('##id_create_smart_plist').fadeIn()" style="vertical-align:middle" /> <label for="id_select_smart_plist">#application.udf.GetLangValSec( 'start_ph_create_smart_playlist' )#</label>
				</form>
			</div>
			</cfoutput>
			
			<!--- tabify! --->
			<script type="text/javascript">
			$("#id_tabs_container_plist_type > ul").tabs();
			</script>
		
		</cfif>
		
		<div id="id_create_default_plist">
		<!--- create a new playlist --->
		<form action="/james/?event=bgaction&amp;type=createeditplaylist" onsubmit="DoAjaxSubmit( {
							'formid': this.id,
							'target': '#id_status_operation',
							'success': function() { parent.ReloadPlaylists();ShowHidePlaylists();StatusMsg( langSet.getTrans( 'cm_wd_created' ) , 'page_white_cd'); }
							} );parent.tb_remove();return false;" id="id_form_new_plist">
								
								
		<!--- auto - add items --->
		<input type="hidden" name="frmadditemkeys" value="<cfoutput>#htmleditformat( event.getArg( 'additems' ) )#</cfoutput>" />
								
		<input type="hidden" name="frmlibrarykey" value="<cfoutput>#htmleditformat( event.getArg('librarykey') )#</cfoutput>" />
		
		<!--- entrykey of the playlist ('' on create) --->
		<input type="hidden" name="frmentrykey" value="<cfoutput>#htmleditformat( event.getArg( 'playlist_entrykey' ) )#</cfoutput>" />
		
		<!--- dynamic? --->
		<cfoutput>
		<input type="hidden" name="dynamic" value="#htmleditformat( event.getArg( 'playlist_dynamic', 0) )#" />
		<input type="hidden" name="dynamic_criteria" value="#htmleditformat( event.getArg( 'playlist_dynamic_criteria', '') )#" />
		</cfoutput>
		
		<!--- <cfif event.getArg( 'playlist_imageset' ) IS 1> --->
			<cfoutput>
				<div class="cBox cBox95" style="float:right;margin-top:20px;">
					<div class="content" id="idPlistImageContent" style="background-image:URL('#application.udf.getPlistImageLink( event.getArg( 'playlist_entrykey' ), 120 )#?#CreateUUID()#');background-position:center center;">
						<a href="##" onclick="$('##idFlickrStartSearchLink').click();return false">#application.udf.si_img( 'find' )#</a>
					</div>
				</div>

			</cfoutput>
		<!--- </cfif> --->
		
		<div style="position:absolute;padding:20px;left:10px;right:10px;top: 40px; bottom: 10px;background-color:white" class="hidden" id="idflickrlookup">
			<p class="bb div_container">
			<a href="##" onclick="$('#idflickrlookup').fadeOut();return false">&lt; <cfoutput>#application.udf.GetLangValSec( 'cm_wd_cancel' )#</cfoutput></a>
			</p>
			<table class="table_details table_edit tbl_bigform" style="margin-top:0px">
				<tr>
					<td>
						
						<p class="addinfotext"><img src="http://deliver.tunesbagcdn.com/images/partner/flickr.png" class="si_img" /> <cfoutput>#application.udf.GetLangValSec( 'cm_ph_plist_flickr_search_hint' )#</cfoutput></p>

						<input type="text" name="frmtext" value="" id="idFlickrSearchTerm" onKeyPress="" />
						&nbsp;												
						<input type="button" id="idFlickrSearchButton" class="btn" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_search' )#</cfoutput>" onclick="plistSearchFlickrImages($('#idFlickrSearchTerm').val());return false;" />				
					</td>
				</tr>
				<tr>
					<td>
						<div id="idflickrresult" class="lightbg b_all div_container" style="height:280px;overflow:auto">							
						</div>						
					</td>
				</tr>
			</table>

			
				

		</div>
			
			
			<script type="text/javascript">
				function plistSearchFlickrImages( searchterm ) {
					
					$('#idFlickrSearchTerm').val( searchterm );
					
					$('#idflickrlookup').fadeIn();
					$('#idflickrresult').html( sImgLoadingStatus );
					
					SimpleBGOperation( 'ui.flickr.searchphotos', { 'search' : searchterm }, function(data) {
						var oData = JSON.parse(data);
						
						// fill with data
						$('#idflickrresult').html( oData.FLICKR_SEARCH );
						});
					}
					
				$("#idFlickrSearchTerm#").keypress(function (e) {
					if (e.which == 13) {
						$('#idFlickrSearchButton').click();
						return false;
						}
					});
				
			</script>
			
			<table class="table_details table_edit tbl_bigform">
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_name' )#</cfoutput>
					</td>
					<td>
						<input type="text" name="frmname" value="<cfoutput>#htmleditformat( event.getArg( 'playlist_name' ) )#</cfoutput>" />
					</td>
				</tr>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_description' )#</cfoutput>
					</td>
					<td>
						<textarea name="frmdescription" style="height:60px"><cfoutput>#htmleditformat( event.getArg( 'playlist_description' ) )#</cfoutput></textarea>
						<!--- <input type="text" name="frmdescription" value="<cfoutput>#htmleditformat( event.getArg( 'playlist_description' ) )#</cfoutput>" /> --->
					</td>
				</tr>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_tags' )#</cfoutput>
					</td>
					<td style="line-height:200%">
						<input type="text" name="frmtags" id="frmtags" value="<cfoutput>#htmleditformat( event.getArg( 'playlist_tags' ) )#</cfoutput>" />
						&nbsp;
						<a href="#" onclick="$(this).hide();$('#id_playlist_tag_cloud').fadeIn();"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_display_popular_tags' )#</cfoutput></a>
						
						<cfinclude template="queries/q_select_popular_playlist_tags.cfm">
						
						<div id="id_playlist_tag_cloud" style="margin-top:10px;display:none">
						<cfoutput query="q_select_tags" maxrows="20">
							<a href="##" onclick="$('##frmtags').val( jQuery.trim( $('##frmtags').val() + ' ' + $(this).text() ) );return false" class="tag_box">#htmleditformat( q_select_tags.tag )#</a>
						</cfoutput>
						</div>
						
						<div style="clear:both;padding-top:4px"></div>
						<cfoutput>#application.udf.GetLangValSec( 'cm_ph_tags_enter_hint' )#</cfoutput>
						
					</td>
				</tr>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlist_public' )#</cfoutput>
					</td>
					<td>
						<input type="checkbox" name="frmpublic" value="1" style="width:auto" <cfif event.getArg( 'playlist_public',  1 ) IS 1>checked="true"</cfif> />
						&nbsp;
						<cfoutput>#application.udf.GetLangValSec( 'cm_ph_playlist_public_hint' )#</cfoutput>						
					</td>
				</tr>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_image' )#</cfoutput>
					</td>
					<td>
						<!--- <div id="upload_button_id" class="div_container_small" style="width:auto !important;cursor:pointer">
							
							
							<span class="btn"><cfoutput>#application.udf.si_img( 'image' )# #application.udf.GetLangValSec( 'lib_upload_infotext' )#</cfoutput></span>
							
							<cfif event.getArg( 'playlist_imageset' ) IS 1>
								<img src="#application.udf.getPlistImageLink( event.getArg( 'playlist_entrykey' ), 120 )#" />
							</cfif>
						</div> --->
						
						
						<a href="##" id="idFlickrStartSearchLink" onclick="plistSearchFlickrImages('<cfoutput>#jsStringFormat( event.getArg( 'playlist_name' ) )#</cfoutput>');return false"><img src="http://deliver.tunesbagcdn.com/images/partner/flickr.png" class="si_img" /> Browse/Search free images</a>
 						<cfoutput>
						<a href="##" onclick="" id="upload_button_id" style="cursor:pointer">#application.udf.si_img( 'image' )# #application.udf.GetLangValSec( 'cm_ph_upload_own_image' )#</a>
						</cfoutput>
						
						<div class="status hidden" id="upload_own_image_waiting">
							<img alt="" style="border:0px" src="http://deliver.tunesbagcdn.com/images/img_circle_loading.gif" width="32" height="32" style="vertical-align:middle" /> <cfoutput>#application.udf.GetLangValSec( 'cm_ph_loading_please_wait' )#</cfoutput>
						</div>

					</td>
				</tr>
				<tr>
					<td class="field_name"></td>
					<td>
						<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_save' )#</cfoutput>" class="btn" />
					</td>
				</tr>
				<cfif Len( event.getArg( 'additems' ) ) GT 0>
					<tr>
						<td class="field_name">
							<cfoutput>#application.udf.GetLangValSec( 'cm_wd_add' )#</cfoutput>
						</td>
						<td>
						
							<ul class="ul_nopoints">
							<cfloop list="#event.getArg( 'additems' )#" index="a_str_entrykey">
								<li><cfoutput>#htmleditformat( getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItemDisplayNameByEntrykey( a_str_entrykey ) )#</cfoutput></li>
							</cfloop>
							</ul>
			
						</td>
					</tr>
				</cfif>
			</table>
			
		</form>
		</div>
		
		<!--- create image upload btn --->		
		<script type="text/javascript">
		new AjaxUpload('#upload_button_id', {
			  // Location of the server-side upload script
			  action: '/james/?event=user.content.imageupload',
			  // File upload name
			  name: 'plist_image',
			  // Additional data to send
			  data: {
			    plistkey : '<cfoutput>#jsStringFormat( event.getArg( 'playlist_entrykey' ) )#</cfoutput>',
			    rand : Math.random()
			  },
			  // Submit file after selection
			  autoSubmit: true,
			  responseType: 'json',
			  onChange: function(file, extension){
			  	if (extension != 'jpg') {
			  		alert( 'Please select a JPG image');
			  		return false;
			  		}
			  	},
			  // Fired before the file is uploaded
			  // You can return false to cancel upload
			  // @param file basename of uploaded file
			  // @param extension of that file
			  onSubmit: function(file, extension) {
			  	// add loading img
			  	$( '#upload_own_image_waiting' ).fadeIn();
			  	},
			  // Fired when file upload is completed
			  // WARNING! DO NOT USE "FALSE" STRING AS A RESPONSE!
			  // @param file basename of uploaded file
			  // @param response server response
			  onComplete: function(file, response) {

			  	  $( '#upload_own_image_waiting' ).fadeOut();
			  	  
			  	  if (response.RESULT) {
			  	  	// alert( $('#idPlistImageContent').css('background-image') );
			  	  	$('#idPlistImageContent').css('backgroundImage', 'URL("<cfoutput>#application.udf.getPlistImageLink( event.getArg( 'playlist_entrykey' ), 120 )#</cfoutput>?' + rnd() + '")' );
			  	  	} else {
			  	  		alert( response.ERRORMESSAGE );
			  	  		}
			  	}
			});
			
		// handle click on flickr image
		function handleFlickrImageClick( imagelink, licence, link_copyright ) {
			
			$('#idflickrresult').html( sImgLoadingStatus );
			
			$.post("/james/?event=user.content.imageupload", {
				plist_image: imagelink,
				licence_type_image : licence,
				licence_image_link : link_copyright,
				plistkey : '<cfoutput>#jsStringFormat( event.getArg( 'playlist_entrykey' ) )#</cfoutput>'  },
			  function(data){
			   $('#idflickrlookup').fadeOut();
			   
			   // reload plist image
			  $('#idPlistImageContent').css('backgroundImage', 'URL("<cfoutput>#application.udf.getPlistImageLink( event.getArg( 'playlist_entrykey' ), 120 )#</cfoutput>?' + rnd() + '")' );
			  });
			
			}
			
		function rnd(){ return String((new Date()).getTime()).replace(/\D/gi,'') }
		</script>
		
		<!--- create smart playlists --->
		<cfinclude template="welcome/inc_create_smart_plist.cfm">


	</cfcase>
	<cfcase value="addcomment">
		
		<!--- subscribed to twitter? --->
		<cfset a_struct_twitter = event.getArg( 'external_twitter') />
		<cfset a_str_type = event.getArg( 'itemtype', 'mediaitem' ) />
		<cfset a_str_name = event.getArg( 'name' ) />
		
		<form action="/james/?event=bgaction&amp;type=addcomment" onsubmit="DoAjaxSubmit( {
							'formid': this.id,
							'success': function() { tb_remove(); },
							'target': '#id_status_operation'
							} );return false;" id="id_form_add_comment" name="id_form_add_comment">
							
			<input type="hidden" name="itemtype" value="<cfoutput>#event.getArg( 'itemtype' )#</cfoutput>" />
			<input type="hidden" name="itemkey" value="<cfoutput>#event.getArg( 'entrykey' )#</cfoutput>" />
			<input type="hidden" name="rating" value="0" />
			
				<table class="table_details table_edit" style="width:100%">
				<cfif Len( a_str_name ) GT 0>
					<tr>
						<td class="field_name">
							<cfoutput>#application.udf.GetLangValSec( 'cm_wd_name' )#</cfoutput>
						</td>
						<td>
							<cfoutput>#htmleditformat( a_str_name )#</cfoutput>
							
							<cfif a_str_type IS 'playlist'>
								(<cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlist' )#</cfoutput>)
							</cfif>
						</td>
					</tr>
				</cfif>
				<tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_text' )#</cfoutput>
					</td>
					<td>
						<textarea name="comment" rows="3" cols="70"></textarea>
					</td>
				</tr>
				<!--- <tr>
					<td class="field_name">
						<cfoutput>#application.udf.GetLangValSec( 'cm_wd_rating' )#</cfoutput>
					</td>
					<td>
						<select name="frmrating">
							<option value="0"></option>
							<cfloop from="1" to="5" index="ii">
								<option value="<cfoutput>#ii#</cfoutput>"><cfoutput>#ii#</cfoutput></option>
							</cfloop>
						</select>
					</td>
				</tr> --->
				<cfif IsStruct( a_struct_twitter ) AND a_struct_twitter.result>
					<tr>
						<td class="field_name">
							<img src="http://deliver.tunesbagcdn.com/images/partner/twitter-logo.jpg" height="20" align="absmiddle" />
						</td>
						<td>
							<input type="checkbox" value="1" name="posttotwitter" checked style="width:auto" />
							
							Post to my Twitter account
							<cfoutput>
							(<a href="http://twitter.com/#htmleditformat( a_struct_twitter.a_item.getusername() )#" target="_blank">#htmleditformat( a_struct_twitter.a_item.getusername() )#</a>)
							</cfoutput>
						</td>
					</tr>
				</cfif>
				<tr>
					<td class="field_name"></td>
					<td>
						<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_btn_create' )#</cfoutput>" class="btn" />
					</td>
				</tr>
			</table>
		</form>		
		
		<script type="text/javascript">
			document.id_form_add_comment.comment.focus();			
		</script>
		
	</cfcase>
	<cfcase value="item.lyrics">
	
		<!--- display lyrics --->
		<cfset a_struct_item_info = event.getArg( 'a_struct_item_info' ) />
		<cfset a_struct_lyrics = event.getArg( 'a_struct_lyrics' ) />
				
		<cfif NOT a_struct_lyrics.result>
			
			<cfoutput>#application.udf.WriteCommonErrorMessage( a_struct_lyrics.error )#</cfoutput>
		
		<cfelse>
		
			<cfoutput>#application.udf.WriteSectionHeader( a_struct_item_info.artist & ' - ' & a_struct_item_info.name , '' )#</cfoutput>
		
			<div style="line-height:160%;font-size:150%" class="div_container">
			<cfloop list="#a_struct_lyrics.content#" delimiters="#chr( 10 )#" index="a_str_line">
				<cfoutput>#a_str_line#</cfoutput><br />
			</cfloop>
			</div>
			
			<br />
			<p>
			powered by <a href="http://lyricwiki.org" target="_blank">lyricwiki</a>
			</p>
		
		</cfif>
	
	</cfcase>
	<cfcase value="item.download">
	
		<!--- download an item ... make a simple delivery --->
				
		<cfset a_data = event.getArg( 'a_download_item' ) />
		
		<cfif NOT IsStruct( a_data ) OR NOT a_data.result>
			
			<cfoutput>#application.udf.WriteCommonErrorMessage( 'Access forbidden' )#</cfoutput>	
			
		<cfelse>
		
			<cflocation addtoken="false" url="#a_data.deliver_info.location#">
		
		</cfif>
	
	</cfcase>
	<cfcase value="item.info">
	
		<!--- display info about item --->
		<!--- <h2><cfoutput>#application.udf.GetLangValSec( 'cm_wd_information' )#</cfoutput></h2> --->
		
		<cfif IsQuery( event.getArg( 'a_struct_item_info' ) )>
			
			<cfset q_select_info = event.getArg( 'a_struct_item_info' ) />
			
			<cfoutput query="q_select_info">
			<table class="table_details table_edit">
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_artist' )#
					</td>
					<td>
						#htmleditformat( q_select_info.artist )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_album' )#
					</td>
					<td>
						#htmleditformat( q_select_info.album )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_title' )#
					</td>
					<td>
						#htmleditformat( q_select_info.name )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_genre' )#
					</td>
					<td>
						#htmleditformat( q_select_info.genre )#
					</td>
				</tr>				
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_year' )#
					</td>
					<td>
						#htmleditformat( q_select_info.yr )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_ph_track_number' )#
					</td>
					<td>
						#htmleditformat( q_select_info.tracknumber )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_ph_total_time' )#
					</td>
					<td>
						#htmleditformat( q_select_info.totaltime )#
					</td>
				</tr>			
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_wd_comments' )#
					</td>
					<td>
						#htmleditformat( q_select_info.comments )#
					</td>
				</tr>			
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_ph_times_played_count' )#
					</td>
					<td>
						#htmleditformat( q_select_info.times )#
					</td>
				</tr>
				<tr>
					<td class="field_name">
						#application.udf.GetLangValSec( 'cm_ph_times_last_time_played' )#
					</td>
					<td>
						<cfif IsDate( q_select_info.lasttime )>
						#LSDateFormat( q_select_info.lasttime,  'mm/dd/yyyy')#
						</cfif>
					</td>
				</tr>
			</table>
			</cfoutput>
			
		</cfif>
			
	
	</cfcase>
	<cfcase value="items.delete">
		<!--- remove items from the library --->
		
		<cfif Len( event.getArg( 'entrykeys' )) GT 0>
			
			<!--- 
			
				call the delete function
				
				reload the library if we've success and rebuild the output
			
			 --->
			<form action="/james/?event=bgaction&amp;type=items.delete" onsubmit="DoAjaxSubmit( { 'formid': this.id, 'success' : function() { librariesSet.ReloadBaseLibrary( function() { RefreshItemListing(); }  ); } } );tb_remove();return false;" name="id_remove_from_lib" id="id_remove_from_lib">
				<input type="hidden" name="itemkeys" value="<cfoutput>#event.getArg( 'entrykeys' )#</cfoutput>" />
				<div style="text-align:center;">
				<cfoutput>#application.udf.GetLangValSec( 'cm_ph_are_you_sure' )#</cfoutput>
				<br /><br />
				<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_yes' )#</cfoutput>" name="frmsubmit" class="btn" />
				&nbsp;&nbsp;
				<input type="button" value="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_no' )#</cfoutput>" class="btn" onclick="parent.tb_remove();" />
				</div>
			</form>	
			
			<!--- display short information --->
			<ul>
			<cfloop list="#event.getArg( 'entrykeys' )#" index="a_str_entrykey">
				<li><cfoutput>#htmleditformat( getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetMediaItemDisplayNameByEntrykey( a_str_entrykey ) )#</cfoutput></li>
			</cfloop>
			</ul>
			
		
		</cfif>	
	</cfcase>
</cfswitch>

<cfif a_bol_own_container>
	</div>
</cfif>

</cfsavecontent>