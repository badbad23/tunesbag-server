<cfquery name="q_select_artist_events" datasource="mytunesbutlercontent">
SELECT
	venue_name,
	artist,
	start,
	name,
	description,
	entrykey,
	source,
	address,
	city,
	country,
	url,
	zipcode,
	LONGITUDE,
	LATITUDE
FROM
	events
WHERE
	artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">

<cfif Len( arguments.countryisocodes ) GT 0>
	AND
	country IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.countryisocodes#" list="true">)
</cfif>
	
	AND
	start >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
	
ORDER BY
	start
;
</cfquery>