<!---

	welcome page

--->

<cfset aImages = [ 'tunesbag-playlist-woman-earjackets.jpg', 'tunesbag-playlist-woman-laptop.jpg' ] />
<cfset event.setArg( 'PageTitle', 'tunesBag music directory') />

<cfsavecontent variable="request.content.final">

      <div class="jumbotron" style="">
		<div style="background-image:URL('http://deliver.tunesbagcdn.com/images/content/landingpage/<cfoutput>#aImages[ RandRange( 1, ArrayLen( aImages ))]#</cfoutput>');height:280px"></div>
        <h1>Millions of tracks ready for you.</h1>
        <p class="lead">tunesBag is your free music directory with direct links to Youtube, Spotify &amp; Deezer.</p>
        <a class="btn btn-large btn-success" href="/playlist-U2-a197">Artist of the day: U2</a>
      </div>

      <hr />

      <div class="row-fluid marketing">
	
		<cfset qSelectPopuplar = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getPopularArtists( sOptions = 'ignorefreemusic,ignorevariousartists').qSelectPopularArtists />
		
        <div class="span6">
			
			<cfoutput query="qSelectPopuplar">
	          <h4><a href="#application.udf.generateArtistURL( qSelectPopuplar.artist_name, qSelectPopuplar.artist_id )#">#htmleditformat( qSelectPopuplar.artist_name )#</a></h4>
    	      <p>#RandRange(20,90)# tracks found</p>
			</cfoutput>
		
        </div>
		
        <!--- <div class="span6">
          <h4>Subheading</h4>
          <p>Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum.</p>

          <h4>Subheading</h4>
          <p>Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Cras mattis consectetur purus sit amet fermentum.</p>

          <h4>Subheading</h4>
          <p>Maecenas sed diam eget risus varius blandit sit amet non magna.</p>
        </div> --->
      </div>

    
<!--- 








<table style="width:894px;height:291px;position:relative;z-index:1;background-repeat:no-repeat;background-image:URL('http://deliver.tunesbagcdn.com/images/content/landingpage/<cfoutput>#aImages[ RandRange( 1, ArrayLen( aImages ))]#</cfoutput>')">
	<tr>
		<td style="width:644px">

		</td>
		<!--- background-image:URL(http://deliver.tunesbagcdn.com/images/skins/default/bgTopSmallHeader.png); --->
		<td style="width:250px;padding:12px;vertical-align:middle">
			
			<cftry>
			<cfset qSelectPopuplar = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getPopularArtists( sOptions = 'ignorefreemusic,ignorevariousartists').qSelectPopularArtists />
			
					<b>Listen to popular music on tunesBag</b>
					<p class="div_container">
					<cfoutput query="qSelectPopuplar">
						<a href="#application.udf.generateArtistURL( qSelectPopuplar.artist_name, qSelectPopuplar.artist_id )#">#htmleditformat( qSelectPopuplar.artist_name )#</a>
						<br />
					</cfoutput>
					</p>

			
			<cfcatch type="any">
			<cfdump var="#cfcatch#">
			</cfcatch>
			</cftry>
			
		</td>
	</tr>
</table>


 --->

</cfsavecontent>