<!--- 

	informations about track

 --->

<cfset q_select_track = event.getArg( 'q_select_track' ) />
<cfset q_select_album_tracks = event.getArg( 'q_select_album_tracks' ) />
<cfset q_select_other_alben = event.getArg( 'q_select_other_alben' ) />
<cfset q_select_playlists = event.getArg( 'q_select_playlists' ) />
<cfset a_bol_IsPublicView = event.getArg( 'IsPublicView', false ) />
<cfset a_bol_is_recommendation = event.IsArgDefined( 'rec' ) />
<cfset a_bol_autostart = event.getArg( 'autostart', false ) />

<cfset stArtistInfo = event.getArg( 'stArtistInfo', {} ) />

<!--- in case of a recommendation, do an autostart --->
<cfif a_bol_is_recommendation>
	<cfset a_bol_autostart = true />
</cfif>

<cfset stYTHits = event.getArg( 'stYTHits' ) />

<cfif q_select_track.recordcount IS 0>
	<cfsavecontent variable="request.content.final">
		<div class="status">
			<h2>This track does not exist or has been deleted.</h2>
		</div>
	</cfsavecontent>
	<cfexit method="exittemplate">
</cfif>

<!--- check redirect --->
<!--- 
<cfquery name="moo" datasource="moosify">
SELECT		s.uri
FROM		seouri AS s
LEFT JOIN	custom_tracks AS t ON (t.track_ID = s.id)
LEFT JOIN	custom_artists AS a ON (a.artist_id = t.artist_id)
WHERE		s.status = 1
			AND
			a.mbid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_track.artist_gid#" />
			AND
			t.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_Select_track.track_name#" />
</cfquery>

<cfif moo.recordcount IS 1>
	<cflocation addtoken="false" url="http://www.moosify.com/t/#moo.uri#" statuscode="301" />
</cfif> --->

<cfsavecontent variable="request.content.final">

<cfif a_bol_IsPublicView>
	<cfinclude template="snippets/inc_signup_public_hint.cfm">
</cfif>

<cfsavecontent variable="top_header">
<cfoutput>
	
<cfset showAd.Artist = q_select_track.artist_album />
<cfinclude template="snippets/inc_ad_moosify.cfm" />
	
<ol class="breadcrumb">
	<li><a href="/">Home</a></li>
<!--- 	<li>/ <a href="/">Artists "#UCase( Left( q_select_track.artist_name, 1 ))#"</a></li> --->
	<li>/ <a href="#application.udf.generateArtistURL( q_select_track.artist_album, q_select_track.mb_artistid_album )#">#htmleditformat( q_select_track.artist_album )#</a></li>
	<li>/ <a href="#generateAlbumURL( q_select_track.artist_name, q_select_track.album_name, q_select_track.mb_albumid )#">#htmleditformat( q_select_track.album_name )#</a></li>
	<li class="active">#htmleditformat( q_select_track.track_name )#</li>
</ol>

<!--- <a href="#application.udf.generateArtistURL( q_select_track.artist_album, q_select_track.mb_artistid_album )#"><h4>#htmleditformat( q_select_track.artist_album )#</h4></a> --->
<h1>#htmleditformat( q_select_track.track_name )#</h1>
<p style="color:gray">
	Relased on <a href="#generateAlbumURL( q_select_track.artist_name, q_select_track.album_name, q_select_track.mb_albumid )#">#htmleditformat( q_select_track.album_name )#</a>
	&nbsp;|&nbsp;
	#application.udf.FormatSecToHMS( q_select_track.length )#
	&nbsp;|&nbsp;
	Buy at <a target="_blank" rel="nofollow" title="Buy track" onclick="pageTracker._trackPageview( '/affiliate/itunes/' );" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat(  q_select_track.artist_name )#&amp;title=#UrlEncodedFormat( q_select_track.track_name  )#&amp;provider=itunes">iTunes</a>
</p>

</cfoutput>
</cfsavecontent>

<cfset event.setArg( 'top_content', trim( top_header )) />

<cfoutput query="q_select_track">

<!--- 
<table style="width:100%" class="bb">
	<tr>
	<!--- <td style="vertical-align: middle; width: 70px">
		
		#application.udf.writeDefaultImageContainer( application.udf.getArtistImageByID( q_select_track.artist_id, 120 ),
								q_select_track.artist_name,
								application.udf.generateArtistURL( q_select_track.artist_name, q_select_track.artist_id ),
								75,
								false,
								false )#

	</td> --->
	<td style="padding: 12px; vertical-align:middle">
	
<!--- <p>

	
	<cfif q_select_track.artist_album NEQ q_select_track.artist_name>
		(<a href="#application.udf.generateArtistURL( q_select_track.artist_name, q_select_track.artist_id )#">#htmleditformat( q_select_track.artist_name )#</a>, ...)
	</cfif>

	
</p> --->


<div style="float:right;text-align:center">
	<!--- <a target="_blank" rel="nofollow" title="Buy track" onclick="pageTracker._trackPageview( '/affiliate/amazon/' );" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat(  q_select_track.artist_name )#&amp;title=#UrlEncodedFormat( q_select_track.track_name  )#&amp;provider=amazon"><img src="http://deliver.tunesbagcdn.com/images/partner/amazon-logo-101x24.png" style="border:0px;margin:4px;vertical-align:middle" width="101" height="24" alt="Buy at amazon" title="MP3 Download @ Amazon" /> MP3 Download</a>
	<br />
	Other hits: --->
	<a target="_blank" rel="nofollow" title="Buy track" onclick="pageTracker._trackPageview( '/affiliate/itunes/' );" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat(  q_select_track.artist_name )#&amp;title=#UrlEncodedFormat( q_select_track.track_name  )#&amp;provider=itunes">Buy at iTunes</a>
	<!--- <br />
	<a href="http://www.addthis.com/bookmark.php"><img width="125" height="16" alt="AddThis Social Bookmark Button" src="http://deliver.tunesbagcdn.com/images/partner/button1-share.gif" style="vertical-align: middle; border: 0px none;" /></a> --->

</div>
	
	</td>
	</tr>
</table>
 --->
<!--- hit on recommendation --->
<!--- <cfif a_bol_is_recommendation>

	<div class="confirmation">
		<b>Like this recommendation?</b>
		<br />
		<a href="/rd/start/">Log in now</a> or <a href="/rd/signup/?source=recommendation">sign up for free</a> to listen to add this track to your playlists.
	</div>

</cfif> --->

<!--- <cfoutput>
<iframe border="0" style="border:0px;margin:8px" frameborder="0"  src="http://api.moosify.com/widgets/explorer/?partner=tunesbag&amp;artist=#UrlEncodedFormat( q_select_track.artist_name )#&amp;track=#urlEncodedFormat( q_select_track.track_name )#" width="720" height="90"></iframe>
</cfoutput> --->
				



<table>
<tr>
	<td>


<cfif IsStruct( stYTHits ) AND StructKeyExists( stYTHits, 'result' ) AND stYTHits.result>


	<!--- #application.udf.WriteSectionHeader( 'Hits on YouTube', '' )# --->
	<div class="ytvideo">
	<!--- only show one hit #ArrayLen( stYTHits.ahits )# --->
		<cfloop from="1" to="1" index="ii">
			
			<cfset sContent = stYTHits.aHits[ ii ].description />
			
			<cfset sContent = ReplaceNoCase( sContent, 'src="http://i.ytimg.com/vi/', ' style="width:280px;margin:8px" src="http://i.ytimg.com/vi/', 'ALL' ) />
			<cfset sContent = ReplaceNoCase( sContent, '<a ', '<a target="_blank" ', 'ALL' ) />
			
			<cfoutput>#sContent#</cfoutput>
			
			<cfif ii IS 1>
			
				<!--- ad --->
				<div class="ad">
					
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
			
			</cfif>
			
		</cfloop>
	</div>
	
</cfif>

<cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( q_select_track.artist_name , q_select_track.artist_id  )#' />
			
			<!--- #application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'cm_wd_comments' ), '' )#
		
			<div id="fb-root"></div>
			<script src="http://connect.facebook.net/en_US/all.js##xfbml=1"></script>
			<fb:comments href="#htmleditformat( sURL )#" num_posts="2" width="600"></fb:comments> --->

<!--- <cfif a_search_yt.result>
<cfset q_select_yt = a_search_yt.q_select_items />


		
		<div class="div_container lightbg bb" style="text-align:center">
			
			<div>
				<embed
				src="http://deliver.tunesbagcdn.com/flash/mediaplayer.swf"
				width="400"
				height="300"
				allowscriptaccess="always"
				allowfullscreen="true"
				flashvars="height=300&width=400&file=#UrlEncodedFormat( q_select_yt.pagelink )#&autostart=#a_bol_autostart#"
				/>			
			</div>
			
			
			<div class="clear"></div>
		</div>
		
</cfif> --->

<!--- 
<cfif IsQuery( q_select_playlists ) AND q_select_playlists.recordcount GT 0>
	#application.udf.WriteSectionHeader( application.udf.GetLangValSec( 'lib_pg_action_list_plist_with_track' ), '' )#
			
	<div class="div_container">
	
		<table class="table_overview">
			<cfloop query="q_select_playlists">
				<tr>
					<td>
						
						#application.udf.writeDefaultImageContainer( application.udf.getPlistImageLink( q_select_playlists.entrykey, 48 ),
									application.udf.CheckZeroString( q_select_playlists.name ),
									generateURLToPlist( q_select_playlists.entrykey, q_select_playlists.name, false ),
									38,
									false,
									true )#
						
						<!--- <a style="font-weight:bold" href="#generateURLToPlist( q_select_playlists.entrykey, q_select_playlists.name, false )#">#application.udf.si_img( 'page_white_cd' )# #htmleditformat( q_select_playlists.name )#</a> --->
					</td>
					<td>
						<h4>#htmleditformat( q_select_playlists.name )#</h4>
						<br />
						#htmleditformat( q_select_playlists.description )#
						<cfloop list="#q_select_playlists.tags#" index="a_str_tag" delimiters=", ">
							<span class="tag_box">#htmleditformat( trim( a_str_tag ))#</span>
						</cfloop>
					</td>
					<td>
						#application.udf.WriteDefaultUserNameProfileLink( q_select_playlists.username )#
					</td>
				</tr>
			</cfloop>
		</table>
	
	</div>	
</cfif>	 --->


<h2>#application.udf.GetLangValSec( 'cm_wd_album' )# #q_select_track.album_name#<span class="muted"> with #(q_select_album_tracks.recordcount -1 )# more tracks</span></h2>

<cfif Len( q_select_track.TAGS_RELEASE ) GT 0 OR Len( q_select_track.TAGS_ARTIST ) GT 0>
	<div class="div_container">
		<cfset counter = 0 />
		<cfloop list="#q_select_track.TAGS_RELEASE#,#TAGS_ARTIST#" index="a_str_tag" delimiters=", ">
			
			<span class="tag_box">#trim( a_str_tag )#</span>
			
			<cfset counter = counter + 1 />
			<cfif counter GT 7>
				<cfbreak >
			</cfif>
		</cfloop>
	</div>
</cfif>

			<table class="table table-striped">
			<cfloop query="q_select_album_tracks">
				<tr <cfif q_select_album_tracks.currentrow MOD 2 NEQ 0>style="background-color:##EEEEEE"</cfif> >
					<td style="text-align:right">
						#Val( q_select_album_tracks.sequence )#
					</td>
					<td>
						<a title="#application.udf.GetLangValSec( 'cm_wd_track' )#" class="add_as_tab" href="#generateGenericURLToTrack( q_select_album_tracks.artist_name, q_select_album_tracks.track_name, q_select_album_tracks.track, '' )#">#htmleditformat( q_select_album_tracks.track_name )#</a>
						
						<cfif CompareNoCase( q_select_track.artist_name, q_select_album_tracks.artist_name ) NEQ 0>
							/
							<a href="#application.udf.generateArtistURL( q_select_album_tracks.artist_name, 0 )#">#htmleditformat( q_select_album_tracks.artist_name )#</a>
						</cfif>
					</td>
					<td>
						#application.udf.FormatSecToHMS( q_select_album_tracks.tracklen )#
					</td>
				</tr>
			</cfloop>
			</table>

<div class="ad">
<script type="text/javascript"><!--
google_ad_client = "ca-pub-5279195474591127";
/* banner footer */
google_ad_slot = "8431393531";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>

<h2>More albums <span class="muted">by #htmleditformat( q_select_track.artist_album )#</span></h2>

<!--- <cfdump var="#q_select_other_alben#"> --->
<div class="div_container">
<cfloop query="q_select_other_alben">
	
	#application.udf.writeDefaultImageContainer( 'http://cdn.tunesbag.com/images/unknown_album_120x120.png',
								q_select_other_alben.name,
								generateAlbumURL( q_select_other_alben.artist_name, q_select_other_alben.name, q_select_other_alben.id ),
								100,
								true,
								true )#
		
</cfloop>
</div>

</cfoutput>



<br />
<div class="ad">
<script type="text/javascript"><!--
google_ad_client = "ca-pub-5279195474591127";
/* banner footer */
google_ad_slot = "8431393531";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
<br /><br />

<h2>About</h2>
<cfoutput>
Try direct <a target="_blank" rel="nofollow" title="Buy track" href="/rd/aff/buy/?app=&amp;artist=#urlEncodedFormat(  q_select_track.artist_name )#&amp;title=#UrlEncodedFormat( q_select_track.track_name  )#&amp;provider=itunes">mp3 download</a> instead of bittorrent, torrent or mega.
</cfoutput>



<br /><br />
		Content provided by 

		<a href="http://www.musicbrainz.org/">musicbrainz</a>,

		<a href="http://www.youtube.com/">YouTube</a>,
		
		<a href="http://www.spotify.com/">Spotify</a>,
		
		<a href="http://www.deezer.com/">Deezer</a>,		
		
		<a href="http://www.amazon.com">amazon</a> and <a href="http://www.songkick.com">SongKick</a>.
		
		<br /><br />
		<span class="addinfotext">
		The search/indexing interface contains content from public sources and links to other websites.
		tunesBag neither controls nor endorses these web sites, nor reviews or approves any content appearing on them.
		tunesBag does not assume any responsibility or liability for any materials available,
		or for the completeness, availability, accuracy, legality or decency.
		</span>
		<br /><br />

</td>
</tr>
</table>


</cfsavecontent>

<cfset event.setArg( 'PageTitle', q_select_track.artist_name &  ' - ' & q_select_track.track_name ) />

<cfsavecontent variable="a_str_meta">
<cfoutput>
Listen to #q_select_track.track_name# by #q_select_track.artist_name# now. Appears on the album #q_select_track.album_name#.
<cfif q_select_playlists.recordcount GT 0>
We've #q_select_playlists.recordcount# Playlists with this track, including <cfloop query="q_select_playlists" endrow="5">#q_select_playlists.name#, </cfloop>...
</cfif>
</cfoutput>
</cfsavecontent>

<cfset a_str_meta = ReplaceNoCase( a_str_meta, chr(10), ' ', 'ALL' ) />
<cfset a_str_meta = ReplaceNoCase( a_str_meta, '  ', ' ', 'ALL') />
<cfset a_str_meta = Trim( a_str_meta ) />

<cfset event.setArg( 'PageDescription',a_str_meta) />