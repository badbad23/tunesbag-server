<!---

	Short user information on the right

--->


<cfinclude template="/common/scripts.cfm">

<cfset a_struct_user_profile = event.getArg( 'a_struct_user_profile' ) />
<cfset a_str_librarykey = event.getArg( 'librarykey' ) />

<!--- not found ? --->
<cfif NOT a_struct_user_profile.result>
	<cfset request.content.final = application.udf.WriteCommonErrorMessage( 1002 ) />
	<cfexit method="exittemplate">
</cfif>

<cfset a_userdata = a_struct_user_profile.a_userdata />
<cfset q_select_favourite_artists = a_struct_user_profile.Q_SELECT_FAVOURITE_ARTISTS />
<cfset q_select_friends = a_struct_user_profile.q_select_friends />
<cfset q_select_genre_cloud_of_user = a_struct_user_profile.q_select_genre_cloud_of_user />
<cfset q_select_playlists = a_struct_user_profile.q_select_playlists />

<cfsavecontent variable="request.content.final">
<cfoutput>
<div>

	<table style="width:100%">
	
		<tr>
			<td style="padding:12px;">
				
				<cfif Len( a_userdata.getPic() ) GT 0>
					<img src="#a_userdata.getpic()#" style="vertical-align:middle;height:34px;width:30px;padding-right:4px" alt="Picture" />
				</cfif>
				#application.udf.GetLangValSec( 'cm_ph_you_are_browsing_library_of' )#

				#htmleditformat( a_userdata.getUsername() )#
			
			
			&nbsp;&nbsp;|&nbsp;&nbsp;
			<a class="add_as_tab" title="#htmleditformat( a_userdata.getUsername() )#" href="/user/#UrlEncodedFormat( a_userdata.getUsername() )#">#application.udf.GetLangValSec( 'cm_ph_view_full_profile' )#</a>
			&nbsp;&nbsp;|&nbsp;&nbsp;
			<a href="##" onclick="SimpleInpagePopup( $(this).text(), '/james/?event=messages.send&closeaftersend=true&amp;KeepThis=true&amp;recipient=#UrlEncodedFormat( a_userdata.getUsername() )#&amp;height=340&amp;width=600', false);return false;">#application.udf.GetLangValSec( 'cm_ph_send_a_message' )#</a>
			
			
			</div>
<cfif q_select_playlists.recordcount GT 0>
<td align="right" style="padding:12px">
		#application.udf.GetLangValSec( 'cm_wd_playlists' )# (#q_select_playlists.recordcount#)
		&nbsp;&nbsp;
	<select class="" style="background-color:transparent" onchange="DoNavigateToURL( 'tb:loadplist&plistkey=' + escape( this.value ) );">
		<option value="">#application.udf.GetLangValSec( 'cm_ph_please_select' )#&nbsp;&nbsp;</option>
		<cfloop query="q_select_playlists">
			<option value="#JsStringFormat( q_select_playlists.entrykey )#">#htmleditformat( q_select_playlists.name )#</option>		
		</cfloop>
	</select>
	
</td>
</cfif>
		
		</tr>
	
	</table>

<cfif a_userdata.getUsername() IS 'free.music'>	
<div style="padding:4px">

	<a href="http://www.jamendo.com" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/jamendo_small.png" style="padding:6px;vertical-align:middle;border:0px" /> Free music powered by jamendo - open your ears</a>

</div>
</cfif>	

</div>
</cfoutput>

</cfsavecontent>