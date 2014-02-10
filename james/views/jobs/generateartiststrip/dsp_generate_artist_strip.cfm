<!--- 

	check artists and generate the strip!

 --->
<!--- 
<cfsetting requesttimeout="75" />

<cfset qSelectPopularArtists = getProperty( 'beanFactory' ).getBean( 'ContentComponent' ).getPopularArtists( sOptions = 'ignorefreemusic,ignorevariousartists', imaxrows = 1, bJoinArtistImageStrips = true ).qSelectPopularArtists />


<cfloop query="qSelectPopularArtists">
	<cfoutput>
	#qSelectPopularArtists.mb_artistid#
	</cfoutput>
	<br />
	<cfflush >
	<cfset stImage = application.beanFactory.getBean( 'ContentComponent' ).updateArtistImageStrip( iMBArtist_ID = qSelectPopularArtists.mb_artistid, sArtistName = qSelectPopularArtists.artist_name, iImgType = 0 ) />
	
	<cfdump var="#stImage#">
</cfloop> --->