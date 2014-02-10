<cfset a_struct_filter.entrykeys = event.getArg( 'setkey' ) />

<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
			filter = a_struct_filter,
			librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
			type = 'playlists') />
							
<cfset StructClear(a_struct_filter) />
<cfset a_struct_filter.ids = a_struct_get_data.q_select_items.items />
<cfset a_struct_filter.info_playlistkey = event.getArg( 'setkey' ) />

<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData( securitycontext = a_struct_securitycontext,
		librarykeys = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetAllPossibleLibrarykeysForLibraryAccess( a_struct_securitycontext ),
		type = 'mediaitems',
		filter = a_struct_filter) />

<cfsavecontent variable="request.rss.final">
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/"  xmlns:boxee="http://boxee.tv">
<channel>
<title>Song Site</title>
<link>http://www.tunesBag.com</link>
<boxee:expiry>0</boxee:expiry>
<description>123</description>

<cfoutput query="a_struct_get_data.q_select_items">
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
</channel>
</rss>
</cfsavecontent>