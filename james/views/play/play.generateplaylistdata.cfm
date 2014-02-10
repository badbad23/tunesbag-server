<!--- //

	Module:		
	Action:		Generate .XML of playlist items
	
// --->

<cfset q_select_items = event.getArg('q_select_items') />
<!--- format --->
<cfset a_str_format = event.getArg( 'format', 'xml' ) />

<!--- which columns? ... only important for XML --->
<cfset a_str_data = event.getArg( 'data' , '') />

<cfif NOT IsQuery(q_select_items)>
	<cfset request.content.final = '' />
	<cfexit method="exittemplate">
</cfif>

<cfif a_str_format IS 'XML'>
	<cfset event.setArg( 'contentType', 'text/xml; charset=UTF-8') />
</cfif>

<cfsavecontent variable="request.content.final">

<cfswitch expression="#a_str_format#">
	<cfcase value="text">

		<!--- text only ... --->
		<cfoutput query="q_select_items">#q_select_items.entrykey#,</cfoutput>
		<!--- <cfoutput>#ValueList( q_select_items.entrykey )#</cfoutput> --->

	</cfcase>
	<cfcase value="xml">
	
		<!--- http://www.jeroenwijering.com/extras/readme.html#customization --->
			
		<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
			<channel>
				<title>Playlist</title>
				<link>http://www.tunesbag.com/</link>
				<description>Playlist</description>
				
				<cfoutput query="q_select_items">
		
				<cfset a_str_file = '/james/index.cfm?event=play.deliverfile&entrykey=' & urlencodedformat(q_select_items.entrykey) />
		
				<item>
					<title>#XMLFormat( q_select_items.name )#<cfif Len( q_select_items.album ) GT 0> (#XMLFormat( q_select_items.album )#)</cfif></title>
					<guid>#XMLFormat( q_select_items.entrykey )#</guid>
					<author>#XMLFormat( q_select_items.artist )#</author>
					<enclosure url="#a_str_file#" type="audio/mpeg" />
					<!--- <link>http://www.jeroenwijering.com/?item=Aggressive_Wallpaper</link> --->
				</item>
				</cfoutput>
		
			</channel>
		</rss>
		</cfcase>
</cfswitch>

</cfsavecontent>