<!--- 

	the welcome tour for new customers of tunesBag

 --->
<cfinclude template="/common/scripts.cfm">


<cfsavecontent variable="sHTMLGuidedTour">
<cfoutput>
<!--- Guided Tour ... very simple, very effective --->	
<div id="idGuidedTour" class="tourcontainer hidden status">
	
	<!--- a) play a track --->
	<a href="##" class="closeguide" onclick="return false" style="float:right" title="#application.udf.GetLangValSec( 'cm_wd_action_hide' )#">#application.udf.si_img( 'cross' )#</a>
	
	<div class="page welcome">
	<p class="title bb">#application.udf.GetLangValSec( 'cm_ph_salutation_hi' )#</p>
	
	<p>#application.udf.GetLangValSec( 'tour_ph_welcome' )#</p>

	<!--- welcome --->
	<p class="div_container">
		
		<!--- <img src="http://deliver.tunesbagcdn.com/images/vista/Symbol-Information.png" style="float:right" class="img64x64" alt="Information" /> --->
		
		<a href="##" onclick="PlayerTogglePlayPause();return false" style="font-weight:bold" class="navnext"><img src="http://cdn.tunesBag.com/images/skins/default/btnPlay16x16.png" class="img16x14" style="vertical-align:middle" /> #application.udf.GetLangValSec( 'tour_ph_start_w_music' )#</a>
		<br />
		<img src="http://deliver.tunesbagcdn.com/images/space1x1.png" class="img16x14" /> ft. Betsie Larkin and others
		
		<br /><br />
		<a href="##" class="navnext"><img src="http://deliver.tunesbagcdn.com/images/skins/default/playerBtnSoundOff.png"  class="img16x14" style="vertical-align:middle" /> #application.udf.GetLangValSec( 'tour_ph_start_wo_music' )#</a>
		<br /><br />
		<a href="##" class="closeguide">#application.udf.GetLangValSec( 'nav_ph_remove_box' )#</a>
	</p>

	</div>
	
	<!--- player --->
	<div class="page player">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_wd_player' )#</p>
		<p>#application.udf.GetLangValSec( 'tour_ph_player_desc' )#</p>
		<!--- <p>
			Share track now
		</p> --->
		
	</div>	
	
	<!--- upload --->
	<div class="page upload">
		<p class="title bb">#application.udf.GetLangValSec( 'lib_upload_info_title' )#</p>
		<p>
		#application.udf.GetLangValSec( 'tour_ph_upload_desc' )#
		<br /><br />
		<a href="##" onclick="OpenUploadWindow( '#JsStringFormat( application.udf.GetLangValSec( 'lib_upload_type_browser' ))#' );return false">#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
		</p>
	</div>
	
	<!--- playlists --->
	<div class="page playlists">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_wd_playlists' )#</p>
		<p>
		#application.udf.GetLangValSec( 'tour_ph_playlists_desc' )#
		<!--- <br />
		<a href="##" onclick="callNewPlaylistDialog('');return false">#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'cm_ph_create_new_playlist' )#</a> --->
		</p>
	</div>
	
	<div class="page library" title="#application.udf.GetLangValSec( 'cm_wd_library' )#">
	<p class="title bb">#application.udf.GetLangValSec( 'cm_wd_library' )#</p>
	<p>
		#application.udf.GetLangValSec( 'tour_ph_library_desc' )#
	</p>	
	</div>
	
	<div class="page dashboard" title="#application.udf.GetLangValSec( 'cm_wd_library' )#">
	<p class="title bb">#application.udf.GetLangValSec( 'cm_wd_dashboard' )#</p>
	<p>
		#application.udf.GetLangValSec( 'tour_ph_dashboard_desc' )#
	</p>
	</div>	
	
	<!--- search --->
	<div class="page search" title="#application.udf.GetLangValSec( 'cm_wd_explore' )#">
	<p class="title bb">#application.udf.GetLangValSec( 'cm_wd_explore' )# &amp; #application.udf.GetLangValSec( 'cm_wd_search' )#</p>
	<p>
		#application.udf.GetLangValSec( 'tour_ph_explore_desc' )#
		<!--- <br />
		<input type="text" name="guidesearch" value="" /> <input type="button" class="btn" value="#application.udf.GetLangValSec( 'cm_wd_search' )#" /> --->
	</p>
	<!--- <p>
		Try some popular tags: <a href="##" onclick="DoRequest('search', { 'search' : 'Pop', 'area' : '_all' } );return false;"><span class="tag_box">Pop</span></a> <a href="##" onclick="DoRequest('search', { 'search' : 'Betsie Larkin', 'area' : '_all' } );return false;"><span class="tag_box">Betsie Larkin</span></a>
	</p> --->
	</div>	
	
	<!--- update --->
	<div class="page upgrade" title="#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#</p>
		<p>#application.udf.GetLangValSec( 'tour_ph_premium_desc' )#</p>
	</div>		
	
	<!--- friends --->
	<div class="page friends" title="#application.udf.GetLangValSec( 'cm_ph_add_invite_friends' )#">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_ph_add_invite_friends' )#</p>
		<p>
			#application.udf.GetLangValSec( 'tour_ph_friends_desc' )#
		</p>
	</div>	
	
	<!--- apps --->
	<div class="page apps" title="#application.udf.GetLangValSec( 'cm_ph_applications_description' )#">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_ph_applications_description' )#</p>
		<p>
			#application.udf.GetLangValSec( 'tour_ph_apps_desc' )#
		</p>
	</div>		
	
	<!--- thank you --->
	<div class="page thankyou" title="#application.udf.GetLangValSec( 'cm_wd_library' )#">
		<p class="title bb">#application.udf.GetLangValSec( 'cm_ph_thank_you' )#</p>
		<p>
			#application.udf.GetLangValSec( 'tour_ph_thankyou_desc' )#
		</p>
		<p>
			<a href="##" class="closeguide" onclick="OpenUploadWindow( '#JsStringFormat( application.udf.GetLangValSec( 'lib_upload_type_browser' ))#' );return false">#application.udf.si_img( 'add' )# #application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
		</p>
		<p>
			<a href="##" class="closeguide" onclick="callNewPlaylistDialog('');return false">#application.udf.si_img( 'folder_add' )# #application.udf.GetLangValSec( 'cm_ph_create_new_playlist' )#
		</p>
		<p>
			<a href="##" class="closeguide" onclick="SimpleInpagePopup( '#application.udf.GetLangValSec( 'cm_ph_add_invite_friends' )#', '/james/?event=ui.simple.dialog&type=addfriend', false);return false">#application.udf.si_img( 'group_add' )# #application.udf.GetLangValSec( 'cm_ph_add_invite_friends' )#</a>
		</p>
		<p>
			<a href="##" class="closeguide">#application.udf.si_img( 'cross' )# #application.udf.GetLangValSec( 'nav_ph_remove_box' )#</a>
		</p>
	</div>		
	
	<div class="navigator" style="text-align:center;margin-top:12px;padding:3px">
		<a href="##" onlick="return false" class="navback">&lt; #application.udf.GetLangValSec( 'cm_ph_play_control_prev' )#</a>
		&nbsp;&nbsp;
		<a href="##" onclick="return false" class="navnext">#application.udf.GetLangValSec( 'cm_ph_play_control_next' )# &gt;</a>
	</div>	

</div>
</cfoutput>
</cfsavecontent>

<!--- container and init script --->
<div id="idGuidedTourContainer"></div>
<script type="text/javascript">
	
	var oGuidePage = 
	
		{
		    'htmlcontent' : '<cfoutput>#JsStringFormat( sHTMLGuidedTour )#</cfoutput>',
			'parent' : '#idGuidedTour',
			'container' : '#idGuidedTourContainer',
			'pages' : [
					   { target : '#idTabsContainer', pos : 'prepend',  className : 'welcome', expose : '#idGuidedTour', location: 'tb:library', floating: true, exposeLen: 60000 },
					   { target : '#idPlayerBox', pos : 'append',  className : 'player', expose : '#playerRight' },
					   { target : '#idTabsContainer', pos : 'prepend', className : 'library', expose : '#tab_library', location : 'tb:library', floating: true},					   
					   { target : '#idTabsContainer', pos : 'prepend', className : 'playlists', expose : '#tab_plist', location : 'tb:playlist', floating: true },
					   { target : '#idTabsContainer', pos : 'prepend', className : 'upload', expose : '#tab_upload', location : 'tb:upload', floating: true },
					   { target : '#idTabsContainer', pos : 'prepend', className : 'dashboard', expose : '#tab_dashboard', location : 'tb:dashboard', floating: true},
					   { target : '#idTabsContainer', pos : 'prepend', className : 'search', expose : '#tab_search', location : 'tb:explore', floating: true},
					   { target : '#idTabsContainer', pos : 'prepend', className : 'apps', expose : '#tab_apps', location : 'tb:apps', floating: true},					   
					   { target : '#idTabsContainer', pos : 'prepend', className : 'upgrade', expose : '#tab_upgrade', location : 'tb:upgrade', floating: true},
					   { target : '#idTabsContainer', pos : 'prepend', className : 'friends', expose : '#tab_friends', location : 'tb:friends', floating: true},
					   { target : '#idTabsContainer', pos : 'prepend', className : 'thankyou', expose : '#idGuidedTour', location : 'tb:library', floating: true}
					    ]
			
		};
	
	
	
	function launchGuidedTour() {
		var guideslides = new guideSlides(oGuidePage);
		guideslides.launch();
		}
	// 
	
</script>