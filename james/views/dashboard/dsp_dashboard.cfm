<!--- //

	Module:		
	Action:		Welcome screen / Dashboard
	Description:Display welcome information, new tracks, creation of custom radio station etc
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_struct_userdata = event.getArg( 'a_struct_userdata' ) />
<cfset a_struct_recommended = event.getArg( 'a_struct_recommendations' ) />
<cfset qSelectRecentlyAdded = event.getArg( 'q_select_items_recentlyadded' ) />
<cfset q_select_items_recommendations = event.getArg( 'q_select_items_recommendations' ) />
<cfset q_select_top_rated_plist_items = event.getArg( 'q_select_items_toprated' ) />
<cfset stFollowStream = event.getArg( 'stFollowStream' ) />
<cfset qSelectRecentlyPlayed = event.getArg( 'qSelectRecentlyPlayed' ) />

<cfset stQuota = event.getArg( 'a_struct_check_quota' ) />

<cfset qSyncSources = event.getArg( 'qSyncSources' ) />

<!--- recently played plists --->
<cfset qSelectRecentlyPlayedPlists = event.getarg( 'qSelectRecentlyPlayedPlists' ) />

<!--- log items --->
<cfset q_select_log_items = event.getArg( 'q_select_log_items' ) />

<!--- is flash properly installed? --->
<cfset a_str_flash_version = event.getArg( 'flashversion', '0' ) />

<!--- load top rated playlist --->
<cfset a_cmp_mediaitems = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ) />

<cfset stPossibleFriends = event.getArg( 'stExternalIdentifierData' ) />

<cfset aQuotes = ArrayNew(1) />

<cfset aQuotes[ 1 ] = [ 'Musicians don''t retire; they stop when there''s no more music in them.', 'Louis Armstrong', 1743 ] />
<cfset aQuotes[ 2 ] = [ 'My heroes are the ones who survived doing it wrong, who made mistakes, but recovered from them. ', 'Bono', 35575 ] />
<cfset aQuotes[ 3 ] = [ 'The less you know, the more you believe.', 'Bono', 35575 ] />
<cfset aQuotes[ 4 ] = [ 'Art is making something out of nothing and selling it.', 'Frank Zappa', 2101 ] />
<cfset aQuotes[ 5 ] = [ 'A man is a success if he gets up in the morning and gets to bed at night, and in between he does what he wants to do.', 'Bob Dylan', 17 ] />
<cfset aQuotes[ 6 ] = [ 'I''ve come to realize that life is not a musical comedy, it''s a Greek tragedy.', 'Billy Joel', 138 ] />
<cfset aQuotes[ 7 ] = [ 'Talent works, genius creates.', 'Robert Schumann', 32513 ] />
<cfset aQuotes[ 8 ] = [ 'Without music, life would be an error. The German imagines even God singing songs.', 'Friedrich Nietzsche', 193547 ] />

<cfsavecontent variable="request.content.final">

<div class="headlinebox">
	
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'nav_welcome_back_username', application.udf.GetCurrentSecurityContext().username )#!</cfoutput></p>
	
	<cfset iQuote = RandRange( 1, ArrayLen( aQuotes)) />
	
	<p><cfoutput><i>#htmleditformat( aQuotes[ iQuote ][ 1 ] )#</i> <a href="#application.udf.generateArtistURL( aQuotes[ iQuote ][ 2 ], aQuotes[ iQuote ][ 3 ] )#" class="add_as_tab">#htmleditformat( aQuotes[ iQuote ][ 2 ] )#</a></cfoutput></p>
</div>

	
<!--- too old version of flash? --->
<cfif a_str_flash_version LT 8>
	<div class="div_container">
	<div class="status">
		
		<h4><cfoutput>#application.udf.GetLangValSec( 'cm_ph_error_flash_not_found_out_of_date' )#</cfoutput></h4>
		<cfoutput>#application.udf.GetLangValSec( 'cm_ph_click_here_to_proceed' )#</cfoutput>:
		<br />
		<a target="_blank" href="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&amp;promoid=tunesBag"><img src="http://deliver.tunesbagcdn.com/images/partner/adobe_get_flash_player.jpg" style="border:0px;" alt="get flash player" /></a>
		</div>
	</div>
</cfif>

<!--- <div class="div_container">
	<div style="margin-left:0px;float:left;background-color:white;padding:6px;-moz-border-radius:4px;font-size:12px;font-weight:bold;border:#CACED1 solid 1px"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_playlist_recently_added' )#</cfoutput></div>
<cfoutput>
				<span class="info" style="float:right"><a style="background-color:white;padding:8px" href="##tb:loadplist&plistkey=recentlyadded"><img src="http://deliver.tunesbagcdn.com/images/skins/default/btnPlay16x16.png" class="img16x14" style="padding:6px" alt="#application.udf.GetLangValSec( 'cm_ph_play_list_now' )#" /> #application.udf.GetLangValSec( 'cm_ph_play_list_now' )#</a>
			&nbsp;&nbsp;
			
			<a href="##tb:upload" style="padding:4px;background-color:white"><img src="http://deliver.tunesbagcdn.com/images/vista/Symbol-Add-64x64.png" class="img16x14" style="padding:6px;" alt="#application.udf.GetLangValSec( 'lib_upload_info_title' )#" /> #application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
			</span>
</cfoutput>

	<div style="border-top:#CACED1 solid 1px;margin-top:12px">&nbsp;</div>
</div> --->

<!--- <div class="div_container">
	<div style="float:left;background: #EEEEEE url(https://rpxnow.com/images/label_left.png) no-repeat scroll left center;position:relative">
		<div style="font-weight:bold;padding: 2px; 10px;height: 18px;background:transparent url(https://rpxnow.com//images/label_right.png) no-repeat scroll right center">
			&nbsp;&nbsp;Recently added&nbsp;&nbsp;
		</div>
	</div>
</div>
<div class="bt">
	<div class="clear"></div>
	</div>
<div class="clear"></div> --->

<!--- <cfquery name="qSelectPrefillCount" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_prefill
FROM
	mediaitems
WHERE
	userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.udf.GetCurrentSecurityContext().userid#">
	AND
	source = 'prefill'
;
</cfquery> --->



<!--- http://flowplayer.org/tools/demos/scrollable/plugins/circular.htm --->

<cfif IsQuery( qSelectRecentlyAdded ) AND qSelectRecentlyAdded.recordcount GT -1>
	<div class="div_container">
	
	<cfoutput>
		<div class="section_header">#application.udf.GetLangValSec( 'cm_ph_playlist_recently_added' )#
			<span class="info"><a href="##tb:loadplist&plistkey=recentlyadded"><img src="http://deliver.tunesbagcdn.com/images/skins/default/btnPlay16x16.png" class="img16x14" style="padding:6px" alt="#application.udf.GetLangValSec( 'cm_ph_play_list_now' )#" /> #application.udf.GetLangValSec( 'cm_ph_play_list_now' )#</a>
			&nbsp;&nbsp;
			
			<a href="##tb:upload"><img src="http://deliver.tunesbagcdn.com/images/vista/Symbol-Add-64x64.png" class="img16x14" style="padding:6px;" alt="#application.udf.GetLangValSec( 'lib_upload_info_title' )#" /> #application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
			</span>
		</div>
	</cfoutput>
	
	<cfquery name="qSelectDistinctArtists" dbtype="query">
	SELECT
		DISTINCT( mb_artistid ),artist
	FROM
		qSelectRecentlyAdded
	;
	</cfquery>

	
	<!-- "previous page" action --> 
	<!--- <a class="prevPage browse left"></a>  --->
	<div class="scrollable scrollable95">	
		
		<!-- root element for the items -->
		<div class="items">

			<cfoutput query="qSelectDistinctArtists" maxrows="20">
				<div class="box cBox cBox95" onclick="CreateCustomRadioStation( '', { 'mbArtistIDs': '#qSelectDistinctArtists.mb_artistid#', 'maxagedays' : 21 }, 'dt_created_desc', { 'radiomode' : true, 'forceplay' : true});return false">
					<span class="header">#htmleditformat( qSelectDistinctArtists.artist )#</span>
					
					<div class="content" style="background-image:URL('#application.udf.getArtistImageByID( qSelectDistinctArtists.mb_artistid, 120 )#')">
						<img src="http://deliver.tunesbagcdn.com/images/skins/default/playerBtnPlay.png" title="#application.udf.GetLangValSec( 'cm_wd_play' )#" class="playbtn" />
					</div>
				</div>
			</cfoutput>
			
				<div class="box cBox cBox95" onclick="DoNavigateToURL( 'tb:upload' )">
					<div class="header"><cfoutput>#application.udf.GetLangValSec( 'lib_upload_info_title' )#</cfoutput></div>
					
					<div class="content" style="background-image:URL(http://deliver.tunesbagcdn.com/images/vista/My-Music-disabled-140x140.png)">
					<cfoutput>
					<img src="http://deliver.tunesbagcdn.com/images/vista/Symbol-Add-64x64.png" alt="#application.udf.GetLangValSec( 'lib_upload_info_title' )#" title="#application.udf.GetLangValSec( 'lib_upload_info_title' )#" class="playbtn" />
					</cfoutput>
					</div>

				</div>
		
		</div>
		
	</div>
	
	<div class="clear"></div>
	
	<cfif qSelectDistinctArtists.recordcount GT 5>
		<p style="text-align:center">
			<a class="prevPage browse left"><cfoutput>#application.udf.si_img( 'arrow_left' )#</cfoutput></a>
			<a class="nextPage browse right"><cfoutput>#application.udf.si_img( 'arrow_right' )#</cfoutput></a>
		</p>
	</cfif>
</cfif>

<!--- <cfoutput>
<div style="padding:0px;background-position:center center;background-image:URL('#application.udf.getArtistImageByID( 197, 120 )#');height:95px;width:95px"><div style="background-image:URL(/res/images/skins/default/cover_rahmen-1.png);width:95px;height:95px;">l</div></div>

</cfoutput> --->
</div>



<!--- SOML --->
<!--- 
<div class="clear"></div>
<div class="div_container">
<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_soundtrackofmylife' ) )#</cfoutput>
<p>
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_soundtrackofmylife_desc' )#</cfoutput>
</p>

<div class="somlcontainer">

<cfset qSOML = q_select_top_rated_plist_items />

	<cfoutput>
	<cfloop from="1" to="8" index="ii">
		<div class="outerbox">
		<div class="box<cfif qSOML.recordcount GTE ii> filled</cfif>"
		
			<cfif qSOML.recordcount GTE ii>
				style="background-image:URL('#getArtistImageLink( qSOML[ 'artist' ][ ii ], false )#')"
			</cfif>
			>
			
			
			<div style="position:absolute;font-size:40px;left:6px;color:silver">#ii#</div>
			
			<cfif qSOML.recordcount GTE ii>
			<div class="trackbox">
				<a href="##" style="font-weight:bold" onclick="CallItemPlayer( '#jsStringFormat( qSOML[ 'entrykey' ][ ii ] )#', '', 0 );return false">#htmleditformat( qSOML[ 'name' ][ ii ] )#</a>
				#application.udf.GetLangValSec( 'cm_wd_by' )#
				<a href="#application.udf.generateArtistURL( qSOML[ 'artist' ][ ii ], qSOML[ 'mb_artistid' ][ ii ])#" class="add_as_tab">#htmleditformat( qSOML[ 'artist' ][ ii ] )#</a>
			</div>
			<cfelse>
			
				<!--- upload / search --->
				<div class="trackbox" style="text-align:center;padding:6px">
				<a href="##" onclick="OpenUploadWindow( '#application.udf.GetLangValSec( 'cm_wd_upload' )#', false, 'soml');return false">#application.udf.GetLangValSec( 'lib_upload_info_title' )#</a>
				<input type="text" class="searchterm addinfotext" onclick="checkInactiveInput(this)" id="idSOMLSearch#qSOML.currentrow#" value="#application.udf.GetLangValSec( 'cm_wd_search' )#" />
				</div>
			
			</cfif>
			
		</div>
		</div>
	</cfloop>
	</cfoutput>
	<div class="clear"></div>
	<p>
	<a href="##">Manage order</a> | <a href="##">Share this playlist</a>
	</p>
</div> 
 --->



<!--- <cfdump var="#application.udf.GetCurrentSecurityContext().RIGHTS.playlist#"> --->
<cfif ISQuery( qSelectRecentlyPlayed ) AND qSelectRecentlyPlayed.recordcount GT 0>
<div class="div_container">
	
	<cfoutput>
	<div class="section_header">#application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' )#
		<span class="info"><a href="##tb:loadplist&plistkey=recentlyplayed"><img src="http://deliver.tunesbagcdn.com/images/skins/default/btnPlay16x16.png" class="img16x14" style="padding:6px" /> #application.udf.GetLangValSec( 'cm_ph_play_list_now' )#</a>
		</span>
	</div>
	</cfoutput>
	
	<!--- generate licence information --->
	<cfset stLicencePermissions = application.beanFactory.getBean( 'LicenceComponent' ).applyLicencePermissionsToRequest(securitycontext = application.udf.GetCurrentSecurityContext(),
					 sRequest = 'PLAYLIST',
					 bOwnDataOnly = true  ) />
	
	<cfset stReturn = application.udf.SimpleBuildOutput(  securitycontext = application.udf.GetCurrentSecurityContext(),
									query = qSelectRecentlyPlayed,
									type = 'internal',
									target = '##idRecentlyplayedtracks',
									setActive = false,
									force_id = '',
									columns = 'artist,album,name,rating',
									lastkey = '',
									playlistkey = '',
									options = '',
									stLicencePermissions = stLicencePermissions) />
	
	<div id="idRecentlyplayedtracks"></div>
	
	<cfoutput>#stReturn.html_content#</cfoutput>
	
	<cfif qSelectRecentlyPlayedPlists.recordcount GT 0>
	
	
	<div class="scrollable scrollable95" style="margin-top:20px">	
	
	<!-- root element for the items -->
	<div class="items">
		
		<cfoutput query="qSelectRecentlyPlayedPlists">
			
			#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( qSelectRecentlyPlayedPlists.entrykey, 120, qSelectRecentlyPlayedPlists.img_revision ),
									application.udf.CheckZeroString( qSelectRecentlyPlayedPlists.name ),
									'',
									100,
									true,
									true,
									'DoNavigateToURL( ''tb:loadplist&plistkey=#qSelectRecentlyPlayedPlists.entrykey#&forceplay=true'' );return false',
									true )#
			
			<!--- <div class="box cBox cBox95"
				title="#htmleditformat( qSelectRecentlyPlayedPlists.name )#"
				onclick="DoNavigateToURL( 'tb:loadplist&plistkey=' + '#qSelectRecentlyPlayedPlists.entrykey#&forceplay=true' )">
				<div class="header">#htmleditformat( application.udf.ShortenString( qSelectRecentlyPlayedPlists.name, 14) )#</div>
				<div class="content" style="background-image:URL('#application.udf.getPlistImageLink( qSelectRecentlyPlayedPlists.entrykey, 120 )#');">
					<img src="http://deliver.tunesbagcdn.com/images/skins/default/playerBtnPlay.png" title="#application.udf.GetLangValSec( 'cm_wd_play' )#" class="playbtn" />
				</div>
			</div> --->
		</cfoutput>
	</div>
		
	</cfif>
</div>				
</cfif>


<!--- alright, let's see --->
<cfif IsStruct( stPossibleFriends ) AND
		StructKeyExists( stPossibleFriends, 'qPossibleFriends') AND
		stPossibleFriends.qPossibleFriends.recordcount GT 0>

	<cfset qSelectPossibleFriends = stPossibleFriends.qPossibleFriends />

	<div class="div_container">
	
	<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_friends_you_might_know' ) )#</cfoutput>
	
	<div class="scrollable scrollable95">	
		
		<!-- root element for the items -->
		<div class="items">
			
			<cfoutput query="qSelectPossibleFriends">
				
				<div onclick="DoNavigateToURL('/user/#qSelectPossibleFriends.username#')" class="cBox cBox95">
					<div class="header">#htmleditformat( qSelectPossibleFriends.firstname )#</div>
					<div class="content"  style="background-image:URL('#application.udf.getUserImageLink( qSelectPossibleFriends.username, 120 )#');"></div>
				</div>
				
			</cfoutput>
			
		</div>
		
	</div>
	
	<div class="clear"></div>
	</div>
</cfif> 

<!--- follow stream --->
<!--- <cfdump var="#application.udf.GetCurrentSecurityContext().rights#">

<cfdump var="#stFollowStream#"> --->
<cfif IsStruct( stFollowStream ) AND stFollowStream.result AND stFollowStream.q_select_items.recordcount GT 0>
	<cfset q_select_playlist_items_follow = stFollowStream.q_select_items />
<div class="div_container">

	<cfoutput>
	<div class="section_header">#application.udf.GetLangValSec( 'cm_ph_playlist_followstream' )#
		
		<!--- ondemand? allow "playlist" --->

		<span class="info">
			<cfif stFollowStream.stLicencePermissions.ONDEMAND>
				<a href="##tb:loadplist&plistkey=followstream"><img src="http://deliver.tunesbagcdn.com/images/skins/default/btnPlay16x16.png" class="img16x14" style="padding:6px" /> #application.udf.GetLangValSec( 'cm_ph_play_list_now' )#</a>
				&nbsp;&nbsp;
			</cfif>

			<a href="##" onclick="SimpleInpagePopup( 'lala', '/james/?event=ui.simple.dialog&type=addfriend', false);return false"><cfoutput>#application.udf.si_img( 'group_add')# #application.udf.GetLangValSec( 'social_ph_invite_friends' )#</cfoutput></a>
		</span>
		
	</div>
	</cfoutput>

			
		<!--- followstream --->
		<cfif q_select_playlist_items_follow.recordcount IS 0>
		
			<div class="div_container addinfotext">
				<cfoutput>#application.udf.GetLangValSec( 'cm_ph_playlist_followstream_empty' )#</cfoutput>
			</div>	
		
		<cfelse>
			<div class="div_container_small addinfotext">
				<cfoutput>#application.udf.GetLangValSec( 'cm_ph_playlist_followstream_description' )#</cfoutput>
			</div>	
			
			<!--- build output --->		 
			<cfset a_struct_return = application.udf.SimpleBuildOutput(  securitycontext = application.udf.GetCurrentSecurityContext(),
					query = q_select_playlist_items_follow,
					type = 'internal', target = '##id_div_followstream_tracks', setActive = false, force_id = '',
						columns = 'artist,name,username', lastkey = '', playlistkey = 'followstream',
						options = 'smallplist,artistimg',
						stLicencePermissions = stFollowStream.stLicencePermissions ) />
		
			<div id="id_div_followstream_tracks"></div>
			
			<cfoutput>#a_struct_return.html_content#</cfoutput>
			
		</cfif>
</div>
</cfif>

<!--- external services --->
<cfif isQuery( qSyncSources ) AND qSyncSources.recordcount GT 0>
<div class="div_container">
			<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_connected_sources_devices'), '')#</cfoutput>
			
			<cfoutput query="qSyncSources">
			
				<cfswitch expression="#qSyncSources.servicename#">
					<cfcase value="dropbox">
						<div style="width:120px;float:left;text-align:center">
						<a href="http://www.dropbox.com"><img alt="" width="110" height="37" src="/res/images/partner/services/dropbox-110x37.png" border="0" /></a>
						<br />
						#application.udf.GetLangValSec( 'cm_ph_last_sync' )#: #LsDateFormat( qSyncSources.dt_lastupdate, 'mm/dd/yy')#
						<br />
						<a href="##" onclick="SimpleBGOperation( 'sync.forcenow', { servicename: 'dropbox' }, function() {
							StatusMsg( '<cfoutput>#application.udf.GetLangValSec( 'cm_ph_dropbox_scanning_started' )#</cfoutput>' )
						});return false"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_sync_now' )#</cfoutput></a>
						</div>
					</cfcase>
				</cfswitch>
			
			</cfoutput>
			
			
			<div class="clear"></div>	
</div>
</cfif>

<!--- statistics --->


<table class="tbl_td_top" style="width:100%">
	<tr>
		<!--- news feed --->
		<cfif q_select_log_items.recordcount GT 0>
		<td style="width:50%;padding:12px">
		
			
			
			
			
				
			
				<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_news_feed' ) , 'lightning' )#</cfoutput>
				
				<div class="div_container">
				<cfoutput query="q_select_log_items" maxrows="10">
					
				<cfset a_str_content = getproperty( 'beanFactory' ).getBean( 'LogComponent' ).FormatSingleLogItem( entrykey =  q_select_log_items.entrykey,
								dt_created = q_select_log_items.dt_created,
								userkey = q_select_log_items.createdbyuserkey,
								affecteduserkey = q_select_log_items.affecteduserkey,
								action = q_select_log_items.action,
								param = q_select_log_items.param,
								objecttitle = q_select_log_items.objecttitle,
								pic = q_select_log_items.pic,
								linked_objectkey = q_select_log_items.linked_objectkey,
								createdbyusername = q_select_log_items.createdbyusername,
								options =  'small,nouserimage,smartdate' ) />
								
				#a_str_content#
				</cfoutput>
				</div>
				
			

		
		</td>
		</cfif>
		<td style="width:<cfif q_select_log_items.recordcount GT 0>50<cfelse>100</cfif>%;padding:12px">
			<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_statistics' ) , 'chart' )#</cfoutput>
			
			<cfoutput>#application.udf.GetLangValSec( 'lib_ph_size_your_library', application.udf.byteConvert( Val( stQuota.CURRENTSIZE ) ) )#
				
				(#application.udf.GetLangValSec( 'shop_wd_storage' )#: #application.udf.byteConvert( stQuota.maxsize )#)
			&nbsp;
			
			<a href="##tb:upgrade">#application.udf.GetLangValSec( 'cm_ph_upgrade_account' )#</a>
			</cfoutput>
			
			<!--- <div class="clear"></div>
			<cftry>
			<cfquery name="qS" datasource="mytunesbutleruserdata">
			SELECT
				COUNT(id) AS genre_counter,
				genre
			FROM
				mediaitems
			WHERE
				LENGTH( genre ) > 3
				AND
				userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
			GROUP BY
				genre
			ORDER BY
				genre_counter DESC
			LIMIT
				10
			;
			</cfquery>
			
			<!--- <cfdump var="#qS#"> --->
			
			<cfchart format="png" showlegend="true" chartheight="360" chartwidth="360">
				<cfchartseries type="pie" query="qS" itemcolumn="genre" valuecolumn="genre_counter">
			</cfchart>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
			</cftry> --->
		</td>
	</tr>
</table>

<!---  --->
<div class="div_container" style="text-align:center">
	<!--- reload page --->
	<a href="#" onclick="$('#tab_dashboard').html('');DoRequest( 'welcome', {} );return false"><cfoutput>#application.udf.si_img( 'arrow_refresh_small' )# #application.udf.GetLangValSec( 'cm_wd_reload' )#</cfoutput></a>
	&nbsp;&nbsp;
	<!--- restart tour --->
	<!--- <a href="#" onclick="launchGuidedTour();return false;"><cfoutput>#application.udf.si_img( 'application_view_gallery' )# #application.udf.GetLangValSec( 'cont_ph_guided_tour' )#</cfoutput></a> --->
</div>

<script type="text/javascript"> 
window.setTimeout( function()
 	{
    // initialize scrollable 
    $("div.scrollable").scrollable(); 
 }, 500);
</script>

</cfsavecontent>