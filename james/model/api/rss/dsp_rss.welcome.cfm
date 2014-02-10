<!--- welcome request --->
<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
							librarykeys = '',
							calculateitems = false,
							filter = a_struct_filter,
							type = 'playlists' ) />

<cfsavecontent variable="request.rss.final">
	
<rss version="2.0" xmlns:boxee="http://boxee.tv/rss" xmlns:media="http://search.yahoo.com/mrss/">
<channel>
  <title><cfoutput>#xmlformat( a_struct_securitycontext.username )#</cfoutput> @ tunesBag.com</title>
  <link>rss://<cfoutput>#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/#cgi.PATH#</cfoutput>/</link>
  <description><cfoutput>#xmlformat( a_struct_securitycontext.username )#</cfoutput> @ tunesBag.com</description>
  <language>en</language>
  <!--- do not cache --->
  <boxee:expiry>0</boxee:expiry>
<boxee:display>
<boxee:view default="1">
<boxee:view-option id="1" view-type="line"/>
<boxee:view-option id="2" view-type="thumb"/>
<boxee:view-option id="3" view-type="thumb with preview"/>
<boxee:view-option id="4" view-type="detailed list"/>

</boxee:view>
<boxee:sort default="1" folder-position="start">
<boxee:sort-option id="1" sort-by="label" sort-order="ascending" sort-type-name="name"/>
</boxee:sort>
</boxee:display>
<!--- <item>
<title>Aeschbacher</title>
<description>Gepflegte Gespraechskultur ohne Schnickschnack</description>
<link>rss://feeds.sf.tv/podcast/aeschbacher</link>
<boxee:image>http://www.sf.tv/podcasts/data/aeschbacher_logo.jpg</boxee:image>
<media:category scheme="urn:boxee:title-type">tv</media:category>
<media:category scheme="urn:boxee:media-type">clip</media:category>

<media:category scheme="urn:boxee:source">TSR</media:category>
</item> --->


<cfoutput>
<item>
	<title>#application.udf.GetLangValSec( 'cm_wd_genres' )#</title>
	<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=genres</link>
	<description>Browse tunes by genres</description>
	<boxee:image>http://www.sf.tv/podcasts/data/club_logo.jpg</boxee:image>
	<media:category scheme="urn:boxee:title-type">tv</media:category>
	<media:category scheme="urn:boxee:media-type">clip</media:category>
	<media:category scheme="urn:boxee:source">TSR</media:category>
</item>
<item>
  <title>#application.udf.GetLangValSec( 'cm_wd_artists' )#</title>
  <link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=artists</link>
  <description>Browse tunes by artists</description>
  <boxee:image></boxee:image>
</item>
<item>
  <title>#application.udf.GetLangValSec( 'cm_wd_albums' )#</title>
  <link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=albums</link>
  <description>Browse tunes by albums</description>
  <boxee:image></boxee:image>
</item>
<!--- <item>
  <title>#application.udf.GetLangValSec( 'cm_wd_friends' )#</title>
  <link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/browse/?#getAPIUserRemotekeyPath(event)#?type=friends</link>
  <description>What your friends are listening to</description>
  <boxee:image></boxee:image>
</item> --->
</cfoutput>

<cfquery name="a_struct_get_data.q_select_items" dbtype="query">
SELECT
	*
FROM
	a_struct_get_data.q_select_items
WHERE
	itemcount > 0
	OR
	dynamic = 1
;
</cfquery>

	<cfoutput query="a_struct_get_data.q_select_items">
	<item>
		<title>#xmlformat( a_struct_get_data.q_select_items.name )#</title>
		<link>rss://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/rss/playlist/?#getAPIUserRemotekeyPath(event)#&amp;setkey=#xmlformat( a_struct_get_data.q_select_items.entrykey )#</link>
		<description>#xmlformat( a_struct_get_data.q_select_items.description )# #application.udf.GetLangValSec( 'cm_wd_by' )# #xmlformat( a_struct_get_data.q_select_items.username )#</description>
		<duration>#xmlformat( a_struct_get_data.q_select_items.totaltime )#</duration>
		<!--- <media:thumbnail>http://www.tunesbag.com/res/images/albums/Sirenia/Nine%20Destinies%20and%20a%20Downfall.jpg</media:thumbnail>
		<boxee:image>http://www.tunesbag.com/res/images/albums/Sirenia/Nine%20Destinies%20and%20a%20Downfall.jpg</boxee:image> --->
	</item>
	</cfoutput>
	
</channel>
</rss>

</cfsavecontent>