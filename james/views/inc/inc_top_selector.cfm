<!--- //

	Module:		Top Selector
	
// --->

<cfprocessingdirective pageencoding="utf-8">

<cfinclude template="/common/scripts.cfm">

<!--- confirmation box when  --->
<cfoutput>
	<div id="id_add_free_music_confirmation" style="display:none" class="confirmation">
	#application.udf.GetLangValSec( 'cm_ph_friends_friend_has_been_added_where_to_find' )#
	</div>
</cfoutput>

<div class="clear"></div>


<form id="id_frm_selector" name="id_frm_selector" action="" onsubmit="return false">
<div class="topselectorcol bb">

	<div class="div_container lightbg bt" id="id_cur_library_info" style="display:none">
		
		<cfoutput>
		#application.udf.si_img( 'application_view_tile' )# #application.udf.GetLangValSec( 'cm_ph_current_library' )#: <span id="id_cur_library_name" style="font-weight:bold">#htmleditformat( application.udf.GetCurrentSecurityContext().username )#</span>
		&nbsp;&nbsp;&nbsp;
		<a href="##" onclick="PerformListFilter( 'library' , sHostUsername, sHostLibrarykey ,sHostUserkey );return false">#application.udf.GetLangValSec( 'cm_ph_switch_to_library_own' )#</a>
		</cfoutput>
		
		<div style="float:right; width: 160px" class="bl div_container">
		
		</div>
		
		<div id="id_container_switch_user" class="lightbg">
			<!--- links to users --->
		</div>
		
		<div class="clear"></div>
	</div>
	
	<table class="table_overview">
		<thead>
			<tr>
			<cfoutput>
			<th style="width:33%;border-top-width:0px">
				
				<!--- right to browse the library? --->
				<cfif application.udf.GetCurrentSecurityContext().rights.library.ondemand IS 1>
					<div style="float:right;padding-right:10px" id="id_show_lib_switcher">
						<a class="hide" style="display:none" href="##" onclick="$('##id_cur_library_info').slideUp();$('##id_show_lib_switcher a').toggle();return false">#application.udf.GetLangValSec( 'cm_wd_action_hide' )# <img src="http://deliver.tunesbagcdn.com/images/img_arrow_sort_down.gif" style="vertical-align:middle;border:0px" alt="" /></a>
						<a class="show" href="##" onclick="$('##id_cur_library_info').slideDown();$('##id_show_lib_switcher a').toggle();return false">#application.udf.GetLangValSec( 'cm_ph_switch_library' )# (<span id="id_libraries_count_switch">0</span>) <img src="http://deliver.tunesbagcdn.com/images/img_arrow_sort_up.gif" style="vertical-align:middle;border:0px" alt="" /></a>
					</div>
				</cfif>

				#application.udf.GetLangValSec( 'cm_wd_genre' )#
			</th>
			<th style="width:33%;border-top-width:0px">
				#application.udf.GetLangValSec( 'cm_wd_artist' )#
			</th>
			<th style="width:33%;border-top-width:0px">
				#application.udf.GetLangValSec( 'cm_wd_album' )#
			</th>		
			</cfoutput>	
			</tr>	
		</thead>
		<tr>
			<cfoutput>
			<td style="padding:4px;width:33%">
				<select class="top_selector_select" style="width:100%" id="id_selector_genres" size="9" onchange="LaunchChangeTmr( 'genre' )">
					<!--- the default ALL entry --->
					<option class="_all lightbg">#application.udf.GetLangValSec( 'cm_wd_all' )#</option>
				</select>
			</td>
			<td style="padding:4px;width:33%">
<!--- <script type="text/javascript">	function mm() {
		Log( this );
		}
</script> --->
				<select class="top_selector_select" style="width:100%" id="id_selector_artists" size="9" onchange="LaunchChangeTmr( 'artist' )">		
					<option class="_all lightbg">#application.udf.GetLangValSec( 'cm_wd_all' )#</option>
				</select>
			</td>
			<td style="padding:4px;width:33%">
				<select class="top_selector_select" style="width:100%" id="id_selector_albums" size="9" onchange="LaunchChangeTmr( 'album' )">
					<option class="_all lightbg">#application.udf.GetLangValSec( 'cm_wd_all' )#</option>
				</select>
			</td>	
			</cfoutput>			
		</tr>
	</table>

</div>



<div class="clear"></div>


<cfoutput>
<div class="bb lightbg" style="padding:4px">
	<div style="float:right;padding:2px" class="addinfotext">
		<cfoutput>#application.udf.GetLangValSec( 'cm_wd_items' )#</cfoutput>: <span id="id_items_count">0</span>
	</div>
	<ul class="libraryActionButtons" id="idLibActionButtons">
		<li class="plist">
			<a href="##" class="btn inactive" onclick="DoRequest( 'item.addtoplist', { 'entrykey' : getSelectedEntrykeys() } );return false"><span>#application.udf.GetLangValSec( 'cm_wd_playlist' )#</span></a>
		</li>
		<li class="share">
			<a href="##" class="btn inactive" onclick="CallShareDlg( this, 1, getFirstSelectedOrPlayingEntrykey() );return false"><span>#application.udf.GetLangValSec( 'cm_wd_share' )#</span></a>
		</li>		
		<!--- <li class="bag">
			<a href="##" class="btn btn2"><span>#application.udf.GetLangValSec( 'cm_ph_playlist_bag' )#</span></a>
		</li> --->
		<li class="comment">
			<a href="##" class="btn inactive" title="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_edit_add_comment' )#</cfoutput>" onclick="DoRequest( 'addcomment', { 'entrykey' : getFirstSelectedOrPlayingEntrykey(), 'dlgtitle' : escape( this.title ) } );return false"><span>#application.udf.GetLangValSec( 'cm_wd_comment' )#</span></a>
		</li>
		<li class="edit">
			<a href="##" class="btn inactive" title="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_edit_meta_information' )#</cfoutput>" onclick="DoRequest( 'editmetainformation', { 'entrykeys' : getSelectedEntrykeys(), 'dlgtitle' : escape( this.title ) });return false"><span>#application.udf.GetLangValSec( 'cm_wd_edit' )#</span></a>
		</li>
		<li class="delete">
			<a href="##" class="btn inactive" onclick="DoRequest( 'item.delete' , { 'entrykey' : getSelectedEntrykeys() });return false"><span>#application.udf.GetLangValSec( 'cm_wd_delete' )#</span></a>
		</li>
	</ul>
	<div class="clear"></div>
</div>
</cfoutput>


<!--- 
<div style="display:none">
<table width="100%" class="table_top_selector" cellpadding="0" cellspacing="0" border="0" id="id_test123" style="displaynone">
	<tr class="tr_top_selector_header">
		<td><cfoutput>#application.udf.GetLangValSec( 'cm_wd_genre' )#</cfoutput></td>
		<td><cfoutput>#application.udf.GetLangValSec( 'cm_wd_artist' )#</cfoutput></td>
		<td>
			<!--- <span style="float:right">
					<a href="#" onclick="$('#id_test123').slideUp();$('#id123123').slideDown();">Hide</a>
			</span> --->
			<cfoutput>#application.udf.GetLangValSec( 'cm_wd_album' )#</cfoutput>
		</td>
	</tr>
	<tr>
		<td id="table_top_selector_col_1">
			
			<div>
				<ul onmouseover="StartMagnifySelectBoxTimer(this.id);" onmouseout="StartDeMagnifySelectBoxTimer(this.id);" id="id_select_genre" class="ul_nopoints ul_top_selector"></ul>
			</div>
			
		</td>
		<td>
			
			<div>
				<ul onmouseover="StartMagnifySelectBoxTimer(this.id);" onmouseout="StartDeMagnifySelectBoxTimer(this.id);" id="id_select_artist" class="ul_nopoints ul_top_selector"></ul>
			</div>
			
		</td>
		<td>

			<div>
				<ul onmouseover="StartMagnifySelectBoxTimer(this.id);" onmouseout="StartDeMagnifySelectBoxTimer(this.id);" id="id_select_album" class="ul_nopoints ul_top_selector"></ul>
			</div>
		
		</td>
	</tr>
</table>
</div> --->
</form>
