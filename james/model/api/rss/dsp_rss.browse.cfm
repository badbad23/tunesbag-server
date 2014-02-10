<cfset a_str_type = Event.getArg( 'type', 'genres' ) />

<cfset a_str_genre = event.getArg( 'genre', '' ) />

<cfswitch expression="#a_str_Type#">
	
	<cfcase value="artists">
		<cfinclude template="dsp_rss.browse.artists.cfm">
	</cfcase>
	<cfcase value="genres">
		<cfinclude template="dsp_rss.browse.genres.cfm">
	</cfcase>
	<cfcase value="albums">
		<cfinclude template="dsp_rss.browse.albums.cfm">
	</cfcase>

</cfswitch>

