<!---

	playlist options
	
	important: save temporary playlists if the user wants to

--->

<cfinclude template="/common/scripts.cfm">

<cfset sPlaylistkey = event.getArg( 'playlistkey' ) />
<cfset a_struct_playlist = event.getArg( 'a_struct_playlist' ) />

<cfif NOT IsStruct( a_struct_playlist ) OR NOT a_struct_playlist.result>
	<cfset request.content.final = 'no hit' />
	<cfexit method="exittemplate">
</cfif>

<cfset q_select_playlist = a_struct_playlist.q_select_items />
<cfset a_userdata = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetUserData( userkey = q_select_playlist.userkey ) />

<!--- own plist? hide some items in this case --->
<cfset a_bol_own_plist = a_userdata.a_struct_item.getEntrykey() IS application.udf.GetCurrentSecurityContext().entrykey />

<cfset a_struct_comments = event.getArg( 'a_struct_comments' ) />
<cfset a_bol_comments = false />

<cfif IsStruct( a_struct_comments ) AND a_struct_comments.result>
	
	<cfset q_select_comments = a_struct_comments.q_select_items />
	
	<cfif q_select_comments.recordcount GT 0>
		<cfset a_bol_comments = true />
	</cfif>
	
</cfif>

<cfsavecontent variable="request.content.final">

<cfoutput query="q_select_playlist">
	
<div class="div_container">
	
	<table style="width:100%">
		<tr>
			<td style="width:100px;text-align:center;padding:6px">
			
				#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( q_select_playlist.entrykey, 120, q_select_playlist.img_revision ),
									application.udf.CheckZeroString( q_select_playlist.name ),
									'',
									75,
									false,
									true )#

			</td>
			
			<td>
				
				<cfif q_select_playlist.totaltime GT 0>
					<cfset sTime = ' (' & application.udf.FormatSecToHMS( q_select_playlist.totaltime ) & ')' />
				<cfelse>
					<cfset sTime = '' />
				</cfif>
				
				
				<h2>#htmleditformat( q_select_playlist.name & ' ' & sTime )#</h2>
				
				<p class="addinfotext">
					<cfif q_select_playlist.public IS 0>(#application.udf.si_img( 'key' )# #application.udf.GetLangValSec( 'cm_wd_private' )#)</cfif>
					
					#htmleditformat( q_select_playlist.description )#
					<cfif q_select_playlist.dynamic IS 1>
						(#application.udf.GetLangValSec( 'cm_ph_smart_playlist' )#)
					</cfif>
					
					<cfif Len( q_select_playlist.tags ) GT 0>
						<p style="margin-top:6px">
						#application.udf.GetLangValSec( 'cm_wd_tags' )#: 
						<!--- loop over the tags --->
						<cfloop list="#q_select_playlist.tags#" index="a_str_tag" delimiters=" ">
							<cfset a_str_tag = ReplaceNoCase( a_str_tag, ',', '') />
							<a class="tag_box" href="##" onclick="DoRequest( 'search', { search : '#jsStringFormat( a_str_tag )#'});return false;">#htmleditformat( a_str_tag )#</a>		
						</cfloop>
						</p>
					</cfif>
				</p>
				
				<cfif q_select_playlist.licence_type_image IS 100>
					<p class="addinfotext" style="margin-top:8px">
						<a class="addinfotext" href="#q_select_playlist.licence_image_link#" target="_blank">#application.udf.GetLangValSec( 'cm_ph_image_licence_link_cc' )#</a>
					</p>
				</cfif>
				
			</td>
			<cfif q_select_playlist.systemplist IS 0>
			<td>
				<!--- rating --->
				<div style="white-space:nowrap;padding-top:8px" class="addinfotext">
					#application.udf.GetLangValSec( 'cm_wd_rating' )#
					
					#WriteRatingBar( 3, q_select_playlist.entrykey, q_select_playlist.avgrating, true )#
				</div>
				
				<cfif a_bol_comments>
				
				 	<a href="##" onclick="$('.show_comments_plist').show();return false;">#application.udf.GetLangValSec( 'cm_wd_comments' )# (#q_select_comments.recordcount#)</a>
				
					<div style="display:none" class="show_comments_plist">
					<cfloop query="q_select_comments">
						#application.udf.WriteDefaultUserNameProfileLink( q_select_comments.createdbyusername )# <span class="addinfotext">(#LsDateFormat( q_select_comments.dt_created, 'mm/dd') #)</span>: #htmleditformat( q_select_comments.comment )#
						<div class="clear"></div>
					</cfloop>
					</div>
				
				</cfif>
				
				<!--- #WriteShareButton( 2, q_select_playlist.entrykey, q_select_playlist.name & ' (' & application.udf.GetLangValSec( 'cm_wd_playlist' ) & ')', generateURLToPlist( q_select_playlist.entrykey, q_select_playlist.name, true), 0 )# --->
		
			</td>
			</cfif>
			<td>
				<div style="float:right">
					#application.udf.writeDefaultImageContainer( application.udf.getUserImageLink( q_select_playlist.username, 75 ),
								q_select_playlist.username,
								'/user/' & Urlencodedformat( q_select_playlist.username ),
								38,
								false,
								true )#
					<div class="clear"></div>
					#htmleditformat( q_select_playlist.username )#
				</div>
			</td>
		</tr>
	</table>


	<div class="clear"></div>
	
	<!--- save as? --->
	<cfif q_select_playlist.userkey IS application.udf.GetCurrentSecurityContext().entrykey>
			
		<cfif q_select_playlist.istemporary IS 1>
			<div class="status">
				#application.udf.GetLangValSec( 'cm_ph_smart_plist_is_temporary' )#
				<br />
				<input type="button" value="Save this playlist now ..." onclick="SimpleInpagePopup( '#application.udf.GetLangValSec( 'cm_wd_playlist' )#', '/james/?event=ui.simple.dialog&amp;librarykey=#q_select_playlist.librarykey#&amp;type=playlist.edit&amp;playlistkey=#q_select_playlist.entrykey#&amp;height=480', false )" class="btn" />
			</div>
		</cfif>

	</cfif>
	
	<p class="lightbg" style="padding:6px">
	<!--- owner ... --->
	<cfif (q_select_playlist.userkey IS application.udf.GetCurrentSecurityContext().entrykey)>
		
		<a href="##" onclick="CallShareDlg(this, 'plist' , '#q_select_playlist.entrykey#');return false"><img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-plistadminplistAdmin sprite-plistadminplistAdminShareActive" /> #application.udf.GetLangValSec( 'cm_wd_share' )#</a>
		&nbsp;&nbsp;&nbsp;
		
		<a  href="##" onclick="SimpleInpagePopup( '#JsStringFormat( q_select_playlist.name )#', '/james/?event=ui.simple.dialog&amp;librarykey=#q_select_playlist.librarykey#&amp;type=playlist.edit&amp;playlistkey=#q_select_playlist.entrykey#&amp;height=480', false );return false"><img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-plistadminplistAdmin sprite-plistadminplistAdminEditActive" /> #application.udf.GetLangValSec( 'cm_wd_edit' )#</a>
		
		<cfif (q_select_playlist.dynamic IS 0) AND q_select_playlist.systemplist IS 0>
			|
			<a href="##" onclick="$('##id_playlist_reorder_btn').hide();$('##id_plist_edit_reorder_info').fadeIn();SwitchToPlistEditMode( true);return false">#application.udf.GetLangValSec( 'cm_ph_playlist_edit_order' )#</a>
			|
			<label for="searchplistaddtrack">#application.udf.GetLangValSec( 'cm_wd_add' )#:</label>
			
			<input type="text" id="searchplistaddtrack" name="searchplistaddtrack" style="width:140px;padding:3px" class="b_all addinfotext" onclick="checkInactiveInput(this)" value="#application.udf.GetLangValSec( 'cm_wd_artist' )#, #application.udf.GetLangValSec( 'cm_wd_name' )#" />
			
			#application.udf.GetLangValSec( 'cm_wd_or' )#
			<a href="##" onclick="OpenUploadWindow( '<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser', false )#</cfoutput>', false, '#sPlaylistkey#' );return false">#application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
			&nbsp;&nbsp;&nbsp;
		</cfif>
		
		&nbsp;&nbsp;&nbsp;
		<a href="##" onclick="SimpleInpagePopup( '#JsStringFormat( q_select_playlist.name )#', '/james/?event=ui.simple.dialog&amp;librarykey=#q_select_playlist.librarykey#&amp;type=playlist.delete&amp;playlistkey=#q_select_playlist.entrykey#&amp;height=160', false );return false"><img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-plistadminplistAdmin sprite-plistadminplistAdminDeleteActive" /> #application.udf.GetLangValSec( 'cm_wd_delete' )#</a>
							
		
	<cfelse>
	
		<a href="##" style="font-weight:bold" onclick="librariesSet.addLinkedPlist( '#q_select_playlist.entrykey#', '#q_select_playlist.userkey#' );StatusMsg( '#application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_done_status' )#', 'folder_add');return false">#application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_plist' )#</a>

	</cfif>
		&nbsp;&nbsp;&nbsp;
		<a title="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_edit_add_comment' )#</cfoutput>" href="##" onclick="DoRequest( 'addcomment', { 'entrykey' : '#JsStringFormat( q_select_playlist.entrykey )#', 'dlgtitle' : escape( this.title ), 'name' : '#JsStringFormat( q_select_playlist.name )#', 'itemtype' : '1' } );return false;"><img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-plistadminplistAdmin sprite-plistadminplistAdminCommentActive" /> #application.udf.GetLangValSec( 'lib_ph_edit_add_comment' )#</a>
	</p>
	

</div>

	
</cfoutput>

<cfoutput>
	
<div class="status" id="id_plist_edit_reorder_info" style="display:none">
	<input type="button" value="#application.udf.GetLangValSec( 'cm_wd_done' )#" onclick="SaveEditedPlaylist('#q_select_playlist.entrykey#');SwitchToPlistEditMode(false);$('##id_playlist_reorder_btn').fadeIn();$('##id_plist_edit_reorder_info').hide();" />
	&nbsp;&nbsp;
	<b>#application.udf.GetLangValSec( 'cm_ph_playlist_edit_order' )#</b> - #application.udf.GetLangValSec( 'cm_ph_playlist_edit_order_description' )#
</div>


<form style="margin:0px" action="##">
<div class="div_container" id="id_add_plist_track_search" style="display:none">
<div class="confirmation">
	
	<span style="float:right"><a href="##"  onclick="$('##id_add_plist_track_search').fadeOut();return false">#application.udf.GetLangValSec( 'cm_wd_action_hide' )#</a></span>
	
	#application.udf.si_img( 'magnifier' )# #application.udf.GetLangValSec( 'cm_wd_search' )#

	<input type="text" id="searchplistaddtrack" name="searchplistaddtrack" style="width:280px;font-size:18px;padding:4px" class="b_all" />
	&nbsp;&nbsp;|
	&nbsp;&nbsp;
	

</div>
</div>
</form>	
</cfoutput>

<!--- add auto --->
<script type="text/javascript">
	AttachPlistAddTrackSearch( 'searchplistaddtrack', '<cfoutput>#jsStringFormat( q_select_playlist.entrykey )#</cfoutput>' );
</script>
</cfsavecontent>