<!--- ignore caching? --->
<cfif arguments.bJoinArtistImageStrips>
	<cfset local.iCacheMin = 0 />
<cfelse>
	<cfset local.iCacheMin = 60 />
</cfif>

<!--- the new way to select the item --->
<cfquery name="qSelectPopularArtists" datasource="mytunesbutlerlogging" cachedwithin="#CreateTimeSpan(0, 0, local.iCacheMin, 0)#">
SELECT t.*,
	artist.name AS artist_name,
	t.mb_artistid AS artist_id
FROM (
SELECT
	/* weighten the numbers
		
		fans = * 7
		play = * 5		
		added = * 3
		rated = * 1.5
		infoassethits = 1
		
	
	 */
	SUM( 
		
		CASE 
		WHEN (indicator = '#application.const.S_REPORTING_INDICATOR_PLAYED#') THEN (artistpopularityreporting.val * 5)
		WHEN (indicator = '#application.const.S_REPORTING_INDICATOR_FANS#') THEN (artistpopularityreporting.val * 4)
		WHEN (indicator = '#application.const.S_REPORTING_INDICATOR_ADDED#') THEN (artistpopularityreporting.val * 3)
		WHEN (indicator = '#application.const.S_REPORTING_INDICATOR_RATINGS#') THEN (artistpopularityreporting.val * 2)
		ELSE (1)
		
		END
		
		<!--- (IF( indicator = 'played', (val * 2), val)) --->
		
		
		) AS hitcount,
	artistpopularityreporting.mb_artistid
	
	<cfif arguments.bJoinArtistImageStrips>
	,strips.id AS strip_id
	</cfif>
FROM
	artistpopularityreporting
	
	<cfif arguments.bJoinArtistImageStrips>
	LEFT JOIN
		<!--- 
			
			join using the artist id and the types 0 (= default) and invalid (-1)
			
		 --->
		mytunesbutlercontent.image_strips AS strips ON (strips.mbid = artistpopularityreporting.mb_artistid AND strips.mbtype = 2 AND strips.img_type IN (0,-1))
	</cfif>
	
WHERE
	/* ignore the total combined item */
	(artistpopularityreporting.mb_artistid > 0)
	AND
	(artistpopularityreporting.date_report >= Date_SUB(Now(), INTERVAL #arguments.iDaysBackStart# DAY))
	AND
	(artistpopularityreporting.date_report <= Date_SUB(Now(), INTERVAL #arguments.iDaysBackEnd# DAY))	
	
	<cfif FindNoCase( 'ignorevariousartists', arguments.sOptions )>
		AND NOT
		(artistpopularityreporting.mb_artistid IN (1,242879))
	</cfif>
	
	<!--- 
		only select non-existing strips!
		
		ignore strips with fewer than 3 images
	 --->
	<cfif arguments.bJoinArtistImageStrips>
		AND (strips.id IS NULL)
	</cfif>
	
GROUP BY
	artistpopularityreporting.mb_artistid
ORDER BY
	hitcount DESC
LIMIT
	#Val( arguments.iMaxRows )#
) AS t
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = t.mb_artistid)

</cfquery>