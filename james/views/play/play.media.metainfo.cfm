<!--- 

	display media meta information

 --->

<cfinclude template="/common/scripts.cfm">

<!--- rotate artist bg? --->
<cfset iEnableArtistBGRotation = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).GetPreference( userkey = application.udf.GetCurrentSecurityContext().entrykey, name = 'ui.artistbgrot', defaultvalue = 1 ) />

<!--- basic item --->
<cfset a_struct_item = event.getarg('a_struct_item') />

<cfset q_select_access = event.getArg( 'q_select_access' ) />

<!--- comments --->
<cfset q_select_comments = event.getArg( 'q_select_comments', QueryNew('dummy') ) />


<!--- recommendations --->
<!--- <cfset a_struct_get_recommendations = event.getArg( 'a_struct_get_recommendations' ) /> --->
<cfset a_struct_get_recommendations = 0 />

<cfset a_struct_artist_information = event.getArg( 'a_struct_artist_information') />

<cfif StructKeyExists( a_struct_artist_information, 'q_select_fans_of_artist')>
	<cfset q_select_fans_of_artist = a_struct_artist_information.q_select_fans_of_artist />
<cfelse>
	<cfset q_select_fans_of_artist = 0 />
</cfif>

<cfif StructKeyExists( a_struct_artist_information, 'IMAGE_STRIPS' )>
	<cfset qImageStrips = a_struct_artist_information.IMAGE_STRIPS />
<cfelse>
	<cfset qImageStrips = 0 />
</cfif>

<!--- <cfsavecontent variable="request.content.final">
<cfdump var="#a_struct_item#" expand="false">
</cfsavecontent>
<cfexit method="exittemplate"> --->

<!--- social infos --->
<cfset a_struct_social_infos = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getSocialInformationOfTrack( artist = a_struct_item.getArtist(),
									name = a_struct_item.getName(),
									securitycontext = application.udf.GetCurrentSecurityContext() ) />

<cfset q_select_plists_with_this_track = a_struct_social_infos.q_select_plists_with_this_track />
<cfset q_select_avg_rating = a_struct_social_infos.q_select_avg_rating />

<cfset bImageStripAvailable = (iEnableArtistBGRotation AND isQuery( qImageStrips ) AND qImageStrips.recordcount IS 1) />

<cfsavecontent variable="request.content.final">

<script type="text/javascript">
	<cfif bImageStripAvailable>
		<cfoutput>
		setArtistStripImage( true, '#JsStringFormat( application.udf.getArtistStripImg( qImageStrips.mbid, 2, qImageStrips.imgwidth, qImageStrips.imgheight, qImageStrips.img_revision) )#', '#jsStringFormat( qImageStrips.copyrighthints )#' );
		</cfoutput>
	<cfelse>
		setArtistStripImage( false );
	</cfif>
</script>
	
<cfoutput>
	
<!--- <cfset sURL = 'http://www.tunesbag.com#application.udf.generateArtistURL( a_struct_item.getartist() , a_struct_item.getmb_artistid()  )#' /> --->

<cfset sURL = 'http://www.tunesBag.com' />

<!--- facebook like --->
<div class="playerContentBox">
<cfoutput>
<iframe id="facebooklikeartist" src="http://www.facebook.com/plugins/like.php?href=#UrlEncodedFormat( sURL )#&amp;layout=standard&amp;show_faces=true&amp;width=240px&amp;action=like&amp;colorscheme=evil;height: 62px !important" scrolling="no" frameborder="0" allowTransparency="true" style="border:none; overflow:hidden; width:240px;height: 62px !important"></iframe>
</cfoutput>


<!--- track click on facebook like button --->
<script type="text/javascript">
	var isOverFacebook = false;
	
	$( "iframe[ id *= facebook ]" ).mouseover(
		function(){
			isOverFacebook = true;		
		}
		).mouseout(
		function(){
			isOverFacebook = false;		
		}
		)
		;

// become a fan on tunesBag as well
$( window ).blur( function(){
	if (isOverFacebook) {
		$('##id_fan_btn_track').click();
		}
	} ).focus();

</script>
</div>

<!--- events --->
	<cfif StructKeyExists( a_struct_artist_information, 'stLoadEvents' )>
		<cfset stEvents = a_struct_artist_information.stLoadEvents />
		
		<!--- everything ok? --->
		<cfif stEvents.result AND stEvents.qEvents.recordcount GT 0>
			
			<div class="playerContentBox">
			<cfoutput>#application.beanFactory.getBean( 'Songkick' ).formatEventData( stEvents.qEvents )#</cfoutput>
			</div>
			
		<cfelse>
			
			<!--- load from server ... --->
			<cfif stEvents.error IS 201>
				<!--- we should perform an ajax request --->
				
				<cfoutput>
				<script type="text/javascript">
				loadArtistConcertEvents( '#a_struct_item.getmb_artistid()#', 'concertsOutput' );
				</script>
				</cfoutput>
				
				<div class="playerContentBox" id="concertsOutput">
					<div class="div_container" style="text-align:center">
					<img src="http://deliver.tunesbagcdn.com/images/ajax-loader.gif" alt="" />
					</div>
				</div>
				
			</cfif>
			
		</cfif>
	</cfif>


<div class="playerContentBox">
	<p class="header">#application.udf.GetLangValSec( 'cm_wd_comments' )#</p>
	
	<div id="id_artist_tweets">

		<!--- comments --->
		<cfif q_select_comments.recordcount GT 0>
			<cfloop query="q_select_comments">
			
			<div class="tweet">
				<a href="/user/#q_select_comments.createdbyusername#" title="#htmleditformat( q_select_comments.createdbyusername )#" class="add_as_tab">
				<img src="#application.udf.getUserImageLink(q_select_comments.createdbyusername, 48 )#" class="userimg" alt="User" />
				</a>
				
				<span class="body">#htmleditformat( q_select_comments.comment )#</span>
				<br />
				<span class="addinfotext">#application.udf.GetLangValSec( 'cm_wd_by' )# <a href="/user/#q_select_comments.createdbyusername#" title="#htmleditformat( q_select_comments.createdbyusername )#" class="add_as_tab">#q_select_comments.createdbyusername#</a></span>
				<!--- <br />
				<span class="addinfotext">#LSDateFormat( q_select_comments.dt_created, 'mm/dd/yy')#</span> --->
			</div>
			</cfloop>
			
		</cfif>
		
		<!--- tweets --->
		<cfif StructKeyExists(a_struct_artist_information, 'q_select_tweets') AND a_struct_artist_information.q_select_tweets.recordcount GT 0>
			
			<cfset q_select_tweets = a_struct_artist_information.q_select_tweets />
			
			
				<cfloop query="q_select_tweets" endrow="10">
				<div class="tweet">
					
					<a href="http://twitter.com/#q_select_tweets.from_user#" target="_blank">
						<img class="userimg" src="#q_select_tweets.PROFILE_IMAGE_URL#" alt="#htmleditformat( q_select_tweets.from_user )#" />
					</a> 
					
					<a class="body" href="http://twitter.com/#htmleditformat( q_select_tweets.from_user )#/status/#q_select_tweets.twitterid#" target="_blank">#trim( q_select_tweets.body )#</a>
					
					<br />
					<span class="addinfotext">#application.udf.GetLangValSec( 'cm_wd_by' )# #htmleditformat( q_select_tweets.from_user )# <a href="http://twitter.com/#q_select_tweets.from_user#" target="_blank"><img src="http://cdn.tunesBag.com/images/partner/twitter-icon.png" class="si_img" style="border:0px" alt="twitter"></a></span>
					<!--- <br />
					<span class="addinfotext">#LSDateFormat( q_select_tweets.dt_created, 'mm/dd/yy')#</span> --->
				</div>
				</cfloop>
				
					
			
		</cfif>
		<!--- tweets end --->
		
		<div class="clear"></div>	
		
		<!--- image strip licence info --->	
		<cfif bImageStripAvailable>
			<a href="##" onclick="$('##idFlickrCopyrightHints').fadeIn();return false"><img src="http://cdn.tunesBag.com/images/cc/120-88x31.png" width="88" height="31" alt="CC licence info" style="padding-right:4px;border:0px;vertical-align:middle" /> Image Copyright hints</a>
			
			<cfset aLicence = DeSerializeJSON( qImageStrips.copyrighthints ) />
			
			<div id="idFlickrCopyrightHints" class="hidden">
			<cfloop from="1" to="#ArrayLen( aLicence )#" index="ii">
				<a href="#htmleditformat( aLicence[ ii ].LINK )#" target="_blank">#htmleditformat( aLicence[ ii ].USERNAME )#</a>,&nbsp;
			</cfloop>
			</div>
			
		</cfif>
	
	</div>
	
	<!--- TODO: re-enable in v1.1 --->
	<p style="display:none">
		<input type="text"class="b_all addinfotext" style="padding:2px" onclick="checkInactiveInput(this)" value="<cfoutput>#application.udf.GetLangValSec( 'lib_ph_add_comment_long' )#</cfoutput>" />
	</p>
	
	<!--- rating --->
	<!--- <cfif Val( q_select_avg_rating.avg_rating ) GT 0>
	<p class="header" style="margin-top:8px">
		#application.udf.GetLangValSec( 'cm_ph_avg_rating' )# #WriteRatingBar(0, 'a', q_select_avg_rating.avg_rating, false)#		
	</p>	
	</cfif> --->
</div>

<!--- are recommendations available? --->
<cfif (IsStruct( a_struct_get_recommendations ) AND StructKeyExists( a_struct_get_recommendations, 'q_select_recommendations' ) AND a_struct_get_recommendations.result AND a_struct_get_recommendations.q_select_recommendations.recordcount GT 0) OR q_select_plists_with_this_track.recordcount GT 0>
	
	<cfset a_str_display_rec = 'display:none' />
	
	<div class="playerContentBox">
		<!--- <p class="header">#application.udf.GetLangValSec( 'cm_wd_recommendations' )#</p> --->
				
		<!--- <cfset q_select_recommendations = a_struct_get_recommendations.q_select_recommendations />

		<div class="curitem_recommendations">
			<cfloop query="q_select_recommendations">
				<div class="rec_#q_select_recommendations.unique_hash# <cfif q_select_recommendations.currentrow GT 1> hidden</cfif>">
					
					<table>
						<tr>
							<td valign="middle">
								<img src="#getArtistImageLink( q_select_recommendations.artist, true )#" width="30" height="36" style="padding:4px" alt="#htmleditformat( q_select_recommendations.artist )#" />
							</td>
							<td valign="middle">
								<a href="##" onclick="_handleRecommendationClick( this, '#jsstringformat( q_select_recommendations.entrykey )#', '#JsStringFormat( q_select_recommendations.unique_hash )#', '#JsStringFormat( q_select_recommendations.recommendation_request_id )#');return false">#htmleditformat( q_select_recommendations.name )#</a>
								<br />
								#application.udf.GetLangValSec( 'cm_wd_by' )# #htmleditformat( q_select_recommendations.artist )#
							</td>
						</tr>
					</table>
					
					
				</div>				
			</cfloop>
			
		
		<cfif q_select_recommendations.recordcount GT 1>
			<p style="text-align:right">
				<a href="##" onclick="$('.curitem_recommendations .hidden').fadeIn('slow');return false" class="importantlink" title="#application.udf.GetLangValSec( 'cm_ph_show_more' )#">#application.udf.GetLangValSec( 'cm_wd_more_link_to' )#</a>
			</p>
		</cfif>
		</div> --->
		
		<cfif q_select_plists_with_this_track.recordcount GT 0>
			<p class="header" style="margin-top:10px">#application.udf.GetLangValSec( 'lib_pg_action_list_plist_with_track' )#</p>
			
			<ul class="ul_nopoints" id="idPlaylistRecommendations">
			<cfloop query="q_select_plists_with_this_track">
				<li <cfif q_select_plists_with_this_track.currentrow GT 2>class="hidden"</cfif>>
					<a href="#generateURLToPlist( q_select_plists_with_this_track.entrykey, q_select_plists_with_this_track.name, false )#" title="#application.udf.GetLangValSec( 'cm_wd_playlist' )#" class="add_as_tab">#htmleditformat( q_select_plists_with_this_track.name )#
						<cfif Len( q_select_plists_with_this_track.description ) GT 0>
						(#htmleditformat( q_select_plists_with_this_track.description )#)
						</cfif>
					</a>
					
					#application.udf.GetLangValSec( 'cm_wd_by' )# #application.udf.WriteDefaultUserNameProfileLink( q_select_plists_with_this_track.username )#
					<div class="clear"></div>
				</li>
			</cfloop>
			</ul>
			
			<cfif q_select_plists_with_this_track.recordcount GT 2>
				<p style="text-align:right">
					<img src="http://cdn.tunesBag.com/images/space1x1.png" class="si_img" />
					<a href="##" onclick="$('##idPlaylistRecommendations .hidden').fadeIn('slow');$(this).hide();return false" class="importantlink" title="#application.udf.GetLangValSec( 'cm_ph_show_more' )#">#application.udf.GetLangValSec( 'cm_wd_more_link_to' )#</a>
				</p>
			</cfif>
		
			<div class="clear"></div>
		
		</cfif>
	</div>
</cfif>



	
</cfoutput>
<!--- show comments / tweets --->
<script type="text/javascript">			
	ShowNextTweet(0);			
</script>	
</cfsavecontent>


	
	<!--- upselling --->
	<!--- <cfif a_struct_item.getuserkey() NEQ application.udf.GetCurrentSecurityContext().entrykey>
		<p>
			<a target="_blank"  style="font-weight:bold" title="Buy MP3" href="/rd/aff/buy/?userkey=#UrlEncodedFormat( application.udf.GetCurrentSecurityContext().entrykey )#&app=&title=#urlEncodedFormat( a_struct_item.getName() )#&artist=#urlEncodedFormat( a_struct_item.getArtist() )#&album=#UrlEncodedFormat( a_struct_item.getAlbum() )#">#application.udf.si_img( 'basket' )# Buy this track</a>
		</p>
		<!--- other user --->
		<p>
			<cfset a_str_provided_by_username = getProperty( 'beanFactory' ).getBean( 'UserComponent' ).getUsernameByEntrykey( a_struct_item.getuserkey() ) />		
			<cfset a_added_info = [ LSDateFormat( a_struct_item.getdt_created(), 'mmm yy'), a_str_provided_by_username ] />
			<a href="/user/#a_str_provided_by_username#" title="#htmleditformat( a_str_provided_by_username )#" class="add_as_tab">#application.udf.GetLangValSec( 'cm_ph_added_date_user',  a_added_info )#</a>
		</p>
	</cfif> --->

	
	<!--- <cfif IsQuery( q_select_fans_of_artist ) AND q_select_fans_of_artist.recordcount GT 0>
			
				<cfquery name="q_user_is_fan" dbtype="query">
				SELECT
					*
				FROM
					q_select_fans_of_artist
				WHERE
					username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.udf.GetCurrentSecurityContext().username#">
				;
				</cfquery>
				
				<cfset a_bol_is_fan = (q_user_is_fan.recordcount IS 1 ) />
			
			<cfelse>
			
				<cfset a_bol_is_fan = false />
				
			</cfif>
			
			<cfif NOT a_bol_is_fan>
				<p>
				<a href="##" onclick="SimpleBGOperation( 'item.rate', 'mbid=#JsStringFormat( a_struct_item.getmb_artistid() )#&rating=100&itemtype=2');$(this).parent().append('<img src=\'http://cdn.tunesbag.com/images/si/accept.png\' class=\'si_img\' ></a>');$(this).hide();return false;"  title="#application.udf.GetLangValSec( 'lib_ph_become_fan_of_artist' )#">#application.udf.si_img( 'heart' )# #application.udf.GetLangValSec( 'lib_ph_become_fan_of_artist' )#</a>
				</p>
			</cfif>
		
		
		
		<!--- fans? --->
	<cfif isQuery( q_select_fans_of_artist ) AND q_select_fans_of_artist.recordcount GT 0>
	
	<br />
	<a href="#application.udf.generateArtistURL( a_struct_item.getArtist(), a_struct_item.getmb_artistid() )#" title="#htmleditformat( a_struct_item.getArtist() )#" class="add_as_tab">#application.udf.GetLangValSec( 'lib_ph_status_artist_has_fans', q_select_fans_of_artist.recordcount )#</a>
	
	
</cfif> --->
