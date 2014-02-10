<!--- create a custom smart plist --->
<!--- get genres --->

<cfset a_struct_distinct_genres = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetDistinctAvailableGenres( application.udf.GetCurrentSecurityContext() ) />
<cfset q_select_distinct_available_genres = a_struct_distinct_genres.q_select_distinct_available_genres />

<!--- re  - sort friends --->
<cfquery name="q_select_real_friends" dbtype="query">
SELECT
	*
FROM
	q_select_friends
WHERE
	accesslibrary = 1
	AND NOT
	otheruserkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().entrykey#">
	AND
	playlistscount > 0
ORDER BY
	accesslibrary DESC,
	displayname
;
</cfquery>

<cfquery name="q_select_distinct_available_genres" dbtype="query">
SELECT
	*
FROM
	q_select_distinct_available_genres
ORDER BY
	genre_count DESC,
	genre
;
</cfquery>

<div id="id_create_smart_plist" style="display:none">

<form action="/james/?event=ui.customradio.createstation" id="id_frm_create_smart_plist" name="id_frm_create_smart_plist"
		method="post" target="_blank" onsubmit="stationCollectSelectedData();DoAjaxSubmit( {
				'formid': this.id } );tb_remove();return false;">
					
		<!--- genre list ... filled by collection function --->
		<input type="hidden" name="genres" value="" />
		<input type="hidden" name="librarykeys" value="" />

		<cfoutput>#application.udf.si_img( 'tag_blue' )# #application.udf.GetLangValSec( 'start_ph_create_custom_playlist_description' )#</cfoutput>
			
			<!--- selected genres --->
			<div>
				<ul id="id_station_selected_genres"></ul>							
				<div class="clear"></div>
			</div>
			
			<!--- available genres --->
			<div>
				
				<ul id="id_station_available_genres">
				<cfoutput query="q_select_distinct_available_genres">
					
					<cfset a_int_size = q_select_distinct_available_genres.genre_count / 1.5 />
					
					<cfif a_int_size LT 11>
						<cfset a_int_size = '' />
					<cfelseif a_int_size GT 16>
						<cfset a_int_size = 16 />
					</cfif>
					
					<cfif q_select_distinct_available_genres.genre_count GT 2>
					<li><a href="##" title="#application.udf.GetLangValSec( 'cm_wd_items' )#: #q_select_distinct_available_genres.genre_count#" <cfif Len( a_int_size ) GT 0>style="font-size:#a_int_size#px"</cfif> onclick="stationAddGenre( this );return false;">#htmleditformat( q_select_distinct_available_genres.genre)#</a></li>
					</cfif>
					
				</cfoutput>
				</ul>
				
				<div class="clear"></div>
			</div>
			
			<div class="clear"><br /></div>
			
			<table class="tbl_td_top" width="90%">
				<tr>
					<td width="50%">
						<b><cfoutput>#application.udf.si_img( 'lightning' )# #application.udf.GetLangValSec( 'cm_ph_surprise_factor' )#</cfoutput></b>
						
						<div style="margin-top:12px;padding-left:30px">
							
							<input type="radio" name="surprise" value="10" id="id_surprise_factor_low" /> <label for="id_surprise_factor_low"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_surprise_factor_low' )#</cfoutput></label>
							&nbsp;
							<input type="radio" name="surprise" value="40" id="id_surprise_factor_middle" checked="true" /> <label for="id_surprise_factor_middle"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_surprise_factor_middle' )#</cfoutput></label>
							&nbsp;
							<input type="radio" name="surprise" value="70" id="id_surprise_factor_high" /> <label for="id_surprise_factor_high"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_surprise_factor_high' )#</cfoutput></label>												
							
						</div>
					</td>
					<cfif q_select_real_friends.recordcount GT 0>
					<td width="50%" style="padding-left:40px">
						
						<cfoutput>#application.udf.si_img( 'folder_page' )# #application.udf.GetLangValSec( 'start_ph_smart_plist_include_libraries' )#</cfoutput>
						
						<div style="margin-top:12px;padding-left:30px">
							<!--- Friends, Mood, Added, Tags --->
									
									
										<input type="radio" name="smart_plist_include_libs" id="smart_plist_include_libs_all" onclick="$('#id_smart_plist_select_libraries').slideUp()" value="all" checked="true" /> <cfoutput>#application.udf.GetLangValSec( 'cm_wd_all' )#</cfoutput>
										<input type="radio" name="smart_plist_include_libs" id="smart_plist_include_libs_selected" onclick="$('#id_smart_plist_select_libraries').slideDown()" value="selected" /> <cfoutput>#application.udf.GetLangValSec( 'cm_ph_selected_only' )#</cfoutput>
										<br />
									
										<ul class="ul_nopoints" style="display:none;margin-top:12px" id="id_smart_plist_select_libraries">
												<li>
													<input type="checkbox" name="librarykeys" value="<cfoutput>#application.udf.GetCurrentSecurityContext().defaultlibrarykey#</cfoutput>" checked="true" /> <cfoutput>#application.udf.GetLangValSec( 'cm_ph_my_library' )#</cfoutput>
												</li>
											<cfoutput query="q_select_real_friends">
												<li>
													<input type="checkbox" name="librarykeys" value="#q_select_real_friends.librarykey#" checked="true" /> #htmleditformat( q_select_real_friends.displayname )# <span class="addinfotext">(#application.udf.GetLangValSec( 'cm_wd_items' )#: #q_Select_real_friends.libraryitemscount#)</span>
												</li>
											</cfoutput>
										</ul>
						</div>
					
					
					</td>
					</cfif>
				</tr>
			</table>
			
			
			
			<div class="clear"></div>
			
			<div style="margin-top:12px">
				<input type="submit" value="<cfoutput>#application.udf.GetLangValSec( 'start_ph_create_smart_plist_btn' )#</cfoutput>" class="btn" />
			</div>
</form>

<!--- // end create own custom radio station // --->
</div>