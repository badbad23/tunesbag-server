<cfsavecontent variable="request.content.final">
	
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:creativeCommons="http://backend.userland.com/creativeCommonsRssModule" xmlns:media="http://search.yahoo.com/mrss/" xmlns:boxee="http://boxee.tv" version="2.0">
<channel>
  <title>BBC</title>
  <link>rss://rss.boxee.tv/bbc.xml/</link>
  <description>BBC Podcasts</description>
  <language>en</language>
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
 <item>

  <title>Setup Guide</title>
  <link>rss://localhost:8030/james/tests/boxee/play2.cfm?asdi</link>
  <description>Learn how to link tunesBag to boxee</description>
  <boxee:image></boxee:image>
 </item>
	
</channel>
</rss>

</cfsavecontent>