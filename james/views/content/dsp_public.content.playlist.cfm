<!--- 

	output playlist information

 --->
<cfinclude template="/common/scripts.cfm">

<!--- <cfquery name="qPlaylists" datasource="mytunesbutleruserdata">
SELECT
	*
FROm
	playlists
WHERE
	istemporary = 0
</cfquery> --->

<cfset a_str_plistkey = event.getArg( 'entrykey' ) />
<cfset a_struct_plist = event.getArg( 'a_struct_playlist' ) />

<cfif NOT IsStruct(a_struct_plist) OR NOT a_struct_plist.result>
	<cfset request.content.final = application.udf.WriteCommonErrorMessage( 1002 ) />
	
	<!--- <cfsavecontent variable="request.content.final">
	<cfdump var="#event.getargs()#">
	<cfdump var="#application.udf.GetCurrentSecurityContext().rights#">
	</cfsavecontent> --->
	<cfexit method="exittemplate">
</cfif>

<cfset q_select_simple_plist_info = a_struct_plist.q_select_simple_plist_info />
<cfset q_select_items = a_struct_plist.q_select_items />
<cfset a_user_info = a_struct_plist.a_user_info.a_struct_item />

<cfset a_struct_comments = event.getArg( 'a_struct_comments' ) />

<!--- tab view? --->
<cfset bInTab = event.getArg( 'tab', 0 ) IS 1 />

<!--- is this a public view? --->
<cfset bPublicView = event.getArg( 'IsPublicView', false ) />

<cfif application.udf.IsLoggedIn()>
	<cfset a_str_librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) />
<cfelse>
	<cfset a_str_librarykeys = '' />
</cfif>

<!--- page description / title --->
<cfset event.setArg( 'PageTitle', q_select_simple_plist_info.name & ' - ' & application.udf.GetLangValSec( 'cm_wd_playlist' ) & ' - ' & application.udf.GetLangValSec( 'cm_ph_plist_public_page_title' ) ) />

<cfset aReplace = [ ValueList( q_select_items.artist, ', '), a_user_info.getUsername() ] />
<cfset event.setArg( 'PageDescription', application.udf.GetLangValSec( 'cm_ph_plist_public_page_description', aReplace) ) />

<cfset sSource = '' />

<cfif findNoCase( 'Facebook', cgi.HTTP_USER_AGENT ) GT 0>
	<cfset sSource = 'fb' />
</cfif>

<cfset sURL = "http://deliver.tunesbagcdn.com/flash/embed/tbembed-0.3.swf?plistkey=#q_select_simple_plist_info.entrykey#" />

<cfif sSource IS 'fb'>
	<cfset sURL = sURL & '&autoplay=true' />
</cfif>

<cfsavecontent variable="sHTMLHead">
	<cfoutput>
	<meta name="title" content="#htmleditformat( event.getArg( 'PageTitle' ) )#" />
	<meta name="medium" content="video" /> 
	
	<meta name="description" content="#htmleditformat( q_select_simple_plist_info.description )#; A playlist w/ tracks from #ValueList( q_select_items.artist, ', ')#" />
	<link rel="image_src" href="#application.udf.getPlistImageLink( q_select_simple_plist_info.entrykey, 120 )#?#CreateUUID()#" />
	
	<link rel="video_src" href="<cfoutput>#sURL#</cfoutput>"/>
	<meta name="video_height" content="110" />
	<meta name="video_width" content="440" />
	<meta name="video_type" content="application/x-shockwave-flash" />
	</cfoutput>
</cfsavecontent>

<!--- IGNORE FOR NOW --->
<cfset sHTMLHead = '' />

<cfhtmlhead text="#sHTMLHead#">

<!--- get total time --->
<cfquery name="q_select_total_time" dbtype="query">
SELECT
	SUM( totaltime ) AS sum_totaltime
FROM
	q_select_items
;
</cfquery>

<cfsavecontent variable="request.content.final">

<!--- "tabbed" --->
<cfif bInTab>
	<div class="headlinebox">
		<cfoutput>
		<p class="title">#htmleditformat( q_select_simple_plist_info.name )# (#application.udf.GetLangValSec( 'cm_wd_playlist' )#)</p>
		<p>#application.udf.GetLangValSec( 'cm_wd_by')# #htmleditformat( a_user_info.getUsername() )#</p>
		</cfoutput>
	</div>
<cfelse>
	<cfinclude template="snippets/inc_signup_public_hint.cfm">
</cfif>

<table class="tbl_td_top" style="width:100%">
<tr>
	<td>
<div class="div_container">

	
<cfoutput>
<div style="float:right;padding:4px;" class="bl">

<table class="table_details" style="width:200px">
	<tr>
		<td style="width:48px">
			
			#application.udf.writeDefaultImageContainer( application.udf.getUserImageLink( a_user_info.getUsername(), 75 ),
								a_user_info.getUsername(),
								'/user/' & Urlencodedformat( a_user_info.getUsername() ),
								38,
								false,
								true )#
			
		</td>
		<td>
			#application.udf.GetLangValSec( 'cm_wd_by' )# <a title="#htmleditformat( a_user_info.getUsername() )#" class="add_as_tab" href="/user/#Urlencodedformat( a_user_info.getUsername() )#">#a_user_info.getUsername()#</a>
			<br />
			#LSDateFormat( q_select_simple_plist_info.dt_lastmodified, 'mmm yy')#
			
			
		</td>
	</tr>
	<!--- image licence hint --->
	<cfif q_select_simple_plist_info.licence_type_image IS 100>
		<tr>
			<td colspan="2">
				<a class="addinfotext" href="#q_select_simple_plist_info.licence_image_link#" target="_blank">#application.udf.GetLangValSec( 'cm_ph_image_licence_link_cc' )#</a>
			</td>
		</tr>
	</cfif>
</table>
</div>
	
<!--- plist image? --->
<cfif q_select_simple_plist_info.imageset IS 1>


	#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( q_select_simple_plist_info.entrykey, 120 ),
									application.udf.CheckZeroString( q_select_simple_plist_info.name ),
									'',
									75,
									false,
									false )#

</cfif>
<h1>#htmleditformat( q_select_simple_plist_info.name )# (#application.udf.FormatSecToHMS( q_select_total_time.sum_totaltime )#)</h1>

<cfif Len( q_select_simple_plist_info.Description ) GT 0>
	<h4 class="addinfotext">
	#htmleditformat( q_select_simple_plist_info.Description )#
	</h4>
</cfif>

<cfif Len( q_select_simple_plist_info.tags ) GT 0>
	<p style="margin-top: 8px">
	<cfloop list="#q_select_simple_plist_info.tags#" delimiters=" " index="a_str_tag">
	<a href="/james/?event=playlists.explore&amp;type=playlists" class="add_as_tab" title="#application.udf.GetLangValSec( 'cm_wd_explore' )#"><span class="tag_box">#htmleditformat( a_str_tag )#</span></a>
	</cfloop>
	</p>
</cfif>
<br />

<cfif a_struct_comments.q_select_items.recordcount GT 0>
	
	<cfset q_select_comments = a_struct_comments.q_select_items />

	#application.udf.si_img( 'comments' )# <b>#application.udf.GetLangValSec( 'cm_wd_comments' )# (#q_select_comments.recordcount#)</b>
	<div style="padding:8px;padding-left:20px">
	<cfloop query="q_select_comments">
		<p>
			<a href="/user/#htmleditformat( q_select_comments.createdbyusername )#" title="#htmleditformat( q_select_comments.createdbyusername )#" class="add_as_tab">#htmleditformat( q_select_comments.createdbyusername )#</a> <span class="addinfotext">(#LsDateFormat( q_select_comments.dt_created, 'mm/dd') #)</span>: #htmleditformat( q_select_comments.comment )#
		</p>
	</cfloop>
	</div>
</cfif>				
	

	
<div class="clear"></div>
<cfset a_str_social_link = UrlEncodedFormat( q_select_simple_plist_info.seohref ) />
<cfset a_str_social_title = UrlEncodedFormat( application.udf.GetLangValSec( 'cm_wd_playlist' ) & ': ' & q_select_simple_plist_info.name & ' (' & q_select_items.recordcount & ' ' & application.udf.GetLangValSec( 'cm_wd_items' ) & ') ' & q_select_simple_plist_info.description ) />

<cfoutput>
<div class="div_social_bar">
<a href="http://www.addthis.com/bookmark.php" onclick="addthis_url = location.href; addthis_title = document.title; return addthis_click(this);" target="_blank"><img style="vertical-align:middle;border:0px" src="http://deliver.tunesbagcdn.com/images/partner/button1-share.gif" width="125" height="16" alt="AddThis Social Bookmark Button" /></a> <script type="text/javascript">var addthis_pub = 'tunesbag';</script><script type="text/javascript" src="http://s9.addthis.com/js/widget.php?v=10"></script>
</div>
</cfoutput>

<!---  --->

<cfif bPublicView>
	<cfset sURL = 'http://deliver.tunesbagcdn.com/flash/embed/tbembed-0.3.swf?plistkey=' & q_select_simple_plist_info.entrykey />
	
	<div style="text-align:center" class="div_container bt">
	<embed src="<cfoutput>#sURL#</cfoutput>" quality="high" bgcolor="##EEEEEE"
		FlashVars=""
		width="440" height="110" name="tbembed" align="middle"
		quality="high"
		type="application/x-shockwave-flash"
		pluginspage="http://www.adobe.com/go/getflashplayer">
	</embed>
	</div>
</cfif>

<!--- add play btn? --->
<cfif NOT bPublicView AND application.udf.IsLoggedIn()>
	
	<cfif application.udf.GetCurrentSecurityContext().rights.playlist.radio IS 1>
		<br />
		<input type="button" class="btn" value="#application.udf.GetLangValSec( 'cm_ph_play_list_now' )#" onclick="DoNavigateToURL( 'tb:loadplist&plistkey=#q_select_simple_plist_info.Entrykey#' );return false;" />
	
	
		<cfif a_user_info.getEntrykey() NEQ application.udf.GetCurrentSecurityContext().entrykey>
			&nbsp;&nbsp;&nbsp;
			<a href="##" onclick="SimpleBGOperation( 'playlist.linktolibrary', 'playlistkey=#q_select_simple_plist_info.Entrykey#&playlistuserkey=#a_user_info.getEntrykey()#', function() { librariesSet.ReloadBaseLibrary();StatusMsg( '#application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_done_status' )#', 'folder_add'); } );return false">#application.udf.si_img( 'folder_add' )# #application.udf.GetLangValSec( 'cm_ph_playlist_bookmark_plist' )#</a>
		</cfif>
	</cfif>
<cfelse>

	<cfif bPublicView>
	<div class="confirmation" style="width:600px">
	
		<cfoutput>
		<a href="/james/?event=showlibrary&amp;addtab=#UrlencodedFormat( 'event=playlist.info&entrykey=' & a_str_plistkey )#&amp;addtabtitle=#application.udf.GetLangValSec( 'cm_wd_playlist' )#">#application.udf.GetLangValSec( 'pub_ph_please_log_in' )#</a>
		</cfoutput>		
	
	</div>
	</cfif>

	<!--- <cfset stSec = application.udf.generatePseudoSecurityContext( 'de', cgi.REMOTE_ADDR)>
	<cfif stSec.rights.playlist.interactiveradio IS 1>
	<cfoutput>
	<embed src="http://deliver.tunesbagcdn.com/flash/embed/tbembed.v1.swf?plistkey=#a_str_plistkey#" flashvars="video_id=123456789" width="100%" height="120" type="application/x-shockwave-flash" />
	</cfoutput>
	</cfif> --->
</cfif>
</div>

</cfoutput>

<div class="clear"></div>


<cfif bPublicView OR application.udf.GetCurrentSecurityContext().rights.playlist.radio NEQ 1>

<div style="padding: 40px">
<script type="text/javascript"><!--
google_ad_client = "ca-pub-5279195474591127";
/* querad 728x90, Erstellt 02.01.09 */
google_ad_slot = "9780078640";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>

	<!--- public view, simple list --->
	<div class="div_container">
		
	<iframe border="0" style="border:0px" frameborder="0"  src="http://www.moosify.com/widgets/explorer/?partner=tunesbag" width="720" height="90"></iframe>
				
	<div class="clear"></div>

		
	<table class="table_overview">
		<cfoutput query="q_select_items">
			<tr>
				<td class="bb">
					
					#application.udf.writeDefaultImageContainer( getAlbumArtworkLink( q_select_items.mb_albumid, 75 ),
								q_select_items.name,
								'',
								38,
								false,
								true )#
								
					<!--- <img src="#getAlbumArtworkLink( q_select_items.mb_albumid, 75 )#" width="60" height="60" alt="#htmleditformat( q_select_items.name )# by #htmleditformat( q_select_items.artist )#" title="#htmleditformat( q_select_items.name )# by #htmleditformat( q_select_items.artist )#" /> --->
				</td>
				<td class="bb" style="padding:10px">
					<a <cfif NOT bPublicView>target="_blank"</cfif> style="font-size:24px" href="#generateGenericURLToTrack( q_select_items.artist, q_select_items.name, q_select_items.mb_trackid, q_select_items.entrykey )#">#htmleditformat( q_select_items.name )#</a>
					-
					<!--- link to artist --->
					<a class="add_as_tab" style="font-size:18px" href="#application.udf.generateArtistURL( q_select_items.artist, q_select_items.mb_artistid )#">#htmleditformat( q_select_items.artist )#</a>
				</td>
				<td class="addinfotext bb">
					#application.udf.FormatSecToHMS( q_select_items.totaltime )#
				</td>
			</tr>
		</cfoutput>
	</table>
	</div>
	
	<br />
		Content provided by <a href="http://last.fm" target="_blank"><img src="http://deliver.tunesbagcdn.com/images/partner/lastfm-logo-100px.png" style="vertical-align:middle;border:0px;padding-left:20px;" alt="last.fm" /></a>
		&nbsp;
		<a href="http://www.musicbrainz.org/">musicbrainz</a>,

		<a href="http://www.amazon.com">amazon</a> and <a href="http://www.songkick.com">songkick</a>.
		
		<br /><br />
		<span class="addinfotext">
		The search/indexing interface contains content from public sources and links to other websites.
		tunesBag neither controls nor endorses these web sites, nor reviews or approves any content appearing on them.
		tunesBag does not assume any responsibility or liability for any materials available,
		or for the completeness, availability, accuracy, legality or decency.
		</span>
		<br /><br />

<cfelse>

	<cfif ListFindNoCase( a_str_librarykeys, q_select_simple_plist_info.LibraryKey ) GT 0>
		<cfset a_str_type = 'internal' />
	<cfelse>
		<cfset a_str_type = 'external' />
	</cfif>
	
	<cfset a_str_jd_id = application.udf.ReturnJSUUID() />
	
	<cfset stLicencePermissions = application.beanFactory.getBean( 'LicenceComponent' ).applyLicencePermissionsToRequest(securitycontext = application.udf.GetCurrentSecurityContext(),
					 sRequest = 'PLAYLIST',
					 bOwnDataOnly = false  ) />
	
	<cfset a_struct_return = application.udf.SimpleBuildOutput( securitycontext = application.udf.GetCurrentSecurityContext(),
								query = q_select_items,
								type = a_str_type,
								target = '##' & a_str_jd_id,
								force_id = '',
								columns = 'artist,name',
								lastkey = '',
								setActive = false,
								playlistkey = q_select_simple_plist_info.Entrykey,
								options = 'artistimg',
								stLicencePermissions = stLicencePermissions ) />
	
	<div class="div_container">
	<div id="<cfoutput>#a_str_jd_id#</cfoutput>"></div>
	</div>
	
	<cfoutput>#a_struct_return.html_content#</cfoutput>

</cfif>

</td>
</tr>
</table>
</cfsavecontent>