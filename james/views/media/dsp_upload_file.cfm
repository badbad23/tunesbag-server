<!--- //

	Module:		Upload some files
	Description:	
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfset a_bol_upload_running = event.getArg('uploadrunning', false) />
<cfset a_struct_processing_queue = event.getArg( 'a_struct_processing_queue' ) />

<cfset a_struct_check_quota = event.getArg( 'a_struct_check_quota' ) />

<!--- upload to a certain playlist? --->
<cfset a_str_plistkey = event.getArg( 'playlistkey' ) />

<!--- entrykey of this upload run AND authentification key --->
<cfif NOT a_bol_upload_running>
	
	<cfset a_auth_info = event.getArg( 'AuthInfo' ) />
	<cfset a_str_uploadrunkey = a_auth_info.runkey />
	<cfset a_str_authkey = a_auth_info.Authkey />
	
	<cfset q_select_playlists = event.getArg( 'q_select_items' ) />
	
	<cfquery name="q_select_playlists" dbtype="query">
	SELECT
		*
	FROM
		q_select_playlists
	WHERE
		dynamic = 0
		AND
		istemporary = 0
		AND
		userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
	ORDER BY
		name
	;
	</cfquery>
</cfif>



<!--- an upload has been started --->
<cfif a_bol_upload_running>

	<cfset bFirstRun = event.getArg( 'bFirstrun', false ) />
	
	<cfif bFirstRun>
		<cfsavecontent variable="request.content.final">
			<cfoutput>
			<div class="headlinebox headlinebox_small">
				<p class="title">#application.udf.GetLangValSec( 'lib_upload_info_title' )#</p>
				<p><a href="##" onclick="window.close();">#application.udf.GetLangValSec( 'nav_ph_close_this_window_now' )#</a></p>
			</div>
			
			<img src="http://cdn.tunesBag.com/images/vista/Web-page.png" style="width:50px;border:0px;position:absolute;left:15px;top:10px" alt="<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput>" />
			
			<div class="div_container">
			<div class="status">
				<img src="http://cdn.tunesBag.com/images/spinner-16x16.gif" class="si_img" /> #application.udf.GetLangValSec( 'cm_ph_upload_please_give_a_second' )#
			</div>
			</div>
			</cfoutput>
			
			<cfsavecontent variable="a_str_meta_refresh">
				<meta http-equiv="refresh" content="30;URL=/james/?event=media.upload&amp;uploadrunning=true" />
			</cfsavecontent>
				
			<cfhtmlhead text="#a_str_meta_refresh#">
		</cfsavecontent>
		
		<cfexit method="exittemplate">
	</cfif>
	
	<cfsavecontent variable="request.content.final">
	
		<cfoutput>
			
			<div class="headlinebox headlinebox_small">
				<p class="title">#application.udf.GetLangValSec( 'lib_ph_upload_number_of_items_in_processing_queue', a_struct_processing_queue.q_select_items.recordcount  )#</p>
				<p><a href="##" onclick="window.close();">#application.udf.GetLangValSec( 'nav_ph_close_this_window_now' )#</a></p>
			</div>
			
			<img src="http://cdn.tunesBag.com/images/vista/Web-page.png" style="width:50px;border:0px;position:absolute;left:15px;top:10px" alt="<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput>" />
			
			<div class="div_container">
			
			
			
			<div class="confirmation">
			#application.udf.GetLangValSec( 'ib_upload_info_uploaded_processing' )#
			<br />
			#application.udf.GetLangValSec( 'lib_ph_upload_will_be_refreshed_all_30_seconds' )#
			</div>
			
			<cfif IsStruct( a_struct_processing_queue ) AND a_struct_processing_queue.result AND a_struct_processing_queue.q_select_items.recordcount GT 0>
				
				
				<br />				
				<table class="table_overview">
					<thead>
						<tr>
						<th class="bb">
							#application.udf.GetLangValSec( 'cm_wd_filename' )#
						</th>
						<th class="bb">
							#application.udf.GetLangValSec( 'cm_wd_created' )#
						</th>
						<th class="bb">
							#application.udf.GetLangValSec( 'cm_wd_status' )#
						</th>
						</tr>
					</thead>
					<tbody>
					<cfloop query="a_struct_processing_queue.q_select_items">
						<tr>
							<td>
								#htmleditformat( GetFileFromPath( a_struct_processing_queue.q_select_items.location ))#
							</td>
							<td>
								#TimeFormat( a_struct_processing_queue.q_select_items.dt_created, 'HH:mm' )#
							</td>
							<td>
								#application.udf.GetLangValSec( 'cm_wd_status_upload_' & a_struct_processing_queue.q_select_items.status )#
							</td>
						</tr>
					</cfloop>
					</tbody>
				</table>
			</cfif>
			
			<br />
			
<cfset stPlistRecently = getProperty( 'beanFactory' ).getBean( 'PlaylistsComponent' ).ReturnPlaylistItems( securitycontext = application.udf.GetCurrentSecurityContext(),
										playlistkey = 'recentlyadded',
										maxrows = 5 ) />
		
<cfif stPlistRecently.result AND stPlistRecently.q_select_items.recordcount GT 0>
	<div style="float:right;padding:4px">
				<a href="##" onclick="opener.playPlaylistByEntrykey( 'recentlyadded' );return false">#application.udf.si_img( 'control_play' )# #application.udf.GetLangValSec( 'cm_ph_play_list_now' )#</a>

	</div>
			#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_playlist_recently_added' ) , '')#

			<cfset qItems = stPlistRecently.q_select_items />
			<table class="table_overview">
			<thead>
				<tr>
					<th class="bb">#application.udf.GetLangValSec( 'cm_wd_artist' )#</th>
					<th class="bb">#application.udf.GetLangValSec( 'cm_wd_name' )#</th>					
					<th class="bb">#application.udf.GetLangValSec( 'cm_wd_album' )#</th>
					<th class="bb">#application.udf.GetLangValSec( 'cm_wd_year' )#</th>					
				</tr>
			</thead>
			<tbody>
			<cfoutput query="qItems">
				<tr>
					<td>
						<a href="#application.udf.generateArtistURL(qItems.artist, 0 )#" target="_blank">#htmleditformat( qItems.artist )#</a>
					</td>
					<td>
						#htmleditformat( qItems.name )#
					</td>
					<td>
						#htmleditformat( qItems.album )#
					</td>
					<td>
						#htmleditformat( qItems.yr )#
					</td>
				</tr>
			</cfoutput>
			</tbody>
			</table>

</cfif>			
			</div>
			
			
			
			<!--- refresh queue --->
			<cfif a_struct_processing_queue.q_select_items.recordcount GT 0>
				<cfsavecontent variable="a_str_meta_refresh">
					<meta http-equiv="refresh" content="30;URL=/james/?event=media.upload&amp;uploadrunning=true" />
				</cfsavecontent>
				
				<cfhtmlhead text="#a_str_meta_refresh#">
			</cfif>
		
		</cfoutput>
	
	</cfsavecontent>
	<cfreturn />
</cfif>


<cfset iAccount_Type = application.udf.getCurrentSecurityContext().stPlan.accounttype />

<cfif iAccount_Type IS 0>
	
	<cfsavecontent variable="request.content.final">
	<div style="padding: 30px">
		<div class="status">
		Please <a href="/rd/upgrade/" target="_blank">upgrade your account</a> to upload media files to tunesBag.
		<br /><br />
		Alternatively, please connect your <a href="/dropbox/" target="_blank">Dropbox account</a> to access the media files stored there.
		</div>
	</div>
	</cfsavecontent>
	<cfexit method="exittemplate" />

</cfif>

<cfsavecontent variable="request.content.final">
	
<div class="headlinebox headlinebox_small">
	<p class="title"><cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput></p>
</div>
<img src="http://cdn.tunesBag.com/images/vista/Web-page.png" style="width:50px;border:0px;position:absolute;left:15px;top:10px" alt="<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser' )#</cfoutput>" />
<!--- <cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_upload_type_browser' ) , 'folder_add')#</cfoutput> --->

<cfif NOT a_struct_check_quota.result>
	<div class="status">
		<cfoutput>#application.udf.GetLangValSec( 'err_ph_4100', application.udf.byteConvert( a_struct_check_quota.maxsize ) )#</cfoutput>
	</div>
</cfif>

<cfset a_str_url_token = ReplaceNoCase( '&' & session.URLToken , '&', '%26', 'ALL' ) />


<cfset stUploadServer = getProperty( 'beanFactory' ).getBean( 'Server' ).getUploadEngineAssignment( application.udf.GetCurrentSecurityContext() ) />
<!--- NEW! --->
<cfset a_str_upload_filehandle_url = 'http://' & stUploadServer.sServerName & '/processing/?event=upload%26authkey=' & a_str_authkey & '%26userkey=' & application.udf.GetCurrentSecurityContext().entrykey & '%26runkey=' & a_str_uploadrunkey />

<!--- redirect after finished --->
<cfset a_str_upload_redirect_url = '/james/?event=media.upload' & a_str_url_token & '%26uploadrunning=true%26uploadrunkey='& a_str_uploadrunkey & '%26bFirstRun=true' />


<!--- development mode? --->
<cfif application.udf.IsDevelopmentServer()>
	<cfset a_str_upload_filehandle_url = 'http://tunesbagincomingdev/processing/?event=upload%26authkey=' & a_str_authkey & '%26userkey=' & application.udf.GetCurrentSecurityContext().entrykey & '%26runkey=' & a_str_uploadrunkey />
</cfif>

<div class="div_container">

<div style="padding:8px;padding-left:0px;padding-bottom:0px">
<form name="formaddplist" id="formaddplist" style="margin:0px">
	
	<!--- entrykey of this upload run --->
	<input type="hidden" name="uploadrunkey" id="uploadrunkey" value="<cfoutput>#htmleditformat( a_str_uploadrunkey )#</cfoutput>" />

	<b><cfoutput>#application.udf.GetLangValSec( 'lib_ph_edit_add_uploaded_files_to_plist' )#</cfoutput></b>
	<select name="addtoplaylist" id="addtoplaylist" onclick="checkCreateNewPlist(this.value)">
		<option value=""></option>
		<option value="createnewplaylist"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_create_new_playlist' )#</cfoutput></option>
		
		<cfif q_select_playlists.recordcount GT 0>
			<option value="">---</option>		
			<cfoutput query="q_select_playlists">
			<option value="#htmleditformat( q_select_playlists.name )#" <cfif CompareNoCase( a_str_plistkey, q_select_playlists.entrykey ) IS 0>selected="true"</cfif>>#htmleditformat( q_select_playlists.name )# &nbsp;</option>
			</cfoutput>
		</cfif>
	</select>

</form>
<div class="clear"></div>
<br />
<cfoutput>#application.udf.GetLangValSec( 'lib_upload_type_browser_info' )#</cfoutput>

</div>	

<!--- <cfimport taglib="/common/tags/" prefix="tb:tags" />

<tb:tags cf_dccom component="ProFlashUpload" folder="#folder#" width="500" height="400" themeColor="blue"
		jsOnComplete="onComplete"
		jsOnFileUpload="onFileUpload">
	</tb:tagscf_dccom> --->

<!--- <cfdump var="#q_select_playlists#"> --->

<script type="text/javascript">
var Flash = 0;
//Init "flash" object below!
function InitFlashObj()
{
    if(document.embeds && document.embeds.length>=1)
        Flash = document.getElementById("EmbedFlashFilesUpload");
    else
        Flash = document.getElementById("FlashFilesUpload");
}

// fired when items has been uploaded ... set the runkey + auto playlist to add
function MultiPowUpload_onComplete(type, fileIndex) {	
	var playlist = $('#addtoplaylist').val();
	var runkey = $('#uploadrunkey').val();
	if (playlist == '') {return;}
	// make simple bg request to transmit plist name
	SimpleBGOperation( 'items.uploadrun.autoadd2plist' , 'playlist=' + escape( playlist ) + '&uploadrunkey=' + escape( runkey ) );	
	
	}

// all completed	
function MultiPowUpload_onCompleteAbsolute(type, uploadedBytes) {
	var playlist = $('#addtoplaylist').val();
	var runkey = $('#uploadrunkey').val();
	if (playlist == '') {return;}
	SimpleBGOperation( 'items.uploadrun.autoadd2plist' , 'playlist=' + escape( playlist ) + '&uploadrunkey=' + escape( runkey ) );	
	}
	
// check if we need to create a new plist
function checkCreateNewPlist(name) {
	var anewname = '';
	var a_new_index = document.forms['formaddplist'].addtoplaylist.options.length;
	
	if (name == 'createnewplaylist') {
		anewname =  prompt("<cfoutput>#application.udf.GetLangValSec( 'cm_ph_playlist_create_please_enter_name' )#</cfoutput>", "");
		
		if (anewname !== null) {
			document.forms['formaddplist'].addtoplaylist.options[a_new_index] = new Option(anewname, anewname);
			
			// select last item
			document.forms['formaddplist'].addtoplaylist.selectedIndex = a_new_index;
			}
		}
	}

</script>

<OBJECT id="FlashFilesUpload" codeBase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0"
		width="450" height="320" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" VIEWASTEXT>
		
	<PARAM NAME="FlashVars" id="FlashVars" VALUE="uploadUrl=<cfoutput>#a_str_upload_filehandle_url#</cfoutput>&uploadButtonVisible=True
	&redirectUploadUrl=<cfoutput>#a_str_upload_redirect_url#</cfoutput>
	&showLink=false
	&customList=false
	&uploadButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangVal( 'lib_upload_btn_upload' ))#</cfoutput>
	&browseButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_browse' ) )#</cfoutput>
	&removeButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_remove' ))#</cfoutput>
	&clearListButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'lib_upload_dlg_clear_list' ))#</cfoutput>
	&cancelButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_cancel' ))#</cfoutput>	
	&labelUploadText=abc
	&labelUploadVisible=false
	&backgroundColor=#FFFFFF
	&buttonBackgroundColor=#ac2405
	&buttonTextColor=#FFFFFF
	&listUpColor=#EEEEEE
	&progressBarLeftColor=#ac2405
	&progressBarRightColor=#ac2405
	&listBackgroundColor=#FFFFFF" />
	<PARAM NAME="BGColor" VALUE="#FFFFFF">
	<PARAM NAME="Movie" VALUE="/res/flash/ElementITMultiPowUpload2.1.swf?<cfoutput>#CreateUUID()#</cfoutput>">
	<PARAM NAME="Src" VALUE="/res/flash/ElementITMultiPowUpload2.1.swf?<cfoutput>#CreateUUID()#</cfoutput>">
	<PARAM NAME="WMode" VALUE="Window">
	<PARAM NAME="Play" VALUE="-1">
	<PARAM NAME="Loop" VALUE="-1">
	<PARAM NAME="Quality" VALUE="High">
	<PARAM NAME="SAlign" VALUE="">
	<PARAM NAME="Menu" VALUE="-1">
	<PARAM NAME="Base" VALUE="">
	<PARAM NAME="AllowScriptAccess" VALUE="always">
	<PARAM NAME="Scale" VALUE="ShowAll">
	<PARAM NAME="DeviceFont" VALUE="0">
	<PARAM NAME="EmbedMovie" VALUE="0">	    
	<PARAM NAME="SWRemote" VALUE="">
	<PARAM NAME="MovieData" VALUE="">
	<PARAM NAME="SeamlessTabbing" VALUE="1">
	<PARAM NAME="Profile" VALUE="0">
	<PARAM NAME="ProfileAddress" VALUE="">
	<PARAM NAME="ProfilePort" VALUE="0">
	<PARAM name="useExternalInterface" value="true">
	
	<embed bgcolor="#FFFFFF" id="EmbedFlashFilesUpload" src="/res/flash/ElementITMultiPowUpload2.1.swf?<cfoutput>#CreateUUID()#</cfoutput>"
			quality="high" pluginspage="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash"
			type="application/x-shockwave-flash" width="450" height="320"
			flashvars="&showLink=false&customList=false
				&listBackgroundColor=#FFFFFF
				&backgroundColor=#FFFFFF
				&buttonBackgroundColor=#ac2405
				&buttonTextColor=#FFFFFF
				&listUpColor=#EEEEEE
				&progressBarLeftColor=#ac2405
				&progressBarRightColor=#ac2405
				&uploadButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'lib_upload_btn_upload' ))#</cfoutput>
				&browseButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_browse' ))#</cfoutput>
				&removeButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_remove' ))#</cfoutput>
				&clearListButtonText=<cfoutput>#UrlEncodedFormat( application.udf.GetLangValSec( 'lib_upload_dlg_clear_list' ))#</cfoutput>
				&cancelButtonText=<cfoutput>#UrlEncodedFormat(application.udf.GetLangValSec( 'cm_wd_cancel' ))#</cfoutput>
				&labelUploadText=abc
				&labelUploadVisible=false
				&useExternalInterface=true
				&uploadUrl=<cfoutput>#a_str_upload_filehandle_url#</cfoutput>&uploadButtonVisible=True&redirectUploadUrl=<cfoutput>#a_str_upload_redirect_url#</cfoutput>">
	</embed>
  </OBJECT>
</div>

<script type="text/javascript">
	InitFlashObj();
</script>

</cfsavecontent>