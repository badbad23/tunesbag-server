<!--- 

	show all artists with a given start char

 --->
<cfset sFirstChar = event.getArg( 'firstchar' ) />

<cfquery name="qArtists" datasource="mytunesbutleruserdata">
SELECT
	COUNT( items.id ) AS count_artist,
	artist.name AS artist,
	artist.id AS mb_artistid
FROM
	mediaitems AS items
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = items.mb_artistid)
WHERE
	items.userid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_struct_securitycontext.userid#" />
	AND
	LEFT( artist.name, 1 ) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sFirstChar#" />
GROUP BY
	items.mb_artistid
ORDER BY
	artist.name
;
</cfquery>

<cfsavecontent variable="request.content.final">
<cfoutput>
<opml version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<head>
		<title>#xmlformat( a_struct_securitycontext.username )# @ tunesBag</title>
		
		<dateCreated>#application.udf.getHTTPDate( Now() )#</dateCreated>
		<dateModified>#application.udf.getHTTPDate( Now() )#</dateModified>
		
		<ownerName>tunesBag.com Limited</ownerName>
		<ownerEmail>office@tunesBag.com</ownerEmail>

		</head>
	<body>
		
		<cfloop query="qArtists">
		
		<!--- filter for certain mb artist ids --->			
		<cfset sCriteria = 'MBARTISTIDS' & '?VALUE=' & trim( qArtists.mb_artistid ) />
			
		<outline text="#xmlformat( qArtists.artist )# (#qArtists.count_artist#)" type="playlist"
				URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;type=custom&amp;criteria=#UrlEncodedFormat( sCriteria )#">			
		</outline>
		</cfloop>
		
</body>
</opml>
</cfoutput>
</cfsavecontent>