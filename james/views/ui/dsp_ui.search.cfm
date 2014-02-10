<!---

	Keywords

--->

<cfset a_str_search = event.getArg( 'search' ) />
<cfset a_search_artists = event.getArg( 'search_artists' ) />
<cfset search_users = event.getArg( 'search_users' ) />
<cfset search_playlists = event.getArg( 'search_playlists' ) />

<!--- <cfinclude template="/common/scripts.cfm"> --->

<cfset q_select_artists = a_search_artists.q_select_search_artists />
<cfset q_select_user = search_users.q_select_search_users />

<cfif IsStruct( search_playlists ) AND StructKeyExists( search_playlists, 'q_select_search_plists' )>
	<cfset q_select_plists = search_playlists.q_select_search_plists />
<cfelse>
	<cfset q_select_plists = 0 />
</cfif>

<cfsavecontent variable="request.content.final">

<div class="div_container_small">

<table border="0" cellpadding="4" cellspacing="0" class="table_overview">
	<tr>
		<td style="width:50%;line-heigt:170%">
			<b><cfoutput>#application.udf.GetLangValSec( 'cm_wd_artists' )# (#q_select_artists.recordcount#)</cfoutput></b>
			
			<cfif q_select_artists.recordcount GT 0>
				<cfoutput query="q_select_artists" maxrows="10"><a href="#application.udf.generateArtistURL( q_select_artists.name, q_select_artists.id ) #" title="#htmleditformat( q_select_artists.name )#" class="add_as_tab">#htmleditformat( q_select_artists.name )#</a>, </cfoutput> ...
			</cfif>
		
		</td>
		<td style="width:50%;line-heigt:170%">
			
			<b><cfoutput>#application.udf.GetLangValSec( 'cm_wd_users' )# (#q_select_user.recordcount#)</cfoutput></b>
			
			<cfif q_select_user.recordcount GT 0>
				<cfoutput query="q_select_user" maxrows="5">#application.udf.WriteDefaultUserNameProfileLink( q_select_user.username )#, </cfoutput>...
			</cfif>
		</td>
	</tr>
</table>

<cfif IsQuery( q_select_plists ) AND q_select_plists.recordcount GT 0>

	<p style="font-weight:bold;padding:4px">
	<cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlists' )# (#q_select_plists.recordcount#)</cfoutput>
	</p>
	
	<div id="id_plist_prelisten_output" class="lightbg" style="display:none">
	</div>
	
	<cfoutput>
	<div id="id_plist_prelisten_ouput_player_info" style="display:none" class="confirmation">
	
		<table class="table_details">
			<tr>
				<td style="width:140px;text-align:center">
					<img src="http://cdn.tunesbag.com/images/space1x1.png" class="artistimg" style="height:60px" />
				</td>
				<td>
					<p class="title" style="font-weight:bold"></p>
					<p class="artist"></p>
					
					<p>
						<a href="##" onclick="a_cur_player_preview.sendEvent('STOP');$('##id_plist_prelisten_ouput_player_info').slideUp();return false">#application.udf.si_img( 'control_stop' )#</a>
						&nbsp;&nbsp;
						<span class="index"></span>
						&nbsp;&nbsp;
						<a href="##" onclick="a_cur_player_preview.sendEvent('NEXT');return false" title="#application.udf.GetLangValSec( 'cm_ph_play_next_item' )#">#application.udf.si_img( 'control_end' )#</a>
					</p>
				</td>
				<td>
				<div class="div_container">
		<input type="button" class="btn" value="#application.udf.GetLangValSec( 'cm_ph_play_list_now' )#" style="font-weight:bold" onclick="DoNavigateToURL( 'tb:loadplist&plistkey=' + escape( a_cur_preview_plist ) )" />
		&nbsp;&nbsp;&nbsp;
		<input type="button" class="btn" value="#application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_plist' )#" onclick="librariesSet.addLinkedPlist( a_cur_preview_plist, a_cur_preview_plist_userkey )" />
		</div>		
				</td>
			</tr>
		</table>
		
			
					
	</div>
	</cfoutput>
	
	<cfif q_select_plists.recordcount GT 5>
	<div style="height:120px;overflow:auto">
	</cfif>
	
	<cfoutput query="q_Select_plists">
		#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( q_select_plists.entrykey, 120 ),
									application.udf.CheckZeroString( q_select_plists.name ),
									'',
									100,
									true,
									true,
									'DoNavigateToURL( ''tb:loadplist&plistkey=#q_select_plists.entrykey#&forceplay=true'' );return false',
									true )#
	</cfoutput>
	
		
	<table class="table_overview  plist_search">
		<tbody>
		<cfoutput query="q_select_plists">
		<tr>

			<cfif q_select_plists.currentrow IS 1>
				<td rowspan="50">
					
				</td>
			</cfif>
				
			<td nowrap="true" width="25%">
				
				<cfif q_select_plists.userkey IS application.udf.GetCurrentSecurityContext().entrykey>
					<a href="##tb:loadplist&plistkey=#q_select_plists.entrykey#">
				<cfelse>
					<a href="##" styke="font-weight:bold" onclick="LoadPreviewPlist('#q_select_plists.entrykey#', '#q_select_plists.userkey#', #q_select_plists.currentrow#);return false">
				</cfif>
					
					#application.udf.si_img( 'page_white_cd' )# #htmleditformat( q_select_plists.name )#</a>			
					
				 	(#application.udf.FormatSecToHMS( q_select_plists.totaltime )#)
					
					#application.udf.GetLangValSec( 'cm_wd_by' )# #application.udf.WriteDefaultUserNameProfileLink( q_select_plists.username )#
				
				<!--- <p style="padding-left:30px">
				<a href="##" onclick="LoadPreviewPlist('#q_select_plists.entrykey#', #q_select_plists.currentrow#);return false">#application.udf.si_img( 'control_play_blue' )# Pre-Listen</a>
			
				<a href="##" onclick="librariesSet.addLinkedPlist( '#q_select_plists.entrykey#', '#q_select_plists.userkey#' );return false">#application.udf.si_img( 'folder_add' )# #application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_plist' )#</a>
				</p> --->
			</td>
			<td style="width:50%">

				#htmleditformat( q_select_plists.description )#
				<cfloop list="#q_select_plists.tags#" index="a_str_tag" delimiters=" ,"><span class="tag_box">#a_str_tag#</span> </cfloop>
				
				<!--- <p class="addinfotext">
				<cfset ii = 0 />
				<cfloop list="#q_select_plists.artists#" index="a_artist" delimiters=",">
					<cfif ii LT 5>
						#htmleditformat( a_artist )#,
						<cfset ii= ii + 1 />
					</cfif>
				</cfloop> ...
				</p> --->
			</td>
			<td width="25%">
				#WriteRatingBar( 1, '', q_select_plists.avgrating, false )#
			</td>
		</tr>
		</cfoutput>
		</tbody>
	</table>
	
	<cfif q_select_plists.recordcount GT 2>
		</div>
	</cfif>
</cfif>

</div>
</cfsavecontent>