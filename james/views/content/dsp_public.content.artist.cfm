<!--- 

	informations about artist

 --->


<cfset q_select_artist = event.getArg( 'q_select_artist' ) />
<cfset q_select_albums = event.getArg( 'q_select_albums' ) />

<cfset a_artist = event.getArg( 'artist' ) />
<!--- <cfset q_select_recent_listeners = event.getArg( 'q_select_recent_listeners' ) /> --->
<cfset a_struct_info = event.getArg( 'a_struct_info', StructNew() ) />
<cfset q_select_compilations = a_struct_info.qCompilations />
<cfset a_bol_IsPublicView = event.getArg( 'IsPublicView', false ) />
<cfset sHTMLHeader = '' />

<!--- full bio= --->
<cfset a_bol_full_biography = event.getArg( 'biography', false ) />

<!--- search through the own library --->
<cfif NOT a_bol_IsPublicView AND application.udf.IsLoggedIn()>
	
	<cfset a_str_search_criteria = 'ARTISTS?VALUE=' & a_artist />
	
	<cfset a_search_result = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentDataMediaItems( securitycontext = application.udf.GetCurrentSecurityContext(),
						search_criteria = a_str_search_criteria,
						librarykeys =  getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( application.udf.GetCurrentSecurityContext() ) ) />
	
	<cfset q_select_local_tracks_of_artist = a_search_result.q_select_items />
	
	<cfset a_str_uuid_div = application.udf.ReturnJSUUID() />
</cfif>

<cfif q_select_artist.recordcount IS 0>
	<cfsavecontent variable="request.content.final">
		<h1><cfoutput>#htmleditformat( a_artist )#</cfoutput></h1>
		<h4>We're sorry, but we've no information stored about this artist.</h4>
	</cfsavecontent>
	<cfexit method="exittemplate">
</cfif>


<cfsavecontent variable="top_header">
<cfoutput>
	
<cfset showAd.Artist = a_artist />
<cfinclude template="snippets/inc_ad_moosify.cfm" />
	
	
<img src="/res/images/album.png" style="float:left;margin-right: 8px; width: 44px; height: 44px" alt="" />

<h1>#htmleditformat( a_artist )#</h1>
<p style="color:gray">
	Expore the Discography, Bio and Fun Facts about this artist!
</p>

<div style="padding-top:8px;padding-bottom: 8px">
<cfloop list="#q_select_artist.tags_artist#" delimiters=", " index="a_str_tag">
	<span class="tag_box">#trim( htmleditformat( a_str_tag ))#</span>
</cfloop>
</div>


</cfoutput>
</cfsavecontent>

<cfset event.setArg( 'top_content', trim( top_header )) />

<cfsavecontent variable="request.content.final">

<!--- <cfdump var="#cgi.THE_REQUEST#"> --->

<!--- facebook like --->
<!--- <div style="text-align:right">
<iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fwww.tunesBag.com%2F&amp;layout=standard&amp;show_faces=false&amp;width=450&amp;action=like&amp;colorscheme=light&amp;height=80" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:40px;" allowTransparency="true"></iframe>
</div> --->

<!--- <cfset sRedirectURL = "http://www.tunesBag.com/facebooktest" />
<cfset sFields = 'name,birthday,gender,location,email' />

<iframe src="http://www.facebook.com/plugins/registration.php?
             client_id=142010702538768&
             redirect_uri=<cfoutput>#UrlEncodedFormat( sRedirectURL )#</cfoutput>&
             fields=<cfoutput>#sFields#</cfoutput>"
        scrolling="auto"
        frameborder="no"
        style="border:none"
        allowTransparency="true"
        width="480"
        height="330">
</iframe> --->

<cfinclude template="snippets/inc_signup_public_hint.cfm">

	
<cfoutput query="q_select_artist">

<table>
<tr>
	<td>
	
		<div style="line-height:150%">
				
				<!--- artist img --->
				<!--- 
				#application.udf.writeDefaultImageContainer( application.udf.getArtistImageByID( q_select_artist.id, 300, q_select_artist.img_revision ),
								q_select_artist.name,
								'',
								160,
								false,
								false )# --->
					
					<!--- bio --->
					<cfif Len( q_select_artist.bio_en ) GT 0 AND q_select_artist.id GT 1>
						
						<cfif a_bol_full_biography>
							#ReplaceNoCase( application.udf.stripHTML( q_select_artist.bio_en ), Chr(10), '<br />', 'ALL')#
						<cfelse>						
							#ReplaceNoCase( application.udf.stripHTML( Left( q_select_artist.bio_en, 500 ) ), Chr(10), '<br />', 'ALL')# ...
							<!---  AND NOT a_bol_IsPublicView AND application.udf.IsLoggedIn() --->
							<cfif Len( q_select_artist.bio_en ) GT 500>
							<a href="#application.udf.generateArtistURL( q_select_artist.name, q_select_artist.id )#?biography=true" title="#htmleditformat( q_select_artist.name )#" class="add_as_tab">Read more ...</a>
							</cfif>
						</cfif>
						
					
					</cfif>
				
				<div class="clear"></div>
				
				<!--- <iframe border="0" style="border:0px" frameborder="0"  src="http://www.moosify.com/widgets/explorer/?partner=tunesbag&artist=<cfoutput>#urlencodedformat( q_select_artist.name )#</cfoutput>" width="720" height="90"></iframe> --->
				
				<div class="clear"></div>

				
				
				
				<!--- similar artists? --->
				<cfif StructKeyExists( a_struct_info, 'q_select_similar_artists') AND a_struct_info.q_select_similar_artists.recordcount GT 0>
					
					<cfset q_select_similar_artists = a_struct_info.q_select_similar_artists />
					
					<p style="margin-top:8px">
					<i class="icon-magnet"></i>
					<cfloop query="q_select_similar_artists" endrow="7">
						<a href="#application.udf.generateArtistURL( q_select_similar_artists.similar_artist, q_select_similar_artists.ARTISTDEST_MBID )#" title="#htmleditformat( q_select_similar_artists.similar_artist )#" class="add_as_tab">#htmleditformat( q_select_similar_artists.similar_artist )#</a>,
					</cfloop> ...
					</p>
					
					
				</cfif>
				
				
				<cfquery name="qSelectConnections" datasource="mytunesbutler_mb">
				SELECT
					conn.link0,
					conn.link1,
					conn.link_type,
					lt.rlinkphrase,
					otherartist.name<!--- ,
					otherartist2.name AS otherartistname --->
				FROM
					l_artist_artist AS conn
				LEFT JOIN
					 lt_artist_artist AS lt ON (lt.id = conn.link_type)
				LEFT JOIN
					artist AS otherartist ON (otherartist.id = conn.link0)
				<!--- LEFT JOIN
					artist AS otherartist2 ON (otherartist2.id = conn.link1) --->
				WHERE
					conn.link1 = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_artist.id#" />
					<!--- OR
					conn.link0 = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_artist.id#" /> --->
					AND
					link_type = 2
				;
				</cfquery>
				
				<cfif qSelectConnections.recordcount GT 0>
					<p style="margin-top:8px">
						#application.udf.si_img( 'group' )#
						<cfloop query="qSelectConnections">
					<a href="#application.udf.generateArtistURL( qSelectConnections.name, qSelectConnections.link0 )#" title="#qSelectConnections.name#" class="add_as_tab">#htmleditformat( qSelectConnections.name )#</a>,
					</cfloop>...
					</p>
					
				</cfif>
				
				<!--- fans --->
				<!--- <cfif StructKeyExists( a_struct_info, 'q_select_fans_of_artist') AND a_struct_info.q_select_fans_of_artist.recordcount GT 0>
			
					<cfset q_select_fans_of_artist = a_struct_info.q_select_fans_of_artist />
					
					<p style="margin-top:8px">
						#application.udf.si_img( 'heart' )# #application.udf.GetLangValSec( 'lib_ph_status_artist_has_fans', q_select_fans_of_artist.recordcount )#:
						
						<cfloop query="q_select_fans_of_artist">
							<a href="/user/#htmleditformat( q_select_fans_of_artist.username )#" class="add_as_tab" title="#htmleditformat( q_select_fans_of_artist.username )#">#htmleditformat( q_select_fans_of_artist.username )#</a>,
						</cfloop> ...
					</p>
				
				</cfif> --->
				
						
		<cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( q_select_artist.name , q_select_artist.id  )#' />

		
		<!--- <cfoutput>
		<iframe id="facebooklikeartist" src="http://www.facebook.com/plugins/like.php?href=#UrlEncodedFormat( sURL )#&amp;layout=standard&amp;show_faces=true&amp;width=600px&amp;height=65px&amp;action=like&amp;colorscheme=evil" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:600px; height: 65px"></iframe>
		</cfoutput> --->
				
				<cfif Len( q_select_artist.tags_artist ) GT 0>
					
					
					<p style="margin-top:8px">
					</p>
				</cfif>
			
			</div>
		<div class="clear"></div>
		
		<!--- #application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_comments' ), '' )#
		
		<div id="fb-root"></div>
		<script src="http://connect.facebook.net/en_US/all.js##xfbml=1"></script>
		<fb:comments href="#htmleditformat( sURL )#" num_posts="2" width="600"></fb:comments> --->

		<!--- playlists with this artists --->
		<cfif StructKeyExists( a_struct_info, 'q_select_playlists' ) AND a_struct_info.q_select_playlists.recordcount GT 0>

			<cfset q_select_playlists = a_struct_info.q_select_playlists />

			<h2 class="feature">Playlists <span class="muted">with tracks of this artist</span></h2>
			

				<table class="table">
					<cfloop query="q_select_playlists">
						<tr>
							<td>
								
								<!--- <cfif q_select_playlists.imageset IS 1> --->
								#application.udf.writeDefaultImageContainer( 'http://cdn.tunesbag.com/images/unknown_album_120x120.png',
									application.udf.CheckZeroString( q_select_playlists.name ),
									q_select_playlists.href,
									38,
									false,
									true )#
								<!--- <cfelse>
									#application.udf.writeDefaultImageContainer( application.const.S_DEFAULT_COVERART,
									application.udf.CheckZeroString( q_select_playlists.name ),
									q_select_playlists.href,
									38,
									false,
									true )#
								</cfif> --->								
								
							</td>
							<td>
								<a style="font-weight:bold" class="add_as_tab" title="#application.udf.GetLangValSec( 'cm_wd_playlist' )#" href="#q_select_playlists.href#">#htmleditformat( q_select_playlists.name )#</a>
								<br />
								#htmleditformat( q_select_playlists.description )#
								<cfloop list="#q_select_playlists.tags#" index="a_str_tag" delimiters=", ">
									<span class="tag_box">#htmleditformat( trim( a_str_tag ))#</span>
								</cfloop>
							</td>
							
						</tr>
					</cfloop>
				</table>
				

		</cfif>		
		

		
		<!--- <cfif NOT a_bol_IsPublicView AND application.udf.IsLoggedIn() AND q_select_local_tracks_of_artist.recordcount GT 0>
			#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_ph_artist_info_what_your_local_tracks' ) , '' )#
			
			<div class="div_container" id="id_div_tracks_of_this_artist#a_str_uuid_div#"></div>
			
			<!--- generate licence information --->
			<cfset stLicencePermissions = application.beanFactory.getBean( 'LicenceComponent' ).applyLicencePermissionsToRequest(securitycontext = application.udf.GetCurrentSecurityContext(),
					 sRequest = 'PLAYLIST',
					 bOwnDataOnly = true  ) />
			
			<cfset a_struct_return = application.udf.SimpleBuildOutput(  query = q_select_local_tracks_of_artist,
										securitycontext = application.udf.GetCurrentSecurityContext(),
										type = 'internal',
										target = '##id_div_tracks_of_this_artist#a_str_uuid_div#',
										force_id = '',
										columns = 'album,name,action,rating',
										lastkey = '',
										setActive = false,
										playlistkey = '',
										options = '',
										STLICENCEPERMISSIONS = stLicencePermissions ) />
					
			#a_struct_return.html_content#
		</cfif> --->
		
		
		<!--- display albums --->
		<cfif IsQuery( q_select_albums ) AND q_select_albums.recordcount GT 0>
			<h2 class="feature">#application.udf.GetLangValSec( 'cm_wd_albums' )#</h2>


			<cfloop query="q_select_albums">
				
				#application.udf.writeDefaultImageContainer( ( Len( q_select_albums.coverarturl ) ? q_select_albums.coverarturl : 'http://cdn.tunesbag.com/images/unknown_album_120x120.png'),
								q_select_albums.name,
								generateAlbumURL( q_select_albums.artist_name, q_select_albums.name, q_select_albums.id ),
								100,
								true,
								true )#
				
			</cfloop>

			<div class="clear"></div>
		</cfif>
		
		<!--- links --->
		
		

<!--- <cfdump var="#qSelectConnections#"> --->
<!--- <cfset cachePut('hello1',qSelectConnections)>
<h1>from cache</h1>
<cfdump var="#cacheGet( 'hello1')#">
<cfdump var="#cacheGetAllIds()#"> --->
		<!--- connections ... --->
		<!--- <cfif qSelectConnections.recordcount GT 0>
			#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_members' ) & ' (' & qSelectConnections.recordcount & ')', '' )#
			<div class="div_container compilations">
				
				<cfquery name="qSelectMembers" dbtype="query">
				SELECT
					*
				FROM
					qSelectConnections
				WHERE
					link_type = 2
					AND
					link1 = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_artist.id#" />
				</cfquery>
				
				#application.udf.GetLangValSec( 'cm_wd_members' )#
				<cfloop query="qSelectMembers">
					<a href="#application.udf.generateArtistURL( qSelectMembers.name, qSelectMembers.link0 )#" title="#qSelectMembers.name#" class="add_as_tab">#qSelectMembers.name#</a>
				</cfloop>
				
				<cfquery name="qSelectCollaborations" dbtype="query">
				SELECT
					*
				FROM
					qSelectConnections
				WHERE
					link_type = 11
					AND
					link0 = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_artist.id#" />
				</cfquery>
				
				<!--- <cfdump var="#qSelectCollaborations#"> --->
			</div>
		</cfif> --->

		<cfif q_select_compilations.recordcount GT 0>
			
			<script type="text/javascript"><!--
			google_ad_client = "ca-pub-5279195474591127";
			/* banner footer */
			google_ad_slot = "8431393531";
			google_ad_width = 728;
			google_ad_height = 90;
			//-->
			</script>
			
			<div class="ad">
			<script type="text/javascript"
			src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
			</div>
			
			<h2 class="feature">#application.udf.GetLangValSec( 'cm_wd_compilations' )# <span class="muted">Collections that matter</span></h2>
		
			<div class="div_container compilations">
				<cfloop query="q_select_compilations" endrow="6">
					
					#application.udf.writeDefaultImageContainer( 'http://cdn.tunesbag.com/images/unknown_album_120x120.png',
								q_select_compilations.album_name,
								generateAlbumURL( 'Various Artists', q_select_compilations.album_name, q_select_compilations.album_id ),
								100,
								true,
								true )#
				
					
					<!--- <div class="cBox cBox135">
					<div class="header"><a href="#generateAlbumURL( 'Various Artists', q_select_compilations.album_name, q_select_compilations.album_id )#" class="add_as_tab" title="#htmleditformat( q_select_compilations.album_name )#">#htmleditformat( q_select_compilations.album_name )#</a>
					</div>
					<div class="content" style="background-image:URL('#getAlbumArtworkLink( q_select_compilations.album_id, 120 )#')">
						<a href="#generateAlbumURL( 'Various Artists', q_select_compilations.album_name, q_select_compilations.album_id )#" class="add_as_tab" title="#application.udf.GetLangValSec( 'cm_wd_compilation' )# #htmleditformat( q_select_compilations.album_name )#"><img src="http://deliver.tunesbagcdn.com/images/space1x1.png" class="linkimg" alt="#application.udf.GetLangValSec( 'cm_wd_compilation' )# #htmleditformat( q_select_compilations.album_name )#" /></a>
					</div> --->
				
					
				</cfloop>
				
				
				<div class="clear"></div>
				
				<cfif q_select_compilations.recordcount GT 6>
					<div class="div_container">
					<cfloop query="q_select_compilations" startrow="7" endrow="15">
						<a href="#generateAlbumURL( 'Various Artists', q_select_compilations.album_name, q_select_compilations.album_id )#" class="add_as_tab" title="#htmleditformat( q_select_compilations.album_name )#">#htmleditformat( q_select_compilations.album_name )#</a>, 
					</cfloop>...
					</div>
					<!--- <a href="##" onclick="$('.compilations div.hidden').removeClass('hidden');return false" style="font-weight:bold">#application.udf.si_img( 'application_side_expand' )# #application.udf.GetLangValSec( 'cm_ph_show_more' )#</a> --->
				</cfif>
			</div>
			
		</cfif>
		
		
		<!---  AND a_struct_info.q_select_artist_events.recordcount GT 0>
		
			<cfset q_select_artist_events = a_struct_info.q_select_artist_events />
			
			#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_events' ), '')#
			
			<div class="div_container artist_event_items">
				<cfloop query="q_select_artist_events">
							
					<div style="margin-bottom:6px;margin-right:6px;float:left;width:240px;<cfif q_select_artist_events.currentrow GT 4>display:none</cfif>">
						
					<div class="cal_box">
					<span class="cal_box_month">
						#LsDateFormat( q_select_artist_events.start, 'mmm')#
					</span>
					<div class="clear"></div>
					<span class="bb bl br cal_box_day">#Day( q_select_artist_events.start )#</span>
					
					</div>
					
					<cfif Len( q_select_artist_events.url ) GT 0>
						<a href="#q_select_artist_events.url#" target="_blank">#htmleditformat( application.udf.ShortenString( q_select_artist_events.name, 24) )#</a>
					<cfelse>
						#htmleditformat( application.udf.ShortenString( q_select_artist_events.name, 24) )#
					</cfif>
					<br />
					#htmleditformat( q_select_artist_events.venue_name )#, #htmleditformat( q_select_artist_events.city )#, #htmleditformat( q_select_artist_events.country )#
					
					<cfif q_select_artist_events.source IS 'jambase'>
						<br />
						<span class="addinfotext">powered by <a href="#q_select_artist_events.url#" target="_blank"><img src="http://deliver.tunesbagcdn.com/images/partner/jambase-favicon.png" class="si_img" alt="jambase" /></a></span>
					</cfif>
					</div>
					
					<cfif q_select_artist_events.currentrow MOD 2 IS 0>
						<div class="clear"></div>
					</cfif>
				
				</cfloop>
				
				<cfif q_select_artist_events.recordcount GT 3>
					<a href="##" onclick="$('.artist_event_items div').slideDown();$(this).hide();return false">#application.udf.GetLangValSec( 'cm_ph_show_all_events' )#</a>
				</cfif>
				
				<div class="clear" style="margin-bottom:4px"></div>
		
			</div>
		</cfif> --->
		
		<cfif StructKeyExists( a_struct_info, 'q_select_artist_links' ) AND a_struct_info.q_select_artist_links.recordcount GT 0>
			#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_links' ), '')#
			
			<div class="div_container">
				<ul class="ul_nopoints">
				<cfloop query="a_struct_info.q_select_artist_links">
					<li><a target="_blank" href="#a_struct_info.q_select_artist_links.url#">#htmleditformat( a_struct_info.q_select_artist_links.description )#</li>
				</cfloop>
				</ul>
				
			</div>
		</cfif>
		
		</cfoutput>
		<br />
		Content provided by 
		<a href="http://www.musicbrainz.org/">musicbrainz</a>,

		<a href="http://www.amazon.com">amazon</a> and <a href="http://www.songkick.com">songkick</a>.
		
		<br /><br />
		<span class="addinfotext">
		The search/indexing interface contains content from public sources and links to other websites.
		tunesBag neither controls nor endorses these web sites, nor reviews or approves any content appearing on them.
		tunesBag does not assume any responsibility or liability for any materials available,
		or for the completeness, availability, accuracy, legality or decency.
		</span>
		
	</td>
	<cfif a_bol_IsPublicView>
	<td style="width:180px;padding: 12px" class="bl">

		<g:plusone href="http://www.tunesBag.com/"></g:plusone>
		<br />
		
		<cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( q_select_artist.name , q_select_artist.id  )#' />

		<!--- facebook like --->
		<!--- <h4>Tell your friends</h4> --->
		
		<a href="http://www.addthis.com/bookmark.php"><img width="125" height="16" alt="AddThis Social Bookmark Button" src="http://deliver.tunesbagcdn.com/images/partner/button1-share.gif" style="vertical-align: middle; border: 0px none;" /></a>
		<br />
		
		
	
	</td>
	</cfif>
</tr>
</table>


</cfsavecontent>

<!--- ' & application.udf.GetLangValSec( 'cm_wd_artist' ) & ' --->
<cfset event.setArg( 'PageTitle', a_artist & ' - ' & ' Music, Bio and Gossip' ) />

<cfsavecontent variable="a_str_meta">
<cfoutput>
Information about the artist #a_artist#
<cfif Len( q_select_artist.tags_artist ) GT 0>
tagged as 
<cfloop list="#q_select_artist.tags_artist#" delimiters=", " index="a_str_tag">
#trim( htmleditformat( a_str_tag ))#,
</cfloop>
by users
</cfif>.
List tracks and informations of albums like
<cfloop query="q_select_albums" endrow="5">
#q_select_albums.name#,
</cfloop>...
<cfif StructKeyExists( a_struct_info, 'q_select_playlists' ) AND a_struct_info.q_select_playlists.recordcount GT 0>
Finally, listen to more than #a_struct_info.q_select_playlists.recordcount# playlist(s) like
<cfloop query="a_struct_info.q_select_playlists" endrow="5">
#a_struct_info.q_select_playlists.name#,
</cfloop>... with tracks of this artist
</cfif>
</cfoutput>
</cfsavecontent>

<cfset a_str_meta = ReplaceNoCase( a_str_meta, chr(10), ' ', 'ALL' ) />
<cfset a_str_meta = ReplaceNoCase( a_str_meta, '  ', ' ', 'ALL') />
<cfset a_str_meta = Trim( a_str_meta ) />

<cfset event.setArg( 'PageDescription',a_str_meta) />


<cfif a_bol_IsPublicView>
	<!--- http://developers.facebook.com/docs/opengraph --->
	<cfsavecontent variable="sHTMLHeader">

	<!--- get image from main host --->
	<cfset sImage = application.udf.getArtistImageByID( q_select_artist.id, 300, 0 ) />
	
	<cfif FindNoCase( 'http://', sImage ) NEQ 1>
		<cfset sImage = 'http://' & cgi.server_name & sImage />
	</cfif>
		
	<cfoutput>
	<!--- previously generated content --->
	#sHTMLHeader#

	<!--- <!-- opengraph / facebook -->
	<meta property="og:title" content="tunesBag"/>
	<meta property="og:type" content="product" />
	<meta property="og:url" content="http://www.tunesBag.com"/>
	<meta property="og:site_name" content="tunesBag.com" />
	<meta property="og:image" content="http://deliver.tunesbagcdn.com/images/skins/default/bgLogoLeftTop.png" />
	<meta property="og:description" content="Cloud Music Service for your own collection" />
	<!--- <meta property="fb:app_id" content="39900567213"/> --->
	<meta property="fb:admins" content="9533443900,523658434"/> --->

	</cfoutput>
	
	</cfsavecontent>
	
</cfif>


<!--- return XML format --->
<cfif event.getArg( 'DocumentOutputFormat' ) IS 'XML'>
	
	<cfxml variable="xData">
	<cfoutput>
	<data>
		<hash>#xmlFormat( event.getArg( 'sCacheKey' ) )#</hash>
		<created>#Now()#</created>
		<server>#xmlformat( cgi.local_host )#</server>
		<title>#xmlformat( event.getArg( 'PageTitle' ) )#</title>
		<htmlhead>#xmlformat( sHTMLHeader )#</htmlhead>
		<body>#xmlformat( request.content.final )#</body>
	</data>
	</cfoutput>
	</cfxml>

	<cfset request.content.final = ToString( xData ) />

<cfelse>

	<!--- output html header --->
	<cfhtmlhead text="#sHTMLHeader#" />

	<cfset bCachedVersionExists = getProperty( 'beanFactory' ).getBean( 'SimpleEHCache' ).AddItemToCache( event.getArg('sCacheKey'), { content = request.content.final, title = event.getArg( 'PageTitle' ),  description = event.getArg( 'PageDescription' ), HTMLHeader = sHTMLHeader } ) />


</cfif>


