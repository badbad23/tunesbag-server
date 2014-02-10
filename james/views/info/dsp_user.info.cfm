<!--- //

	Module:		User info
	Action:		user.info
	Description:	
	
// --->

<cfinclude template="/common/scripts.cfm">

<cfif Len( event.getArg( 'userkey', '')) IS 0>
 	<cfset request.content.final = application.udf.WriteCommonErrorMessage( 1002 ) />
	<cfexit method="exittemplate">
</cfif>

<!--- read profile --->
<cfset a_struct_user_profile = event.getArg( 'a_struct_user_profile' ) />

<!--- is a friend? false by default --->
<cfset bIsAFriend = false />

<cfif NOT a_struct_user_profile.result>
	<cfset request.content.final = application.udf.WriteCommonErrorMessage( 1002 ) />
	<cfexit method="exittemplate">
</cfif>

<!--- is this a public view? --->
<cfset a_bol_public_view = event.getArg( 'IsPublicView', false ) />

<!--- get userdata --->
<cfset a_userdata = a_struct_user_profile.a_userdata />
<cfset q_select_friends = a_struct_user_profile.q_select_friends />
<cfset q_select_favourite_artists = a_struct_user_profile.q_select_favourite_artists />
<cfset q_select_genre_cloud_of_user = a_struct_user_profile.q_select_genre_cloud_of_user />
<cfset q_select_playlists = a_struct_user_profile.q_select_playlists />
<!--- get last log items --->
<cfset q_select_last_log_items = event.getArg( 'q_select_last_log_items' ) />

<cfquery name="q_select_playlists" dbtype="query">
SELECT
	*
FROM
	q_select_playlists
WHERE
	[public] = 1
;
</cfquery>


<!--- <cfset q_select_recently_played_items = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).GetLastPlayedItems( userkeys = a_userdata.getentrykey() ).q_select_recently_played_items />

<cfquery name="q_select_recently_played_items" dbtype="query" maxrows="5">
SELECT
	*
FROM
	q_select_recently_played_items
;
</cfquery> --->

<!--- set meta data --->
<cfset event.setArg( 'PageTitle', a_userdata.getUsername() & ' - ' & application.udf.GetLangValSec( 'cm_wd_user' ) ) />
<cfset event.setArg( 'PageDescription', 'Is a fan of ' & ValueList( q_select_favourite_artists.name ) & '; has several playlists like ' & ValueList( q_select_playlists.name, ', ') ) />

<!--- private profile? --->
<cfif a_userdata.getprivacy_profile() NEQ 0 AND NOT bIsAFriend>
	<cfsavecontent variable="request.content.final">
		<div class="status">This is a private profile</div>
	</cfsavecontent>
	<cfexit method="exittemplate">
</cfif>

<cfsavecontent variable="request.content.final">

<cfoutput>
	
<cfif a_bol_public_view>
	<cfsavecontent variable="a_str_css">
		<style type="text/css" media="all">
		body.body_main {
			background-image:URL(#a_userdata.getbgimage()#)
			}
		</style>
	</cfsavecontent>
	
	<cfhtmlhead text="#a_str_css#">
</cfif>

<cfif NOT a_bol_public_view>
	<div class="headlinebox">
		<p class="title"><cfoutput>#application.udf.GetLangValSec( 'cm_ph_profile_of_user', a_userdata.getUsername() )#</cfoutput></p>
		
		<cfif Len( a_userdata.getCity() ) GT 0>
		<p><cfoutput>#application.udf.GetLangValSec( 'cm_ph_person_is_from', a_userdata.getCity() & ', ' & a_userdata.getCountryISOCode() )#</cfoutput></p>
		</cfif>
	</div>
	
	<cfset bIsAFriend = application.udf.checkIsFriend( application.udf.GetCurrentSecurityContext(), a_userdata.getEntrykey() ) />
</cfif>
		
<div class="div_container">

	
<cfif NOT a_bol_public_view AND (a_userdata.getEntrykey() IS application.udf.GetCurrentSecurityContext().entrykey)>
	<div class="confirmation">
		#application.udf.GetLangValSec( 'cm_ph_is_your_profile' )#
		<a href="/james/?event=user.preferences&amp;TB_iframe=true&amp;height=500&amp;width=840" target="_blank">#application.udf.GetLangValSec( 'cm_wd_edit' )#</a>
	</div>
</cfif>

<h1>#application.udf.GetLangValSec( 'cm_ph_profile_of_user', a_userdata.getUsername() )#</h1>

<table style="margin-top:12px" class="tbl_td_top">
	<tr>
		<td style="padding-right:12px" width="70">
			<cfif a_userdata.getpic() IS ''>
				<cfset a_userdata.setPic( 'http://cdn.tunesBag.com/images/nobody.png' ) />
			</cfif>
			
			#application.udf.writeDefaultImageContainer( application.udf.getUserImageLink( a_userdata.getUsername(), 120 ),
								a_userdata.getUsername(),
								'',
								75,
								false,
								true )#
								
		</td>
		<td style="padding-right:8px;width:40%">
			
			<table class="table_details">
				<tr>
					<cfif Len( a_userdata.getCity() ) GT 0>
					<td>
						#application.udf.si_img( 'world' )#
					</td>
					<td>
						
						<cfif IsDate( a_userdata.getbirthday() )>
							<cfset a_int_age = DateDiff( 'yyyy', a_userdata.getbirthday(), Now() ) />
							
							<cfif Val( a_int_age ) GT 0>
								#a_int_age#
							</cfif>
						</cfif>
						
						
						#application.udf.GetLangValSec( 'cm_ph_person_is_from', a_userdata.getCity() & ', ' & a_userdata.getCountryISOCode() )#
						

					</td>					
				</tr>
				</cfif>
				<cfif Len( a_userdata.getabout_me() ) GT 0>
				<tr>
					<td valign="top">
						#application.udf.si_img( 'comment' )#
					</td>
					<td>
						 #htmleditformat( a_userdata.getabout_me() )#
						 <img src="http://cdn.tunesBag.com/images/space1x1.png" class="si_img" />
					</td>
				</tr>
				</cfif>
				
				<cfif Len( a_userdata.gethomepage() ) GT 0>
					
					<cfset a_str_homepage = a_userdata.gethomepage() />
					
					<cfif FindNoCase( 'http://', a_str_homepage ) IS 0>
						<cfset a_str_homepage = 'http://' & a_str_homepage />
					</cfif>
					<tr>
						<td>#application.udf.si_img( 'link' )#</td>
						<td>
							<a href="##" onclick="window.open('#Trim( a_str_homepage )#');return false;" title="#application.udf.GetLangValSec( 'cm_wd_homepage' )#">#htmleditformat( application.udf.ShortenString( a_userdata.gethomepage(), 40 ))#</a>
						</td>
					</tr>
				</cfif>
				
				<tr>
					<td>
						#application.udf.si_img( 'group' )#
					</td>
					<td>
						#application.udf.GetLangValSec( 'cm_ph_profile_has_friends', q_select_friends.recordcount )#
					</td>
				</tr>
				
				<cfif NOT a_bol_public_view AND (a_userdata.getEntrykey() NEQ application.udf.GetCurrentSecurityContext().entrykey)>
				<tr>
					<td>
						#application.udf.si_img( 'add' )#
					</td>
					<td>
						<a href="##" onclick="SimpleInpagePopup( '#application.udf.GetLangValSec( 'cm_ph_request_friendship' )#', '/james/?event=ui.simple.dialog&username=#UrlEncodedFormat( a_userdata.getUsername() )#&type=friend.requestfriendship', false);return false">#application.udf.GetLangValSec( 'cm_ph_add_as_friend' )#</a>
					</td>
				</tr>
				<tr>
					<td>
						#application.udf.si_img( 'email' )#
					</td>
					<td>
						<a href="##" onclick="SimpleInpagePopup( 'Message', '/james/?event=messages.send&height=290&width=600&recipient=#UrlEncodedFormat( a_userdata.getUsername() )#', false);return false" class="add_thickbox">#application.udf.GetLangValSec( 'cm_ph_send_a_message' )#</a>					
					</td>
				</tr>
				</cfif>
				
				</cfoutput>
				
				<cfif q_select_genre_cloud_of_user.recordcount GT 0>
					<tr>
						<td>
							<cfoutput>#application.udf.si_img( 'chart_pie' )#</cfoutput>
						</td>
						<td>
							
					<cfquery name="q_select_genre_cloud_of_user" dbtype="query">
					SELECT
						*
					FROM
						q_select_genre_cloud_of_user
					WHERE
						genre_count > 2
					ORDER BY
						genre_count DESC
					;
					</cfquery>
					
					<cfoutput query="q_select_genre_cloud_of_user" startrow="1" maxrows="12">
								
						<cfset a_int_size = q_select_genre_cloud_of_user.genre_count / 3 />
						
						<cfif a_int_size LT 11>
							<cfset a_int_size = '' />
						<cfelseif a_int_size GT 16>
							<cfset a_int_size = 16 />
						</cfif>
						
						<cfif Len( q_select_genre_cloud_of_user.genre ) GT 0>
						<span <cfif Len( a_int_size ) GT 0>style="font-size:#a_int_size#px"</cfif>>#htmleditformat( application.udf.CheckZeroString( q_select_genre_cloud_of_user.genre ) )#</span> &nbsp;
						</cfif>
						
					</cfoutput>	
	
	
					<cfif q_select_genre_cloud_of_user.recordcount LT 10 AND Len( a_userdata.getMusic_Preferences() ) GT 0>
						<div>
							<cfloop list="#a_userdata.getMusic_Preferences()#" delimiters="," index="a_str_tag">
								<cfoutput>
								#htmleditformat( a_str_tag )#,
								</cfoutput>
							</cfloop>...
							<img src="http://cdn.tunesBag.com/images/space1x1.png" class="si_img" />
						</div>
					</cfif>
						</td>
					</tr>
				</cfif>
			</table>
			
			

			
		</td>
		<!--- <td style="padding-left:20px;" class="bl">
			
				
				<table class="table_details tbl_td_top">
				<cfoutput>
				<tr>
					<td>
						
					</td>
					<td style="font-weight:bold">
						#application.udf.GetLangValSec( 'cm_ph_playlist_recently_played' )#
					</td>
				</tr>
				</cfoutput>
				<tr>
					<td></td>
					
					<td>
						
						
						<!--- build a plist? --->
						<cfif NOT a_bol_public_view>
							
							<!--- a friend of public playlists --->
							<cfif bIsAFriend OR a_userdata.getprivacy_playlists() IS 0>
						
								<cfset stLicencePermissions = application.beanFactory.getBean( 'LicenceComponent' ).applyLicencePermissionsToRequest(securitycontext = application.udf.GetCurrentSecurityContext(),
										 sRequest = 'PLAYLIST',
										 bOwnDataOnly = false  ) />
						
								<cfset stReturn = application.udf.SimpleBuildOutput(  securitycontext = application.udf.GetCurrentSecurityContext(),
										query = q_select_recently_played_items,
										type = 'internal',
										target = 'idUserRecentlyPlayed#Hash( a_userdata.getusername() )#',
										setActive = false,
										force_id = '',
										columns = 'artist,name',
										lastkey = '',
										playlistkey = '',
										options = '',
										stLicencePermissions = stLicencePermissions) />
											
								<cfoutput>#stReturn.html_content#</cfoutput>
								
							</cfif>
						
						<cfelse>
						<!--- 
							<!--- public playlists --->
							<cfif a_userdata.getprivacy_playlists() IS 0>
								<cfoutput query="q_select_recently_played_items">
								<div style="margin-bottom:8px">
								<a href="/item/#q_select_recently_played_items.mediaitemkey#"
									
									style="font-size:12px">#htmleditformat( q_select_recently_played_items.name )#</a>
								-
								<a href="#application.udf.generateArtistURL( q_select_recently_played_items.artist, q_select_recently_played_items.mb_artistid )#" title="#htmleditformat( q_select_recently_played_items.artist )#" class="add_as_tab">#q_select_recently_played_items.artist#
								</div>
								</cfoutput>

							</cfif> --->
						
						</cfif>

					</td>
				</tr>					
				</table>
				
		
		</td> --->
	</tr>
</table>

<!--- google ad --->
<cfif a_bol_public_view>

	<div class="div_container_small bt" style="text-align:center">
		<script type="text/javascript"><!--
		google_ad_client = "pub-5279195474591127";
		/* ad on user page, 728x90, Erstellt 30.12.08 */
		google_ad_slot = "4100042417";
		google_ad_width = 728;
		google_ad_height = 90;
		//-->
		</script>
		<script type="text/javascript"
		src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
		</script>
	</div>

</cfif>

<cfif bIsAFriend OR a_userdata.getprivacy_playlists() IS 0>

	<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_playlists' ) & ' (' & q_select_playlists.recordcount & ')', 'page_cd_white' )#</cfoutput>
	
	<div class="div_container">
		
	<cfif q_select_playlists.recordcount IS 0>
		<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
	<cfelse>
		<table class="table_overview tbl_td_top">
		<cfoutput query="q_select_playlists">
			
			
			<cfquery name="q_select_items" datasource="mytunesbutleruserdata">
			SELECT
				DISTINCT( mediaitems.artist )
			FROM
				playlist_items
			INNER JOIN mediaitems ON (mediaitems.entrykey = playlist_items.mediaitemkey)
			WHERE
				playlist_items.playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_playlists.entrykey#">
				AND
				/* create a smaller range for this simple output to speed up the query */
				mediaitems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_userdata.getEntrykey()#">
			LIMIT
				5
			;
			</cfquery>
			<tr>
				<td>
					#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( q_select_playlists.entrykey, 48 ),
									application.udf.CheckZeroString( q_select_playlists.name ),
									generateURLToPlist( q_select_playlists.entrykey, q_select_playlists.name, false ),
									38,
									false,
									true )#
				</td>
				<td nowrap="true">
					
					
									
					<a title="#application.udf.GetLangValSec( 'cm_wd_playlist' )#" href="#generateURLToPlist( q_select_playlists.entrykey, q_select_playlists.name, false )#" class="add_as_tab"><h3>#htmleditformat( q_select_playlists.name )#</h3></a>
				
				
						<span class="addinfotext">
							#application.udf.GetLangValSec( 'cm_wd_items' )#: #q_select_items.recordcount#
							
							<cfif Len( q_select_playlists.description ) GT 0>
								<br />
								#htmleditformat( q_select_playlists.description )#
							</cfif>
					</span>
						
				</td>
				<td style="line-height:160%;padding-left:10px">
	
					
					
					<cfloop query="q_select_items">
						#htmleditformat( q_select_items.artist )#,
					</cfloop>&nbsp;
					
					<!--- <div style="clear:both">
						3 Comments, 9 ratings
					</div> --->
				</td>
			</tr>
		</cfoutput>
		</table>
	</cfif>
	</div>
</cfif>

<!--- recent actions --->
<cfif bIsAFriend OR a_userdata.getprivacy_newsfeed() IS 0>
	<cfif q_select_last_log_items.recordcount GT 0>
		
		<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_ph_recent_activites' ), '' )#</cfoutput>
			
		<div class="div_container">
		<cfoutput query="q_select_last_log_items" maxrows="10">
		
		<cfset a_str_content = getproperty( 'beanFactory' ).getBean( 'LogComponent' ).FormatSingleLogItem( entrykey =  q_select_last_log_items.entrykey,
						dt_created = q_select_last_log_items.dt_created,
						userkey = q_select_last_log_items.createdbyuserkey,
						affecteduserkey = q_select_last_log_items.affecteduserkey,
						action = q_select_last_log_items.action,
						param = q_select_last_log_items.param,
						objecttitle = q_select_last_log_items.objecttitle,
						pic = q_select_last_log_items.pic,
						linked_objectkey = q_select_last_log_items.linked_objectkey,
						createdbyusername = q_select_last_log_items.createdbyusername,
						options =  'small,nouserimage,smartdate') />
		#a_str_content#
		</cfoutput>
		</div>
			
	
	</cfif>
</cfif>
	
<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_friends' ) & ' (' & q_select_friends.recordcount & ')', 'group' )#</cfoutput>

<cfif q_select_friends.recordcount IS 0>
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
</cfif>

<cfquery name="q_select_facebook_friends" dbtype="query">
SELECT
	*
FROM
	q_select_friends
WHERE
	SOURCE = 1
;
</cfquery>

<cfquery name="q_select_friends" dbtype="query">
SELECT
	*
FROM
	q_select_friends
WHERE
	NOT otheruserkey = ''
ORDER BY
	otheruserkey,
	displayname
;
</cfquery>

<div class="div_container">
	<cfoutput query="q_select_friends" startrow="1" maxrows="12">
		
		#application.udf.writeDefaultImageContainer( application.udf.getUserImageLink( q_select_friends.displayname, 75 ),
								q_select_friends.displayname,
								'/user/' & Urlencodedformat( q_select_friends.displayname ),
								38,
								false,
								true )#
		
		<!--- <div class="div_user_box" style="background-image:URL('#htmleditformat( q_select_friends.photourl )#')">
			<span>#htmleditformat( q_select_friends.displayname )#</span>
		</div> --->
		<!--- #WriteUserBox( q_select_friends.displayname, '' )# --->
		<!--- <div style="margin-right:12px;margin-bottom:12px;float:left;width:auto;">
			<a title="#htmlEditformat( q_select_friends.displayname )#" class="add_as_tab" href="/user/#urlEncodedFormat( q_select_friends.displayname )#"><img src="#htmleditformat( q_select_friends.photourl )#" width="30" height="36" style="vertical-align:middle;padding:2px;border:0px" /> #htmlEditformat( q_select_friends.displayname )#</a>
		</div> --->
								
	</cfoutput>
	
	<div style="clear:both"></div>
	
</div>

<!--- fav artists --->

<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_ph_favourite_artists' ) & ' (' & q_select_favourite_artists.recordcount & ')', 'star' )#</cfoutput>

<cfif q_select_favourite_artists.recordcount IS 0>
	<div class="div_container">
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
	</div>
<cfelse>

<!--- <cfdump var="#q_select_favourite_artists#"> --->
	
	<cfquery name="q_select_favourite_artists" dbtype="query">
	SELECT
		*
	FROM
		q_select_favourite_artists
	ORDER BY
		randdata
	;
	</cfquery>
	
	<div class="div_container">
	<cfoutput query="q_select_favourite_artists" maxrows="12">
		
		#application.udf.writeDefaultImageContainer( application.udf.getArtistImageByID( q_select_favourite_artists.mbid, 120 ),
								q_select_favourite_artists.name,
								application.udf.generateArtistURL( q_select_favourite_artists.name, q_select_favourite_artists.mbid ),
								75,
								true,
								false )#
		
<!--- 		<div class="cBox cBox135">
			<div class="header"><a href="#application.udf.generateArtistURL( q_select_favourite_artists.name, q_select_favourite_artists.mbid )#" class="add_as_tab" title="#htmleditformat( q_select_favourite_artists.name )#">#htmleditformat( q_select_favourite_artists.name )#</a>
			</div>
			<div class="content" style="background-image:URL('#application.udf.getArtistImageByID( q_select_favourite_artists.mbid, 120 )#')">
				<a href="#application.udf.generateArtistURL( q_select_favourite_artists.name, q_select_favourite_artists.mbid )#" class="add_as_tab" title="#htmleditformat( q_select_favourite_artists.name )#"><img src="http://cdn.tunesBag.com/images/space1x1.png" class="linkimg"></a>
			</div>
		</div> --->
						
	</cfoutput>

	<div class="clear"></div>	
	
	<cfif q_select_favourite_artists.recordcount GT 12>

		<div class="div_container">
		<cfoutput query="q_select_favourite_artists" startrow="16">
			<a href="#application.udf.generateArtistURL( q_select_favourite_artists.name, q_select_favourite_artists.mbid )#" class="add_as_tab" title="#htmleditformat( q_select_favourite_artists.name )#">#htmleditformat( q_select_favourite_artists.name )#</a>, 
		</cfoutput>...
		</div>
	</cfif>
	</div>


</cfif>
<div class="clear"></div>



<cfoutput>#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_comments' ), 'page_cd_white' )#</cfoutput>
	<div class="div_container">
	<cfoutput>#application.udf.GetLangValSec( 'cm_ph_no_items_found' )#</cfoutput>
	</div>

</cfsavecontent>
