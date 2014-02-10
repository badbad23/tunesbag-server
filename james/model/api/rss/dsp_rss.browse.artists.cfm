
<cfset a_str_artist = event.getArg( 'artist' ) />
<cfset a_str_firstchar = event.getArg( 'firstchar' ) />

<cfsavecontent variable="request.rss.final">

<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/"  xmlns:boxee="http://boxee.tv">
<channel>
<title>tunesBag browse</title>
<link>http://www.tunesBag.com</link>
<boxee:expiry>0</boxee:expiry>
<description></description>

<cfif Len( a_Str_artist ) GT 0>

	<cfset a_str_criteria = 'ARTIST' & '?VALUE=' & trim( a_Str_artist ) />
	
	<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentDataMediaItems( securitycontext = a_struct_securitycontext,
										librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
										search_criteria = a_str_criteria ) />
	<cfset q_select_items = a_struct_get_data.q_select_items />


	<cfoutput query="q_select_items">
		<item>
			<title>#xmlformat( a_struct_get_data.q_select_items.name )# - #xmlformat( a_struct_get_data.q_select_items.artist )#</title>
			<link>http://www.tunesBag.com/</link>
			<boxee:image>http://www.tunesbag.com/#getAlbumArtworkLink( a_struct_get_data.q_select_items.mb_albumid, 120 )#</boxee:image>		
			<media:thumbnail>http://www.tunesbag.com/#getAlbumArtworkLink( a_struct_get_data.q_select_items.mb_albumid, 120 )#</media:thumbnail>		
			<media:content url="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/items/get/deliver/?#getAPIUserRemotekeyPath(event)#&amp;entrykey=#a_struct_get_data.q_select_items.entrykey#&amp;targetbitrate=128&amp;options=FORWARDTOPLAYURL&amp;autostart=True&amp;autoplay=1" 
				fileSize="#a_struct_get_data.q_select_items.size#" type="audio/mpeg" expression="full">
				</media:content>
				
			<!--- <media:category>music/band1/album/song</media:category> --->
			<media:rating>nonadult</media:rating>
			<media:title>#xmlformat( a_struct_get_data.q_select_items.name )# - #xmlformat( a_struct_get_data.q_select_items.artist )#</media:title>
			<media:text type="plain">
			</media:text>
			<description>#xmlformat( a_struct_get_data.q_select_items.genre )# / #xmlformat( a_struct_get_data.q_select_items.totaltime )# seconds</description>
		</item>		
	</cfoutput>
	
<cfelse>

	<cfif Len( a_str_firstchar ) IS 0>
		
		<cfquery name="q_select_distinct_firstchar" datasource="mytunesbutleruserdata">
		SELECT
			DISTINCT(UPPER( LEFT(artist, 1) ) ) AS first_char,
			COUNT(id) AS count_char,
			CONCAT(LEFT( GROUP_CONCAT( DISTINCT artist SEPARATOR ', ' ), 50), ' ...') AS artists
		FROM
			mediaitems
		WHERE
			userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.entrykey#">
		GROUP BY
			LEFT(artist, 1)
		ORDER BY
			UPPER(artist)
		;
		</cfquery>
		
		<cfoutput query="q_select_distinct_firstchar">
		<item>
				<title>#xmlformat( q_select_distinct_firstchar.first_char )# (#artists#)<!---  #xmlformat( application.udf.CheckZeroString(q_select_artists.artist) )# (#q_select_artists.count_artist#) ---></title>
				<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=artists&amp;firstchar=#urlencodedformat( q_select_distinct_firstchar.first_char )#</link>
				
			</item>	
		</cfoutput>
	
	<cfelse>
	
		<cfquery name="q_select_artists" datasource="mytunesbutleruserdata">
		SELECT
			DISTINCT(artist),
			COUNT(id) AS count_artist
		FROM
			mediaitems
		WHERE
			userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.entrykey#">
			AND
			LEFT(artist, 1) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_firstchar#">
		GROUP BY
			artist
		ORDER BY
			UPPER(artist)
		;
		</cfquery>
	
		<cfoutput query="q_select_artists">
			<item>
				<title>#xmlformat( application.udf.CheckZeroString(q_select_artists.artist) )# (#q_select_artists.count_artist#)</title>
				<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=artists&amp;artist=#urlencodedformat( q_select_artists.artist )#</link>
				<boxee:image>http://www.tunesbag.com/#getArtistImageLink( q_select_artists.artist, false )#</boxee:image>		
				<media:thumbnail>http://www.tunesbag.com/#getArtistImageLink( q_select_artists.artist, false )#</media:thumbnail>		
				
			</item>	
		</cfoutput>
	
	
	</cfif>

	

</cfif>
</channel>
</rss>

</cfsavecontent>