<!--- 

	first page of opml service

 --->

<cfinclude template="/common/scripts.cfm" />

<cfset a_struct_get_data = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).GetUserContentData(securitycontext = a_struct_securitycontext,
							librarykeys = '',
							calculateitems = false,
							filter = a_struct_filter,
							type = 'playlists' ) />
							
<cfquery name="qSelectPlists" dbtype="query">
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

<cfset qFirstCharsArtists = getProperty( 'beanFactory' ).getBean( 'MediaItemsComponent' ).getUniqueFirstCharsOfArtists( securitycontext = a_struct_securitycontext ) />

<!--- get recently played plists --->
<cfquery name="qSelectRecentPlists" dbtype="query" maxrows="10">
SELECT
	*
FROM
	qSelectPlists
WHERE NOT
	lasttime = ''
ORDER BY
	lasttime DESC
</cfquery>

			
<!--- <cfmail from="hansjoerg@tunesbag.com" to="hansjoerg@tunesbag.com" subject="stRecentPlist" type="html">
<cfdump var="#qSelectRecentPlists#"></cfmail> --->
<cfsavecontent variable="request.content.final">
<cfoutput>
<opml version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<head>
		<title>#xmlformat( a_struct_securitycontext.username )# @ tunesBag</title>
		
		<dateCreated>#application.udf.getHTTPDate( Now() )#</dateCreated>
		<dateModified>#application.udf.getHTTPDate( Now() )#</dateModified>
		
		<ownerName>tunesBag.com Limited</ownerName>
		<ownerEmail>office@tunesBag.com</ownerEmail>
		<!---<expansionState>1,3,17</expansionState>
		<vertScrollState>1</vertScrollState>
		<windowTop>164</windowTop>
		<windowLeft>50</windowLeft>
		<windowBottom>672</windowBottom>
		<windowRight>455</windowRight>--->
		</head>
	<body>
		
		<outline text="&amp;##x272A Zuletzt gespielt">
			<!--- list plists recently played --->
			<cfloop query="qSelectRecentPlists">
			<outline text="&amp;##9776; #xmlformat( qSelectRecentPlists.name )#<cfif Len( qSelectRecentPlists.description ) GT 0> - #xmlformat( qSelectRecentPlists.description )#</cfif>"
				type="playlist"
				imageHref="#xmlformat( application.udf.getPlistImageLink( qSelectRecentPlists.entrykey, '300') )#"
				URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;entrykey=#qSelectRecentPlists.entrykey#&amp;dummy=#CreateUUID()#.opml" />
			</cfloop>
			
		</outline>
		
		<outline text="&amp;##9776; <cfoutput>#application.udf.GetLangValSec( 'cm_wd_playlists' )#</cfoutput> (<cfoutput>#qSelectPlists.recordcount#</cfoutput>)">
			<cfloop query="qSelectPlists">
			<outline text="&amp;##9776; #xmlformat( qSelectPlists.name )#<cfif Len( qSelectPlists.description ) GT 0> - #xmlformat( qSelectPlists.description )#</cfif>"
				type="playlist"
				imageHref="#xmlformat( application.udf.getPlistImageLink( qSelectPlists.entrykey, '300') )#"
				URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;entrykey=#qSelectPlists.entrykey#&amp;dummy=#CreateUUID()#.opml" />
			</cfloop>
		</outline>
			
		<!--- artists --->
		<outline text="&amp;##9835; #XMLFormat( application.udf.GetLangValSec( 'cm_wd_artists' ))# (A-Z)">
		
			<cfloop query="qFirstCharsArtists">
				<outline text="#xmlformat( qFirstCharsArtists.first_char )# (#xmlformat( qFirstCharsArtists.artists )#)"
						type="url"
						URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=artists&amp;firstchar=#xmlformat( qFirstCharsArtists.first_char )#" />
			</cfloop>
		
		</outline>
		
		<cfquery name="qSelectAlbenFirstChar" datasource="mytunesbutleruserdata">
		SELECT
			LEFT( album.name, 1) AS first_char
		FROM
			mediaitems AS items
		LEFT JOIN
			mytunesbutler_mb.album AS album ON (album.id = items.mb_albumid)
		WHERE
			userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_securitycontext.userid#" />
			AND
			LENGTH( album.name ) > 0
		GROUP BY
			first_char
		;
		</cfquery>
			
		<!--- albums --->
		<outline text="&amp;##9744; #XMLFormat( application.udf.GetLangValSec( 'cm_wd_albums' ))# (A-Z)">
			<cfloop query="qSelectAlbenFirstChar">
				<outline text="#xmlformat( qSelectAlbenFirstChar.first_char )#"
						type="url"
						URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/browse/?#getAPIUserRemotekeyPath(event)#&amp;type=albums&amp;firstchar=#xmlformat( qSelectAlbenFirstChar.first_char )#" />
			</cfloop>
		</outline>

		<cfquery name="qSelectDistinctGenres" datasource="mytunesbutleruserdata">
		SELECT
			COUNT(id) AS count_genre,
			genre
		FROM
			mediaitems
		WHERE
			userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_securitycontext.userid#" />
			AND
			LENGTH( genre ) > 0
		GROUP BY genre
		ORDER BY
			count_genre DESC
		;
		</cfquery>
		
		<outline text="&amp;##9872; Genre Radios">
			<cfloop query="qSelectDistinctGenres" endrow="50">
				
			<!--- filter for certain mb artist ids --->			
			<cfset sCriteria = 'GENRES' & '?VALUE=' & trim( qSelectDistinctGenres.genre ) />
				
			<outline text="&amp;##9872; #xmlformat( qSelectDistinctGenres.genre )# (#count_genre.count_genre#)"
						type="playlist"
						URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;type=custom&amp;criteria=#UrlEncodedFormat( sCriteria )#&amp;order=RANDOMIZE" />
			</cfloop>
		</outline>
		
		<!--- <outline text="&amp;##9762; Surprise me!" description="Play totally randomized tracks from your library">
			<outline text="" />
		</outline> --->
		
		<!--- <outline text="Keyword Playlists">
			<outline text="&amp;##x2602 &amp;##x9774 #LSDateFormat( Now(), 'dddd')#"
						type="url"
						URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/browser/artists/?#getAPIUserRemotekeyPath(event)#&amp;firstchar=#xmlformat( qFirstCharsArtists.first_char )#" />
		</outline>
		
		<outline text="#application.udf.GetLangValSec( 'nav_about' )#">
			<outline text="" />
		</outline> --->
			
		</body>
	</opml>
</cfoutput>
</cfsavecontent>