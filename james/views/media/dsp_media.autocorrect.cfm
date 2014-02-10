<!--- 

	let the user dedide about media auto correction

 --->

<!--- TODO: Translate --->
<cfinclude template="/common/scripts.cfm">

<cfset a_struct_check = event.getArg( 'a_struct_check_data' ) />

<cfset q_select_next_unchecked_mediaitem = event.getArg( 'q_select_next_unchecked_mediaitem') />

<cfif q_select_next_unchecked_mediaitem.recordcount IS 0>

	<cfsavecontent variable="request.content.final">
		<div class="headlinebox">
			<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metatags' )#</cfoutput></p>
			<p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metatags_desc' )#</cfoutput></p>
		</div>
		<div class="status">
			<cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metags_no_more_item_found' )#</cfoutput>
		</div>
	</cfsavecontent>

	<cfexit method="exittemplate">
</cfif>

<cfset q_select_possible_items = a_struct_check.Q_SELECT_PUID_ALL_POSSIBLE_TRACKS />

<cfif q_select_possible_items.recordcount IS 0>

	<cfsavecontent variable="request.content.final">
		<!--- <cfoutput>#q_select_next_unchecked_mediaitem.entrykey#</cfoutput> --->
		<!--- ignore for now and reload --->
		<script type="text/javascript">
		
			<cfoutput>
			SimpleBGOperation( 'item.metadata.autofix', 'entrykey=#JsStringFormat( q_select_next_unchecked_mediaitem.entrykey )#&ignore=1',
					function(data) {
						
						DoNavigateToURL( 'tb:fixtags&rand=' + Math.random() );
						});
			</cfoutput>
		
		</script>
		
		... loading next item ... 
		
	</cfsavecontent>

	<cfexit method="exittemplate">
</cfif>

<cfsavecontent variable="request.content.final">
	
<div class="headlinebox">
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metatags' )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metatags_desc' )#</cfoutput></p>
</div>

<!--- <cfdump var="#event.getargs()#"> --->
<div class="div_container">
<div class="status">
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_fix_metatags_intro' )#</cfoutput>	
</div>
</div>

<cfoutput>
<table style="margin-left:auto;margin-right:auto;" class="tbl_td_top">
	<tr>
		
		<td>
			
			<div class="div_container">
				<div style="padding:2px;width:100%;font-weight:bold" class="bb addinfotext">
					#application.udf.GetLangValSec( 'cm_ph_fix_metatags_current_tags' )#
				</div>
			</div>
			
			<div class="div_container" style="margin-bottom:20px;width:360px">
			
					
				<div style="line-height: 160%;padding:8px;">
					
				<img src="#getAlbumArtworkLink( q_select_possible_items.orig_albumid, 75 )#" style="float:left;padding:12px;height:80px;width:80px" />

				<p style="font-weight:bold;font-size:16px;line-height:150%">#htmleditformat( q_select_possible_items.orig_artist )#<br /><span style="color:##006699">#htmleditformat( q_select_possible_items.orig_name )#</span></p>
				
				
				<p style="font-size:14px">
					#htmleditformat( q_select_possible_items.orig_album )#						
				</p>
				<p class="addinfotext">
					#application.udf.FormatSecToHMS( q_select_possible_items.orig_length )#
					<cfif Len( q_select_possible_items.orig_sequence) GT 0>
						/
							## #htmleditformat( q_select_possible_items.orig_sequence )#
					</cfif>
				</p>
			
				<p style="padding:4px">
				<a href="##" title="#application.udf.GetLangValSec( 'cm_wd_play' )#" onclick="CallItemPlayer( '#JsStringFormat( q_select_possible_items.entrykey )#', '', 0);return false">#application.udf.si_img( 'control_play_blue' )# #application.udf.GetLangValSec( 'cm_wd_play' )#</a>
				&nbsp;&nbsp;&nbsp;
				<a href="##" onclick="SimpleBGOperation( 'item.metadata.autofix', 'entrykey=#JsStringFormat( q_select_possible_items.entrykey )#&ignore=1', function() { StatusMsg('#application.udf.GetLangValSec( 'cm_wd_done' )#', 'cancel'); ShowNextItem(true); });return false">#application.udf.si_img( 'cross' )# #application.udf.GetLangValSec( 'cm_wd_ignore' )#</a>
				</p>
				</div>
			</div>
		</td>

		<td class="bl">
			<div class="div_container">
				<div style="padding:2px;width:100%;font-weight:bold" class="bb addinfotext">
					#application.udf.GetLangValSec( 'cm_wd_proposals' )#
				</div>					
			</div>
			


			<cfloop query="q_select_possible_items">
				
			<cfif q_select_possible_items.full_hit IS 1>
				<cfset a_bg_color = 'green' />
			<cfelseif q_select_possible_items.full_string_hit IS 1>
				<cfset a_bg_color = 'lightgreen' />
			<cfelse>
				<cfset a_bg_color = 'orange' />
			</cfif>
	

			<div class="div_container" style="margin-bottom:20px;width:360px <cfif q_select_possible_items.currentrow GT 10>;display:none</cfif>">
									
				<div style="line-height: 160%;padding:8px;">
					
						<img src="#getAlbumArtworkLink( q_select_possible_items.puid_albumid, 75 )#" style="float:left;padding:12px;height:80px;width:80px" />
					
							<b>#htmleditformat( q_select_possible_items.mb_artist )#</b><br /><span style="color:##006699">#htmleditformat( q_select_possible_items.mb_name )#</span></a>

							<p style="font-size:14px">#htmleditformat( q_select_possible_items.mb_album )#<cfif Len( q_select_possible_items.mb_year ) GT 0> (#htmleditformat( q_select_possible_items.mb_year )#)</cfif></p>
							<p class="addinfotext">
								#application.udf.FormatSecToHMS( q_select_possible_items.mb_length )# / ## #htmleditformat( q_select_possible_items.mb_sequence )#
								
								<cfif q_select_possible_items.is_compilation IS 1>
									/
								<i>#application.udf.GetLangValSec( 'cm_wd_compilation' )#</i>
								
							</cfif>
							</p>
							
							<div class="clear"></div>

							<p style="padding:4px" onmouseover="$(this).addClass('lightbg')" onmouseout="$(this).removeClass('lightbg')">
								#application.udf.si_img( 'tick' )# <input type="button" class="btn" value="#application.udf.GetLangValSec( 'cm_wd_apply' )#" onclick="SimpleBGOperation( 'item.metadata.autofix', 'entrykey=#JsStringFormat( q_select_possible_items.entrykey )#&mb_identifier=#JsStringFormat( q_select_possible_items.mb_identifier )#', function() { StatusMsg('#application.udf.GetLangValSec( 'cm_wd_done' )#', 'tick'); ShowNextItem(true); });" />
					&nbsp;&nbsp;&nbsp;
				
				
				<cfif q_select_possible_items.full_hit IS 1>
					#application.udf.si_img( 'bullet_green' )# #application.udf.si_img( 'bullet_green' )# #application.udf.si_img( 'bullet_green' )#
				<cfelseif q_select_possible_items.full_string_hit IS 1>
					#application.udf.si_img( 'bullet_green' )# #application.udf.si_img( 'bullet_green' )# #application.udf.si_img( 'bullet_orange' )#
				<cfelse>
					#application.udf.si_img( 'bullet_orange' )# #application.udf.si_img( 'bullet_orange' )# #application.udf.si_img( 'bullet_orange' )#
				</cfif>
							</p>
							
				</div>
				
				

			</div>
			</cfloop>
		
		
		
	</td>
	</tr>
</table>
</cfoutput>
	


<script type="text/javascript">
	function ShowNextItem(removefirst) {
		
		<cfoutput>
		DoNavigateToURL( 'tb:fixtags&rand=' + Math.random() );
		//AddNewTab( '#application.udf.GetLangValSec( 'cm_ph_fix_metatags' )#', '/james/?event=media.autocorrect');
		</cfoutput>
			
		}
		

</script>
</cfsavecontent>