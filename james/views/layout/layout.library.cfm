<!--- //

	Module:		Default main layout
	Description:The main lib view and player
	
// --->

<cfprocessingdirective pageencoding="utf-8">

<cfset sCustomStyleSheet = event.getArg('pref_skin') />
<cfset a_struct_userdata = event.getArg( 'a_struct_userdata' ) />
<cfset q_select_preferences = event.getArg( 'q_select_preferences' ) />

<cfset bDisplayGuidedTour = event.getArg( 'bDisplayGuidedTour', 1 ) />
<!--- <cfset a_str_searches = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey, name = 'search.history', defaultvalue = '' ) />
 --->
<cfset a_str_translation_ids = 'er_ph_9000,cm_wd_delete,lib_ph_drag_drop_insert_before_this_item,cm_ph_switch_to_library_own,cm_ph_create_new_playlist,cm_ph_play_control_play,nav_preferences,cm_ph_play_control_pause,cm_wd_by,cm_wd_libraries,lib_ph_action_show_artist_information,lib_ph_action_show_album_information,cm_ph_times_played_count,cm_wd_created,cm_ph_no_subject,cm_wd_actions,cm_wd_counter,cm_wd_all,cm_wd_information,cm_wd_items,cm_ph_more_options,cm_wd_done,cm_ph_loading_please_wait,cm_wd_playlists,cm_wd_more_link_to,cm_wd_podcasts,cm_ph_news_feed,lib_ph_edit_add_to_playlist,cm_wd_users,cm_wd_artist,cm_wd_shuffle,cm_wd_album,cm_wd_name,cm_wd_title,cm_ph_track_number,cm_ph_library_has_been_reloaded,cm_ph_track_no_short,cm_wd_select,cm_wd_rating,cm_ph_friends_friend_has_been_added_where_to_find' />

<!--- dev server? --->
<cfset bDevServer = application.udf.IsDevelopmentServer() />

<cfset bDevServer = true>

<!--- location of scripts --->
<cfif bDevServer>
	<cfset a_scripts_prefix = '/res' />
<cfelse>
	<cfset a_scripts_prefix = 'http://res.tunesBag.com' />
</cfif>

<cfsavecontent variable="request.content.final">
	
<!DOCTYPE HTML>
<html lang="en">
<head>
	
	<meta http-equiv="content-type" content="application/xhtml+xml; charset=UTF-8" />
	<title>tunesBag | <cfoutput>#htmleditformat( a_struct_userdata.getUsername() )#</cfoutput></title>

	<link rel="stylesheet" href="/res/css/default.css" />
		
	<link rel="stylesheet" type="text/css" href="/res/css/jit/base.css" />
	
	<style media="all" type="text/css">
		body.body_default {
		<cfif Len( event.getarg( 'pref_design_bg_color' ) ) GT 0>
			background-color:<cfoutput>#event.getarg( 'pref_design_bg_color' )#</cfoutput>;
		</cfif>
		<cfif a_struct_userdata.getbgimage() NEQ ''>
			background-image:URL('<cfoutput>#htmleditformat( a_struct_userdata.getbgimage() )#?#CreateUUID()#</cfoutput>');
			background-attachment: fixed;
			background-repeat: repeat;
		</cfif>
			}
		
	</style>
	
	

	<!--- support for both browsers ... --->
	<link rel="shortcut icon" href="http://cdn.tunesBag.com/images/favicon.ico" type="image/x-icon" />		
	<link rel="icon" type="image/png" href="http://cdn.tunesBag.com/images/favicon-32px.png" />
	
	<!--- jquery-1.3.2.min.js --->
	<cfset arJSFiles = [ 'jquery-1.4.min.js', 'swfobject.2.1.js', 'ui/jquery-ui-1.8rc3.custom.min.js', 'jquery.tools.min.js',
			'jquery.thickbox.js',  'jquery.form.js', 'plugins/jquery.bgiframe.min.js', 'plugins/jquery.autocomplete.pack.js', 
			'tweaks.js','james/james.basic.js', 'james/james.interface.js', 'james/james.data.js', 'jit/jit.js', 'jit/datasource.js' ] />

	
		<cfloop from="1" to="#ArrayLen( arJSFiles )#" index="ii">
			<script type="text/javascript" src="/res/js/<cfoutput>#arJSFiles[ ii ]#?#CreateUUID()#</cfoutput>"></script>
		</cfloop>

	<script src="http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js" type="text/javascript"></script>
	
	<!--- <script type="text/javascript">
		var _moq = _moq || [];
		_moq.push( [ '_setAppId', '123' ] );
	    _moq.push( [ '_setAuth', 'custom' ] );	   
	    _moq.push( [ '_setHost', 'http://moosifyconnect.local' ] );	   
	    // get custom instructions
	    _moq.push( [ '_setCustomJS', '/res/js/tunesbag.moosify.connect.js' ] );
	    _moq.push( [ '_setNavigationMode', 'custom' ] );	    
	    _moq.push( [ '_setDisplayMode', 'dialog' ] );	    
	    _moq.push( [ '_setShowBar', true ] );	    	    
	    
	    // subscriptions
	    _moq.push( ['_subscribe', 'onNotificationsUpdate', function( data ) {
	    	$('#notifications').html( data.count_unread ).show();
	    	} ]);
	    	
	     _moq.push( ['_subscribe', 'onMediaUpdateUserDiscovered', function( data ) {
			
	    	} ]);
	    	
	    _moq.push( ['_subscribe', 'onResolveMediaItem', function( data ) {
			// alert( 'resolving media item to local platform: ' + data.artist + ': ' + data.track );
			
			playTrack( data.artist, data.track );
	    	} ]);
	
		// add script
	    (function() {
	      var moo = document.createElement('script'); moo.type = 'text/javascript'; moo.async = true;
	      moo.src = 'http://moosifyconnect.local/js/moosify.connect.js?<cfoutput>#createuuid()#</cfoutput>';
	      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(moo, s);
	    })();
		
		</script> --->
	
	<!--- include this one manually as it does not work with yuicompressor --->
	<script type="text/javascript" src="/res/js/plugins/ajaxupload.3.1.js"></script>
	
	<!--- <cfif application.udf.getCurrentSecurityContext().username IS 'funkymusic'>
		
		<!--- incldue socket stuff --->
		<script type="text/javascript" src="/res/js/websockets/FABridge.js"></script>
		<script type="text/javascript" src="/res/js/websockets/web_socket.js"></script>
		
		<script type="text/javascript" src="/res/js/james/james.remotecontrol.js"></script>
		
		<!--- todo: move to after load --->
		<script type="text/javascript">
			<cfoutput>
				wsinit('#JsStringFormat( a_struct_userdata.getUsername() )#', '#JsStringFormat( getProperty( 'beanFactory' ).getBean( 'Environments' ).getProperty( 'WSServer' ))#');
			</cfoutput>	
		</script>
		
	</cfif> --->
	
	<meta name="author" content="(c) tunesBag.com Limited" />
	<meta name="description" content="tunesBag - Listen to your music anywhere!" />
	
	<!--- data to load when DOM has been loaded --->
	
	<!--- the very basic variables --->
	<script type="text/javascript">
	var sHostUsername = '<cfoutput>#a_struct_userdata.getUsername()#</cfoutput>';
	var sHostUserkey =  '<cfoutput>#a_struct_userdata.getEntrykey()#</cfoutput>';
	var sHostLibrarykey = '<cfoutput>#event.getArg('a_str_default_library')#</cfoutput>';
	var sHostLibraryLastkey = '<cfoutput>#event.getArg( 'sHostLibraryLastkey' )#</cfoutput>';

	$( function(){
		
		// main JS init
		<cfoutput>
		InitService('#JsStringFormat( a_struct_userdata.getEntrykey() )#', '#JsStringFormat( event.getArg('a_str_default_library') )#', #SerializeJSON( application.udf.GetCurrentSecurityContext().rights )#, 'minimal');
		</cfoutput>
		
		// init hoverc etc
		InitDisplayRoutines();
		
		<!--- output translations --->		
		<cfloop list="#a_str_translation_ids#" index="a_str_id"><cfoutput>langSet.add( '#a_str_id#', '#JSStringFormat( application.udf.GetLangValSec( a_str_id ))#');</cfoutput></cfloop>

		<cfoutput query="q_select_preferences">prefSet.storePreference( '#JsStringFormat( q_select_preferences.name  )#', '#JsStringFormat( q_select_preferences.value )#' );</cfoutput>
		
		highlightActiveTab();
		
		// create preview player and check for links to convert
		window.setTimeout( function() {
			CreateDefaultMediaPlayer();
	   		CreatePreviewMediaPlayer();
	   		
	   		CheckConvertLinksToAddTab( $('#body_default').html() );
	   		
	   		// fire first keep alive query
	   		KeepAliveQuery();
	   		}, 500);
	   	
		
		// set initial counters / indicators after 5 seconds
		window.setTimeout( "KeepAliveQuery()", 1000 );	
		
       });
       
       
     // append to resizing function
     $(window).resize(function(){
     	launchAdaptPageWidthEvent();
     	});
     	
     // start with library or recently used tab
     $(window).load( function () {
     		if ((location.hash.substr(1) === '') || (location.hash.substr(1) === '#')) { location.href = '#tb:library' ;}
     		
     		// reload sidebare
     		window.setTimeout( function() {
     			reloadSideBarAd();
     			}, 500);
     			
     		// show guide?
     		<!--- if (<cfoutput>#bDisplayGuidedTour#</cfoutput> == 1) {
     			launchGuidedTour();
     			} --->
     		
     	}); 
     
	</script>
	
	
	<!--- scripts to execute --->
	<cfset request.bSubscribers = true />
	<cfinclude template="inc_tracking.cfm">
</head>

<body class="body_default" onclick="_handleGeneralClick( event )">
	
<div style="background-color:#FFFCCA; border: #E2C822 solid 1px;padding: 8px;text-align:center">
	tunesBag is shutting down at the end of May 2013, please backup any uploaded data. It was great having you here :)
</div>
	
<!--- status / error message --->	
<div id="idStatusMsg" style="display:none"></div>
	
<!--- top player bar --->
<div style="position:fixed;z-index:99;width:100%;background-image:URL(/res/images/june12/bgtop-bar.png);height:65px;border-bottom:#a5a5a5 solid 1px">

	<cfoutput>
	<a href="##tb:dashboard" title="#application.udf.GetLangValSec( 'cm_wd_home' )#"><img src="http://cdn.tunesBag.com/images/skins/default/bgLogoLeftTop.png" alt="#application.udf.GetLangValSec( 'cm_wd_home' )#" class="" style="position:absolute;left:8px" /></a>
	</cfoutput>
	
	<div style="position:absolute;right:0px;top:4px">
		
		<!--- mini menu on top --->
			<div class="topsmallheader" id="idTopHeaderUserMenu1">
				<cfoutput>
				<ul>
					<li
					<cfif a_struct_userdata.getphotoindex() GT 0>
						 style="padding-left:38px;background-image:URL( '#application.udf.getUserImageLink( a_struct_userdata.getUsername(), 30 )#' );background-repeat:no-repeat;background-position:left center"
					</cfif>
					
					>
						<a onclick="openSimplePopup( this, 'id_popup_user' );return false" href="##" title="#application.udf.GetCurrentSecurityContext().username#">#application.udf.GetLangValSec( 'cm_ph_signed_in_as_user', application.udf.GetCurrentSecurityContext().username )# <cfif application.udf.GetCurrentSecurityContext().accounttype GT 0>[PRO]</cfif>
						<img src="http://cdn.tunesBag.com/images/img_arrow_sort_down.gif" style="vertical-align:middle;border:0px" alt="" /></a>
					</li>
				</ul>
				</cfoutput>
				
			</div>
		
		<div style="text-align:right;padding-right: 12px;padding-top:12px">
		<input type="text" name="search" onkeyup="if (event.keyCode == 13) { DoRequest('search', { search: this.value });  }"  style="padding:4px;border-radius:6px;border:silver solid 1px" />
		</div>
	</div>
	
	<!--- player --->
	<div style="position:absolute;left:140px;">
	
		
		<div style="float:left;padding-top:18px">
						<cfoutput>	<a href="##" onclick="PlayPreviousNextItem( -1 , false);return false" title="#application.udf.GetLangValSec( 'cm_ph_play_previous_item' )#">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnBack"  alt="#application.udf.GetLangValSec( 'cm_ph_play_previous_item' )#" />
							</a>
							
							<a href="##" onclick="PlayerTogglePlayPause();return false" id="id_player_controls_playpause" title="#application.udf.GetLangValSec( 'cm_ph_play_pause_play' )#">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnPlay"  alt="#application.udf.GetLangValSec( 'cm_ph_play_previous_item' )#" />
							</a>
							
							<a href="##" onclick="PlayPreviousNextItem( 1 , false);return false" title="#application.udf.GetLangValSec( 'cm_ph_play_next_item' )#">
								<img src="http://cdn.tunesBag.com/images/space1x1.png" class="sprite-player sprite-playerBtnForward"  alt="#application.udf.GetLangValSec( 'cm_ph_play_next_item' )#" />
							</a></cfoutput>

		</div>
		
		<div style="float:left;padding-top:10px;padding-left:12px">
<!--- 										<div id="albumartwork" title="<cfoutput>#application.udf.GetLangValSec( 'cm_wd_album' )#</cfoutput>" style="position:relative;top:auto;bottom:auto;left:auto;right:auto" />	 --->
											
														
				<a href="#" class="data_holder" onclick="_handleGotoAlbumArtwork(this);return false"><img src="http://cdn.tunesBag.com/images/skins/default/coverDefault.png" class="artwork" alt="artwork" style="width:48px;height:48px;border-radius: 4px;" /></a>


		</div>
		
		<div style="float:left;padding-top:10px;padding-left:12px">
			<p id="PlayerCurTitle"><span>Title</span></p>
			<p id="PlayerCurArtist"><a href="##" onclick="DoNavigateToURL( '/playlist-' + escape( $(this).text() ) );return false">Artist</a></p>
			<span id="PlayerTrackSource" class="hidden addinfotext"></span>
			
			<span id="id_mpl_time_played" class="mpl_time_info" style="left: 0px;bottom: 0px;top:auto;right: auto">00:00</span>
			/
			<span id="id_mpl_time_total" class="mpl_time_info">00:00</span>
		</div>
		
	</div>

</div>

<!--- spacer --->
<div style="height:66px"></div>

<!--- write box using JS to start with the right width --->

		<div id="id_content_main">

		<div style="position:fixed;width:110px;padding-top:80px;background-image:URL(http://cdn.tunesbag.com/images/skins/minimal/page_bg.png);width:140px;background-repeat:no-repeat;">
			

		<div class="clear"></div>
		
		<!--- menu --->
		<ul class="ul_left_nav" id="idMainNav">
			<li class="onair"><a href="#tb:dashboard"><cfoutput>#GetLangVal( 'cm_wd_home' )#</cfoutput></a></li>
			<li><a href="#tb:explore"><cfoutput>#GetLangVal( 'cm_wd_explore' )#</cfoutput></a></li>			
			<li><a href="#tb:library"><cfoutput>#GetLangVal( 'cm_wd_library' )#</cfoutput></a></li>
			<li><a href="#tb:playlist"><cfoutput>#GetLangVal( 'cm_wd_playlists' )#</cfoutput></a></li>
			<li><a href="#tb:upgrade"><cfoutput>#GetLangVal( 'cm_wd_upgrade' )#</cfoutput></a></li>
			<li><a href="#tb:upload">+ Add music</a></li>			
		</ul>
		<br />		
		<ul class="ul_left_nav">
			<li><a href="#tb:apps">Link devices</a></li>			
		</ul>
		
				
				
			</div>
			
				
</div>
		
		</div>


<table class="tbl_main" border="0">
<tr>
	<td class="left">
		<!--- logo --->
	</td>
	<td>
		<div>
			<div id="idTopAreaBox">
			
			<!--- spacer --->
			<!--- <div style="height:12px" class="clear" id="idSpacerTop"></div> --->
			
			<!--- main navigation --->
			<!--- <div class="mainnav_container">
				<div class="filled">
				
					<!--- <cfoutput>
					<div class="searchbox" onmouseover="$('.searchbox').removeClass( 'invisible' );$(this).remove();">#application.udf.si_img( 'magnifier' )# Search</div>
					</cfoutput> --->
					<div class="searchbox">
						<cfoutput>
						<form action="##" id="id_form_top_search" onsubmit="DoRequest('search', { 'search' : jQuery.trim( document.forms.id_form_top_search.searchterm.value ), 'area' : $('##search_area').val() } );return false;" style="margin:0px">
							
							<p style="width:auto">							
								<input type="hidden" name="search_area" id="search_area" value="_all" />
								<input type="text" name="searchterm" id="searchterm" class="addinfotext searchterm" onclick="checkInactiveInput(this)" value="#application.udf.GetLangValSec( 'cm_wd_search' )# ..." style="padding:6px" />
								<!--- <input type="submit" value="#application.udf.GetLangValSec( 'cm_wd_search' )#" class="btn" /> --->
							</p>
							
						</form>
						</cfoutput>
						<!--- <div style="position:absolute;"></div> --->
					</div>
			
			
					<!--- the main navitation --->
					<cfoutput>
					<ul class="mainnav" id="idMainNav" style="display:none">
						<li>
							<a href="##tb:dashboard" class="dashboard"><span>#application.udf.GetLangValSec( 'cm_wd_home' )#</span></a>
						</li>
						<li>
							<a href="##tb:library" class="library"><span>#application.udf.GetLangValSec( 'cm_wd_library' )#</span></a>
						</li>
						<li>
							<a href="##tb:playlist" class="playlist"><span>#application.udf.GetLangValSec( 'cm_wd_playlists' )#</span></a>
						</li>
						<li>
							<a href="##tb:explore" class="explore"><span>#application.udf.GetLangValSec( 'cm_wd_explore' )#</span></a>
						</li>
						<cfif application.udf.GetCurrentSecurityContext().accounttype LT 100>
							<li style="position:relative">
								<!--- 
								
									long time customer or iPhone customer
								
								 --->
								<cfif application.beanFactory.getBean( 'UserComponent' ).isIPhoneCustomer( application.udf.GetCurrentSecurityContext().entrykey )>
								<span style="position:absolute;right:-8px;top:-16px;z-index:98;background-image:URL(http://cdn.tunesbag.com/images/skins/default/bg2ndNav-active.png);color:white;font-weight:bold;padding:2px;-moz-border-radius: 4px">Special</span>
								</cfif>
								
								<a href="##tb:upgrade" class="upgrade"><span style="z-index:99">#application.udf.GetLangValSec( 'cm_wd_upgrade' )#</span></a>
							</li>
						</cfif>
					</ul>
					</cfoutput>
			
				<div class="clear"></div>
				

			
			</div>
		</div> --->
		
		<!--- secondary navigation container --->
		<div class="secondnav_container nobg" id="idSecondNav">
		
			
			<!--- here we have now the various containers for various areas --->
			
			<div class="library hidden contentbox">
			
				<!--- <div>
					<cfoutput>
					<ul class="secondnav parent_library" id="idTopNavLibrary" title="library">
						<li>
							<a href="##tb:library" class="active library"><span>#application.udf.GetLangValSec( 'cm_ph_my_library' )#</span></a>
						</li>
						<li>
							<a href="##tb:upload" class="upload"><span>#application.udf.GetLangValSec( 'lib_upload_info_title' )#</span></a>
						</li>
						<li>
							<a href="##tb:fixtags" class="fixtags"><span>#application.udf.GetLangValSec( 'cm_ph_fix_metatags' )#</span></a>
						</li>
					</ul>
					</cfoutput>
				</div>
				
				<div class="clear"></div>
				
			</div> --->
			
			<div class="playlist hidden contentbox">
				
				<div>
					<cfoutput>
					<ul class="secondnav" title="playlist">
						<li>
							<a href="##tb:playlist" class="active playlist" onclick="$('##idPlaylistSelectorContainer').slideDown('slow');"><span>#application.udf.GetLangValSec( 'cm_ph_show_all_items' )#</span></a>
						</li>
						<!--- <li>
							<a href="##tb:loadplist&plistkey=toprated"><span>#application.udf.GetLangValSec( 'cm_ph_playlist_top_rated' )#</span></a>
						</li>
						<li>
							<a href="##tb:loadplist&plistkey=recentlyplayed"><span>#application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' )#</span></a>
						</li> --->
						<li>
							<a href="##" id="lnknewplistnav" onclick="callNewPlaylistDialog('');return false"><span>#application.udf.GetLangValSec( 'cm_ph_create_new_playlist' )#</span></a>
						</li>
						<li>
							<a href="##tb:playlist" class="active loadplist hidden"><span>#application.udf.GetLangValSec( 'cm_ph_now_playing' )#</span></a>
						</li>
						
					</ul>
					</cfoutput>
				</div>
				
				<div class="clear"></div>
			</div>
			
			<div class="upgrade hidden contentbox"></div>
		
			<div class="clear"></div>
		</div>
		
		
		</div>
		<div class="clear"></div>
				
		<!--- include all content containers --->
		<div id="idTabsContainer" class="bl">
			<cfinclude template="layout.library.content.cfm">
			<div class="clear" />
		</div>
		
		<!--- footer --->
		<div class="bt div_container" id="idFooterLibrary">
			<p class="addinfotext">
				<cfoutput>#application.udf.GetLangValSec( 'cm_wd_links' )#</cfoutput>:
				&nbsp;&nbsp;
				<a href="/rd/feedback/" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_feedback' )#</cfoutput></a>
				&nbsp;&nbsp;
				<a href="http://blog.tunesBag.com" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'nav_blog' )#</cfoutput></a>
				&nbsp;&nbsp;
				<a href="/rd/contact/" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'nav_wd_contact' )#</cfoutput></a>
				&nbsp;&nbsp;
				<a href="/rd/api/" target="_blank">API</a>
				&nbsp;&nbsp;
				<a href="http://twitter.com/tunesBag" target="_blank" title="tunesBag on twitter">@tunesBag</a>
				&nbsp;&nbsp;
				<a href="/rd/terms/" target="_blank"><cfoutput>#application.udf.GetLangValSec( 'nav_wd_terms' )#</cfoutput></a>
			</p>
		</div>
	
	</td>
	<!--- <td class="right" id="playerRight">
		
		<!--- container for stuff to move right here --->
		<div id="idPlayerRightTopBox"></div>
		
		<cfinclude template="layout.library.player.cfm">
	</td> --->
</tr>
</table>
</div>

<!--- <div id="" style="position:fixed;bottom:0px;height:60px;left:0px;right:0px;top:auto;background-color:white" class="bt">




</div> --->


<!--- info bar --->
<div id="id_cur_playing_banner"><p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_now_playing' )#</cfoutput></p><p class="output"></p></div>

<!--- currently playing data holder --->
<div id="id_cur_playing_data"></div>

<div class="clear"></div>

<cfinclude template="layout.library.menus.cfm">

<!--- // item properties end // --->


<!--- include guided tour --->
<cfinclude template="../content/guidedtour/dsp_inc_welcome_tour.cfm">

<!--- playing around --->
<!--- <cfif NOT application.udf.IsDevelopmentServer()>
	<script src="http://feedback.tunesBag.com/pages/general/widgets/tab.js?alignment=right&amp;color=F78204" type="text/javascript"></script>
</cfif> --->

<!--- <script type="text/javascript">
  (function() {
    var uv = document.createElement('script'); uv.type = 'text/javascript'; uv.async = true;
    uv.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'widget.uservoice.com/rY6YQwcktFSMysLBdk5uEA.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(uv, s);
  })();
</script> --->

<!--- <script type="text/javascript" src="http://include.reinvigorate.net/re_.js"></script>
<script type="text/javascript">
try {
var re_name_tag = "<cfoutput>#JsStringFormat( application.udf.GetCurrentSecurityContext().username )#</cfoutput>";
reinvigorate.track("36161-r9547bcg80");
} catch(err) {}
</script> --->
</body>
</html>
</cfsavecontent>