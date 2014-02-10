<!--- 
	
	all the tabs holding the content

 --->

<!--- user info --->
<div id="id_item_user_info" class="bt" style="display:none"></div>

<div class="clear"></div>

<div id="id_top_lookup_info" class="div_container confirmation" style="display:none"></div>

<div class="clear"></div>

<!--- dashboard tab --->

<div id="tab_dashboard" class="ui-tabs-panel"></div>
			
<!--- library tab ... --->
<div id="tab_library" class="ui-tabs-panel ui-tabs-hide" style="border-top:0px">

	<!---  output the content ... --->
	<cfoutput>#request.content.final#</cfoutput>
	
	<!--- items count --->
	<div class="clear"></div>
	

	
</div>

<!--- plist tab --->
<div id="tab_plist" class="ui-tabs-panel ui-tabs-hide">

				
				<div style="background-color:#ac2405;font-weight:bold;color:white;padding:6px;color:white;padding-left:140px">
				<cfoutput>
					<div style="float: right; width: auto;">
						<a onclick="$('##idPlaylistSelectorContainer').slideDown('slow');return false" href="##">
							<img class="sprite-smallimages sprite-btnToogleMaximizeRed" src="http://cdn.tunesBag.com/images/space1x1.png" alt="" />
						</a>
					</div>
					
					<a href="##" style="color:white" onclick="$('##idPlaylistSelectorContainer').slideDown();return false"><span>#application.udf.GetLangValSec( 'cm_wd_filter' )#</span></a>
				</cfoutput>
				</div>
				

	<div class="" id="idPlaylistSelectorContainer">
	<!--- <cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_playlists' ), '')#</cfoutput>sss --->
	
		<div style="border: 1px solid rgb(172, 36, 5);" class="div_container">
		<form style="margin:0px" id="idPlistFilterForm" action="#">
		<cfoutput>
			<p>#application.udf.GetLangValSec( 'cm_wd_show' )#
				<input type="radio" name="filter" class="filter" value="all" checked="checked" onclick="handlePlistFilter()" id="cbplistfilterall" /> <label for="cbplistfilterall">#application.udf.GetLangValSec( 'cm_wd_all' )#</label>&nbsp;
				<input type="radio" name="filter" class="filter" value="recentlyplayed" onclick="handlePlistFilter()" id="cbplistfilterrecently" /> <label for="cbplistfilterrecently">#application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' )#</label>&nbsp;
				<input type="radio" name="filter" class="filter" value="toprated" onclick="handlePlistFilter()" id="cbplistfiltertoprated" /> <label for="cbplistfiltertoprated">#application.udf.GetLangValSec( 'cm_ph_playlist_top_rated' )#&nbsp;
				<input type="radio" name="filter" class="filter" value="own" onclick="handlePlistFilter()" id="cbplistfilterown" /> <label for="cbplistfilterown">#application.udf.GetLangValSec( 'cm_wd_library_own' )#</label>
				&nbsp;&nbsp;
				
				<input type="checkbox" value="on" class="hideempty" name="hideempty" onclick="handlePlistFilter()" id="cbplistfilterhideempty" /> <label for="cbplistfilterhideempty">#application.udf.GetLangValSec( 'cm_ph_hide_empty' )#</label>
			</p>
		</cfoutput> 
		</form>
		</div>
		
		<div class="clear"></div>
		
		<div id="idPlaylistSelector" class="div_container"></div>
	</div>
	
	

	<div id="id_item_player_info_playlist" class="bb" style="display:none"></div>
	<div id="id_plist_output"></div>
	
</div>

<!--- single playlists --->
<div id="tab_loadplists" class="ui-tabs-panel ui-tabs-hide"></div>

<!--- browse music + users --->
<div id="tab_explore" class="ui-tabs-panel ui-tabs-hide">
	
	<div id="container">

		<div id="center-container">
		   <div id="infovis"></div>    
		</div>
		
		<div id="log"></div>
		
	</div>

</div>

<!--- upload tab --->
<div id="tab_upload" class="ui-tabs-panel ui-tabs-hide"><div class="content">p</div></div>

<cfsavecontent variable="sTabUpload">
<cfinclude template="../info/dsp_info.upload.cfm">
</cfsavecontent>

<span class="hidden" id="idTabUploadContent"><cfoutput>#htmleditformat( sTabUpload )#</cfoutput></span>

<!--- fix tags --->
<div id="tab_fixtags" class="ui-tabs-panel ui-tabs-hide"></div>

<!--- upgrade --->
<div id="tab_upgrade" class="ui-tabs-panel ui-tabs-hide"></div>

<!--- friends --->
<div id="tab_friends" class="ui-tabs-panel ui-tabs-hide"></div>


<!--- add on apps info --->
<div id="tab_apps" class="ui-tabs-panel ui-tabs-hide">
	<cfsavecontent variable="sAppTabContent">
	<cfinclude template="../info/dsp_info_tab_apps.cfm">
	</cfsavecontent>
</div>

<span style="display:none" id="idTabAppsContent"><cfoutput>#htmleditformat( sAppTabContent )#</cfoutput></span>

<!--- search --->
<div id="tab_search" class="ui-tabs-panel ui-tabs-hide">

	<div class="headlinebox">
		<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_wd_search' )#</cfoutput></p>
		<p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_search_description' )#</cfoutput></p>
	</div>
	<div class="summary"></div>
	
	<div class="div_container_small">
	<b><cfoutput>#application.udf.GetLangValSec( 'cm_wd_tracks' )#</cfoutput></b>
	<div class="library">
		
		
		
	
	</div>
	</div>
</div>

<!--- external content --->
<div id="tab_content" class="ui-tabs-panel ui-tabs-hide"></div>