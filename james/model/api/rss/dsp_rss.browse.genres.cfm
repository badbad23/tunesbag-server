<cfset a_str_genre = event.getARg( 'genre' ) />

<cfquery name="q_select_genres" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT(genre),
	COUNT(id) AS count_items
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.entrykey#">
GROUP BY
	genre
ORDER BY
	UPPER(genre)
;
</cfquery>

<cfsavecontent variable="request.rss.final">

<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/"  xmlns:boxee="http://boxee.tv">
<channel>
<title>tunesBag browse</title>
<link>http://www.tunesBag.com</link>
<boxee:expiry>0</boxee:expiry>
<description></description>

<cfif Len( a_str_genre ) GT 0>

	<cfset a_str_criteria = 'GENRES' & '?VALUE=' & trim( a_str_genre ) />
	
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

	<cfoutput query="q_select_genres">
		<item>
			<title>#xmlformat( application.udf.CheckZeroString(q_select_genres.genre) )# (#q_select_genres.count_items#)</title>
			<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=genres&amp;genre=#xmlformat( q_select_genres.genre )#</link>
		</item>	
	</cfoutput>

</cfif>

</channel>
</rss>
</cfsavecontent>