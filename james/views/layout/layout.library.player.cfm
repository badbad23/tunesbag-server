<!---

	the player block

--->

<div id="idPlayerBox">

	<div class="inner">
	
		<!--- <div style="background-image:URL(/res/images/skins/default/bgPlayerMain.png);background-repeat:repeat-x;text-align:right;padding:4px;padding-right:20px">
			
			<a href="#" onclick="$('#albumartwork').slideToggle( 'slow', function() { 
						// set preference
					
						});return false">
				<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-smallimages sprite-btnToogleMinimizeGray" alt="" />
			</a>
		</div> --->
	
		<!--- <a href="#" onclick="loadLargeArtistImages( recSet.GetCurrentRecord().artist );return false">loadLargeArtistImages</a> --->
		<div class="bg">
		<cfoutput>
			<p style="margin:0px;padding-left:12px;text-align:center;padding-top:6px">
				<a href="##" title="#application.udf.GetLangValSec( 'lib_ph_edit_add_to_playlist' )#" onclick="var entrykey = $('##id_cur_playing_data').data('entrykey');DoRequest( 'item.addtoplist', { 'entrykey' : entrykey } );return false;">
					<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player-actions sprite-playerActionAddToPlist" alt="#application.udf.GetLangValSec( 'lib_ph_edit_add_to_playlist' )#" />	
				</a>
				&nbsp;
				<a href="##" id="id_share_btn_track" title="#application.udf.GetLangValSec( 'cm_ph_share_item' )#">
					<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player-actions sprite-playerActionShare" alt="#application.udf.GetLangValSec( 'cm_ph_share_item' )#" />	
				</a>
				&nbsp;
				<a href="##" id="id_fan_btn_track" title="#application.udf.GetLangValSec( 'lib_ph_become_fan_of_artist' )#" onclick="becomeFanOfArtist( recSet.GetCurrentRecord().mb_artistid );StatusMsg('#application.udf.GetLangValSec( 'cm_wd_done' )#');return false">
					<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player-actions sprite-playerActionArtistFan" alt="#application.udf.GetLangValSec( 'lib_ph_become_fan_of_artist' )#" />	
				</a>
				&nbsp;
				<a title="#application.udf.GetLangValSec( 'cm_wd_buy_stuff' )#" href="##" onclick="OpenPurchasePopup();return false">
					<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player-actions sprite-playerActionBuyCart" alt="#application.udf.GetLangValSec( 'cm_wd_buy_stuff' )#" />
				</a>
				
				<!--- <a href="##" title="#application.udf.GetLangValSec( 'cm_wd_rate' )#" onclick="openSimplePopup(this, 'id_popup_rating');return false">#application.udf.si_img( 'star' )# #application.udf.GetLangValSec( 'cm_wd_rate' )#</a> --->
			</p>
						
	
					</cfoutput>
		</div>
		
		<div class="bg" style="padding-top: 6px;position:relative">
		
			<!--- show when loading a new track  --->
			<p class="hidden" id="idLoadingAlbumCircle">
				<img src="http://cdn.tunesBag.com/images/skins/default/ajax-loader-big.gif" alt="loading ..." />
			</p>
			
				<!--- playlist name and next track information --->
				<div class="lightbg plistnexttrack">
					
					<p id="idPlayerPlistInformation"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlist' )#</cfoutput> <a href="#" style="font-weight:bold" class="plist_name"><!--- plist name ---></a> by <a href="##" class="plist_username"><!--- username ---></a></p>
					
					<!--- next track --->
					<p id="idPlistNextItem">
						
						<b><cfoutput>#application.udf.GetLangValSec( 'cm_ph_play_control_next' )#</cfoutput>:</b>
						<a href="##" class="artist" onclick="DoNavigateToURL( '/playlist-' + escape( $(this).text() ) );return false"><!--- artist ---></a> - <span class="name"><!--- title ---></span>
					</p>
				</div>
				
				
				


		</div>
		
		
		<!--- slider --->
		<div class="bg">
		
			<div id="slider_main_player" class="ui-slider-1"></div>
		
		</div>
		
		<!--- last bg ... buttons --->
		<div class="bglast" id="idContainerPlayerControls">

				<cfoutput>
				<table id="idPlayerControlTable">
					<tr>
						<td>
							<a href="##" onclick="_handleClick(this, 'sort', 'random');return false" style="padding: 1px" title="#application.udf.GetLangValSec( 'cm_wd_randomize' )#">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnShuffle" alt="#application.udf.GetLangValSec( 'cm_wd_randomize' )#" />
							</a>
						</td>
						<td>
							<a href="##" onclick="ChangeRepeatMode();return false" title="#application.udf.GetLangValSec( 'cm_wd_repeat' )#" id="id_btn_repeat_track" style="padding:1px">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnRepeat" alt="#application.udf.GetLangValSec( 'cm_wd_repeat' )#" />
							</a>
						</td>
						<td>
							
						</td>
						<td>
							
						</td>
						<td>
							
						</td>
						<td>
							<a href="##" onclick="handleMuteRequest();return false" title="#application.udf.GetLangValSec( 'cm_wd_volume' )#">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnSound" id="idBtnMuteState" alt="#application.udf.GetLangValSec( 'cm_wd_volume' )#" />
							</a>
						</td>
						<td>
							<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerVolumeIndicator" alt="#application.udf.GetLangValSec( 'cm_wd_volume' )#" onclick="alert( 'Not supported yet')" />							
						</td>
					</tr>
				</table>
				</cfoutput>

		</div>

	
	</div>
</div>

<cfoutput>
<div class="playerContentBox alert" id="idStatusUploadItems" style="display:none">
	<a href="##" onclick="OpenUploadWindow( '#application.udf.GetLangValSec( 'cm_ph_upload_queue_length' )#', true );return false"><span>#application.udf.GetLangValSec( 'cm_ph_upload_tunes_in_queue' )#:</span> <span class="count"></span></a>
</div>
</cfoutput>

<cfoutput>
<div class="playerContentBox alert" id="idStatusLibraryHasBeenReloaded" style="display:none">
	<a href="##tb:library"><span>#application.udf.GetLangValSec( 'cm_ph_library_has_been_reloaded' )#</span></a>
</div>
</cfoutput>

<!--- open friendship requests ... --->
<cfoutput>
<div class="playerContentBox alert" id="id_status_show_open_friendship_requests_box" style="display:none">
	<a href="##" onclick="SimpleInpagePopup( '<cfoutput>#application.udf.GetLangValSec( 'nav_friends' )#</cfoutput>', '/james/?event=user.social.friends.edit&amp;height=500&amp;width=820', false);return false" title="<cfoutput>#application.udf.GetLangValSec( 'nav_friends' )#</cfoutput>">#application.udf.GetLangValSec( 'social_ph_confirm_or_deny_friendship_request' )#</a>
</div>
</cfoutput>

<!--- // include advertisment? // --->
<cfif application.udf.GetCurrentSecurityContext().stPlan.displayads>
<!--- 	<div class="playerContentBox" style="text-align:center" id="idAdIframeSideBar"></div> --->
</cfif>

<!--- // shopping hint // --->
<div class="playerContentBox addinfotext hidden" id="idShoppingHint" style="text-align:center">
	<b><cfoutput>#application.udf.GetLangValSec( 'cm_wd_buy_stuff' )#</cfoutput></b><br />
	
	<a href="##" onclick="openPurchaseWindow('amazon');return false"><img alt="Amazon" src="http://cdn.tunesBag.com/images/partner/amazon-logo-101x24.png" style="padding:8px;width:101px;height:24px;border:0px" /></a>
	<br />
	<a href="##" onclick="openPurchaseWindow('7digital');return false">7digital</a>
	|
	<a href="##" onclick="openPurchaseWindow('itunes');return false">iTunes</a>
	|
	<a href="##" onclick="openPurchaseWindow('amiestreet');return false">Amie Street</a>

</div>


<!--- will be replaced later with real data --->
<div id="idTrackMetaData">
	<!--- comments --->
	<!--- <div class="playerContentBox">
		<p class="header"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_comments' )#</cfoutput></p>		
	</div>
	
	<!--- recommendations --->
	<div class="playerContentBox">
		<p class="header"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_recommendations' )#</cfoutput></p>
	</div> --->
</div>

<!--- CC licence --->
<div class="playerContentBox" id="idHintCCLicence" style="display:none">
	<a href="http://creativecommons.org/licenses/by-sa/3.0/" target="_blank"><img src="http://cdn.tunesBag.com/images/cc/120-88x31.png" style="border:0px;vertical-align:middle;float:left;padding-right:12px" alt="CC" /> Item licensed under a Creative Commons License</a>
</div>

<!--- <div class="playerContentBox">
	<div style="float:right;width:auto">
		<a href="#" onclick="$('#albumartwork').slideToggle( 'slow', function() { 
						// set preference
					
						});return false">
				<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-smallimages sprite-btnToogleMinimizeGray" alt="" />
			</a>
	</div>
	<b>Bag</b>
</div>

--->

