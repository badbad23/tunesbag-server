
<cfset a_str_album = event.getArg( 'album' ) />

<cfquery name="q_select_alben" datasource="mytunesbutleruserdata">
SELECT
	DISTINCT(album),
	artist,
	mb_albumid,
	COUNT(id) AS count_album
FROM
	mediaitems
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.entrykey#">
GROUP BY
	album
ORDER BY
	UPPER(album)
;
</cfquery>

<cfsavecontent variable="request.rss.final">

<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/" xmlns:boxee="http://boxee.tv">
<channel>
<title>tunesBag browse</title>
<link>http://www.tunesBag.com</link>
<boxee:expiry>0</boxee:expiry>
<description></description>

<cfif Len( a_str_album ) GT 0>

	<cfset a_str_criteria = 'ALBUMS' & '?VALUE=' & trim( a_str_album ) />
	
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
				this is a text
			</media:text>
			<media:description>sample description</media:description>
			<description>#xmlformat( a_struct_get_data.q_select_items.genre )# / #xmlformat( a_struct_get_data.q_select_items.totaltime )# seconds</description>
		</item>		
	</cfoutput>
	
<cfelse>

	<cfoutput query="q_select_alben">
	<item>
			<title>#xmlformat( application.udf.CheckZeroString(q_select_alben.album) )# #application.udf.GetLangValSec( 'cm_wd_by' )# #xmlformat( application.udf.CheckZeroString(q_select_alben.artist) )# (#q_select_alben.count_album#)</title>
			<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=albums&amp;album=#urlencodedformat( q_select_alben.album )#</link>
			<boxee:image>http://www.tunesbag.com/#getAlbumArtworkLink( q_select_alben.mb_albumid, 120 )#</boxee:image>		
			<media:thumbnail>http://www.tunesbag.com/#getAlbumArtworkLink( q_select_alben.mb_albumid, 120 )#</media:thumbnail>		
		</item>	
	</cfoutput>

</cfif>
</channel>
</rss>

</cfsavecontent>