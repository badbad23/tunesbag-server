<!--- get firstchar --->
<cfset sFirstChar = event.getArg( 'firstchar' ) />

<cfquery name="qSelectAlben" datasource="mytunesbutleruserdata">
SELECT
	LEFT( album.name, 1) AS firstchar,
	album.name,
	album.id AS mb_albumid,
	COUNT( items.id ) AS count_tracks,
	artist.name AS artist_name
FROM
	mediaitems AS items
LEFT JOIN
	mytunesbutler_mb.album AS album ON (album.id = items.mb_albumid)
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = album.artist)
WHERE
	userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#a_struct_securitycontext.userid#" />
	AND
	album.artist > 1
	AND
	LEFT( album.name, 1) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#sFirstChar#" />
GROUP BY
	album.id
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
		
		<cfloop query="qSelectAlben">
		
		<!--- filter for certain mb artist ids --->			
		<cfset sCriteria = 'MBALBUMIDS' & '?VALUE=' & trim( qSelectAlben.mb_albumid ) />
		
		<cfset sPlistname = qSelectAlben.name & ' - ' & qSelectAlben.artist_name />
			
		<outline text="#xmlformat( sPlistname )# (#qSelectAlben.count_tracks#)" type="playlist"
				URL="http://#cgi.SERVER_NAME#:#cgi.SERVER_PORT#/api/rest/opml/playlist/?#getAPIUserRemotekeyPath(event)#&amp;type=custom&amp;criteria=#UrlEncodedFormat( sCriteria )#&amp;plistname=#UrlEncodedFormat( sPlistname )#&amp;Order=TrackNumber">
		</outline>
		</cfloop>
		
</body>
</opml>
</cfoutput>
</cfsavecontent>