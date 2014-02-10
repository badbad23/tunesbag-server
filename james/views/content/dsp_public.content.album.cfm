<!--- 

	informations about album

 --->



<cfset q_select_album_tracks = event.getArg( 'q_select_album_tracks' ) />
<cfset a_artist = event.getArg( 'artist' ) />
<cfset q_select_other_alben = event.getArg( 'q_select_other_alben' ) />
<cfset q_select_album = event.getArg( 'q_select_album' ) />
<cfset q_select_recent_listeners = event.getArg( 'q_select_recent_listeners' ) />
<cfset a_bol_IsPublicView = event.getArg( 'IsPublicView', false ) />
<cfset stArtistInfo = event.getArg( 'stArtistInfo', {} ) />
<cfset bAjax = event.getArg( 'ajax', false ) />

<cfsavecontent variable="request.content.final">

<cfif bAjax>
<div class="headlinebox">
	<p class="title"><cfoutput>#htmleditformat( trim( q_select_album.name) )#</cfoutput></p>
	<p><cfoutput>#application.udf.GetLangValSec( 'cm_wd_album' )#</cfoutput></p>
</div>
<cfelse>
	
	<cfinclude template="snippets/inc_signup_public_hint.cfm">
	
</cfif>


<cfsavecontent variable="top_header">
<cfoutput>


<cfset showAd.Artist = q_select_album.artist_name />
<cfinclude template="snippets/inc_ad_moosify.cfm" />
	
	
<img src="/res/images/album.png" style="float:left;margin-right: 8px; width: 44px; height: 44px" alt="" />
<a href="#application.udf.generateArtistURL( q_select_album.artist_name, q_select_album.artist )#"><h4>#htmleditformat( q_select_album.artist_name )#</h4></a>
<h1>#htmleditformat( q_select_album.name )#</h1>
<p style="color:gray">
	
	<cfif Len( q_select_album.releasedate ) GT 0>
						Released #Left( q_select_album.releasedate, 4)#
						&nbsp;|&nbsp;
					</cfif>

	
	Buy at
	<a target="_blank" rel="nofollow" onclick="pageTracker._trackPageview( '/affiliate/itunes/' );" title="Buy track at iTunes" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat( a_artist )#&amp;album=#UrlEncodedFormat( q_select_album.name )#&amp;provider=itunes">iTunes</a>
</p>

</cfoutput>
</cfsavecontent>

<cfset event.setArg( 'top_content', trim( top_header )) />

<div class="div_container" <cfif NOT a_bol_IsPublicView>style="max-width: 800px"</cfif>>
<table class="tbl_td_top" style="width:100%">
<tr>
	<td>
	
	
			
	<!--- 
		<cfoutput query="q_select_album">
		<table style="width:100%">
			<tr>
				<td style="vertical-align: top; width: 135px;padding-top:12px">
					
								
					
				</td>
				<td style="padding: 12px; vertical-align:middle">
				
					
					<!--- <div class="addinfotext">
						Buy now at 
						<a target="_blank" rel="nofollow" onclick="pageTracker._trackPageview( '/affiliate/amazon/' );" title="MP3 Download / Buy track at amazon" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat( a_artist )#&amp;album=#UrlEncodedFormat( q_select_album.name )#&amp;provider=amazon"><img src="http://deliver.tunesbagcdn.com/images/partner/amazon-logo-101x24.png" style="border:0px;margin:4px;vertical-align:middle" width="101" height="24" alt="Buy at amazon" title="Buy at amazon" /> MP3 Download</a>
						|
						
						|
						<a target="_blank" rel="nofollow" onclick="pageTracker._trackPageview( '/affiliate/7digital/' );" title="Buy track at 7digital" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat( a_artist )#&amp;album=#UrlEncodedFormat( q_select_album.name )#&amp;provider=7digital">7digital</a>
						<!--- <a target="_blank" rel="nofollow" title="Buy track" href="/rd/aff/buy/?app=&artist=#urlEncodedFormat( a_artist )#&album=#UrlEncodedFormat( q_select_album.name )#">#application.udf.si_img( 'basket' )# Buy album online</a>
						&nbsp;&nbsp; --->
						<!--- <a href="http://www.addthis.com/bookmark.php" onclick="addthis_url = location.href; addthis_title = document.title; return addthis_click(this);" target="_blank"><img style="vertical-align:middle;border:0px" src="http://deliver.tunesbagcdn.com/images/partner/button1-share.gif" width="125" height="16" alt="AddThis Social Bookmark Button" /></a> <script type="text/javascript">var addthis_pub = 'tunesbag';</script><script type="text/javascript" src="http://s9.addthis.com/js/widget.php?v=10"></script>   --->
					</div> --->
			
				</td>
				</tr>
			</table>
			</cfoutput>	
			
			<div class="clear"></div> --->
			
			<cfoutput>
			
<!--- 
			<iframe border="0" style="border:0px" frameborder="0" src="http://www.moosify.com/widgets/explorer/?partner=tunesbag&artist=<cfoutput>#urlencodedformat( q_select_album.artist_name )#</cfoutput>" width="720" height="90"></iframe>
 --->
				
				<div class="clear"></div>
				
				
				
				
			
<h2 class="feature">#application.udf.GetLangValSec( 'cm_wd_tracks' )#</h2>

<!--- min height to show the full ad --->
				<div>
						<table class="table table-striped">
						<cfloop query="q_select_album_tracks">
							<tr>		
								<td>
									#Val( q_select_album_tracks.sequence )#
								</td>
								<td>
									<!--- <a target="_blank" rel="nofollow" onclick="pageTracker._trackPageview( '/affiliate/amazon/track' );" title="MP3 Download / Buy track at amazon" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat( q_select_album_tracks.artist_name )#&amp;title=#UrlEncodedFormat( q_select_album_tracks.track_name )#&amp;provider=amazon">#application.udf.si_img( 'cart' )#</a> --->

									<a
												
										 href="#generateGenericURLToTrack( q_select_album_tracks.artist_name, q_select_album_tracks.track_name, q_select_album_tracks.track, '' )#"><img src="http://deliver.tunesbagcdn.com/images/skins/default/btnPlay16x16.png" class="si_img" alt="Play" /> #htmleditformat( q_select_album_tracks.track_name )#</a>
									
									<cfif CompareNoCase( a_artist, q_select_album_tracks.artist_name ) NEQ 0>
										/
										<a href="#application.udf.generateArtistURL( q_select_album_tracks.artist_name, q_select_album_tracks.artist_id )#">#htmleditformat( q_select_album_tracks.artist_name )#</a>
									</cfif>
									
								</td>
								<td>
									#application.udf.FormatSecToHMS( q_select_album_tracks.tracklen )#
								</td>
							</tr>
						</cfloop>
						</table>
			</div>
			
			<cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( q_select_album.artist_name , q_select_album.artist  )#' />
			
			<!--- #application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_comments' ), '' )#
		
			<div id="fb-root"></div>
			<script src="http://connect.facebook.net/en_US/all.js##xfbml=1"></script>
			<fb:comments href="#htmleditformat( sURL )#" num_posts="2" width="600"></fb:comments> --->
			
			
			<div class="ad">
					
					<cfoutput>
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
					</cfoutput>
					
				</div>
			
			<!--- othe albums --->
			<cfif q_select_other_alben.recordcount GT 0>
			
						
				<h2 class="feature">#application.udf.GetLangValSec( 'cm_wd_albums' )#</h2>
				
				<div class="div_container">
				<cfloop query="q_select_other_alben">
					
					#application.udf.writeDefaultImageContainer( 'http://cdn.tunesbag.com/images/unknown_album_120x120.png',
								q_select_other_alben.name,
								generateAlbumURL( a_artist, q_select_other_alben.name, q_select_other_alben.id ),
								100,
								true,
								true )#
					
					
				</cfloop>
				</div>
			</cfif>
			
			</cfoutput>
			
			<div class="clear"></div>
			

			
			
			<br />
			<cfoutput>
Try direct <a target="_blank" rel="nofollow" title="Buy track" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat(  q_select_album.artist_name )#&amp;album=#UrlEncodedFormat( q_select_album.name  )#&amp;provider=amazon">mp3 download</a> instead of rapidshare, mediafire, megaupload or torrent.
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
		<br /><br />
	
	</td>
	<!--- <cfif a_bol_IsPublicView>
		<td style="width:180px;padding: 12px" class="bl">
			
			
			
			<!--- <cfif StructKeyExists( stArtistInfo, 'stLoadEvents' )>
			<cfset stEvents = stArtistInfo.stLoadEvents />
			
			<!--- everything ok? --->
			<cfif stEvents.result>
				
				<cfoutput>#application.beanFactory.getBean( 'Songkick' ).formatEventData( stEvents.qEvents )#</cfoutput>
				
			<cfelse>
				
				<!--- load from server ... --->
				<cfif stEvents.error IS 201>
					<!--- we should perform an ajax request --->
					
					<cfoutput>
						<script type="text/javascript">
						loadArtistConcertEvents( '#q_select_album.artist#', 'concertsOutput' );
						</script>
						
					</cfoutput>
					
					<div id="concertsOutput" style="margin-top:12px">
						<div class="div_container" style="text-align:center">
						<img src="http://deliver.tunesbagcdn.com/images/ajax-loader.gif" alt="" />
						</div>
					</div>
					
				</cfif>
				
			</cfif>
		</cfif> --->
			
			
			
			<cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( q_select_album.artist_name , q_select_album.artist  )#' />
			
			<!--- <cfoutput>
			<iframe id="facebooklikeartist" src="http://www.facebook.com/plugins/like.php?href=#UrlEncodedFormat( sURL )#&amp;layout=standard&amp;show_faces=true&amp;width=240px&amp;height=65px&amp;action=like&amp;colorscheme=evil" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:160px; height: 65px"></iframe>
			</cfoutput> --->
			

			
			<!--- <form action="http://www.google.com/cse" id="cse-search-box" style="padding-bottom:20px">
			  <div>
			    <input type="hidden" name="cx" value="010934425247403868513:rldsqudqhgu" />
			    <input type="hidden" name="ie" value="UTF-8" />
			    <input type="text" name="q" size="14" />
			    <input type="submit" name="sa" value="Search" />
			  </div>
			</form> --->
			
			<!--- <script type="text/javascript"><!--
			google_ad_client = "pub-5279195474591127";
			/* MBInfo Right 160x600, Erstellt 19.12.08 */
			google_ad_slot = "5637574774";
			google_ad_width = 160;
			google_ad_height = 600;
			//-->
			</script>
			<script type="text/javascript"
			src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script> --->
			
					<!--/* OpenX iFrame Tag v2.8.1 */-->
		<!--- <cfset sUnique = CreateUUID() />
		<br /><br />		
		<cfoutput>
		<iframe id='a600110e' name='a600110e' src='http://ads.tunesbag.com/www/delivery/afr.php?zoneid=5&amp;cb=#sUnique#' framespacing='0' frameborder='0' scrolling='no' width='160' height='600'><a href='http://ads.tunesbag.com/www/delivery/ck.php?n=acd02a30&amp;cb=#sUnique#' target='_blank'><img src='http://ads.tunesbag.com/www/delivery/avw.php?zoneid=5&amp;cb=#sUnique#&amp;n=acd02a30' border='0' alt='' /></a></iframe>
		</cfoutput> --->

		
		</td>
	</cfif> --->
</tr>
</table>

</div>
</cfsavecontent>

<!---  & application.udf.GetLangValSec( 'cm_wd_album' ) & ' --->
<cfset event.setArg( 'PageTitle', q_select_album.name & ' - ' & a_artist ) />
<!--- <cfset event.setArg( 'PageDescription', 'Is a fan of ' & ValueList( q_select_favourite_artists.artist ) & '; has several playlists like ' & ValueList( q_select_playlists.name, ', ') ) /> --->

<cfsavecontent variable="a_str_meta">
<cfoutput>
Listen to tracks of the album #q_select_album.name# by #a_artist# now. Available tracks are #ValueList( q_select_album_tracks.track_name, ', ' )#
</cfoutput>
</cfsavecontent>

<cfset a_str_meta = ReplaceNoCase( a_str_meta, chr(10), ' ', 'ALL' ) />
<cfset a_str_meta = ReplaceNoCase( a_str_meta, '  ', ' ', 'ALL') />
<cfset a_str_meta = Trim( a_str_meta ) />

<cfset event.setArg( 'PageDescription',a_str_meta) />