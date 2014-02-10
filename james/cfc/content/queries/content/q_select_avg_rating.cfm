<cfquery name="q_select_avg_rating" datasource="mytunesbutleruserdata">
SELECT
	AVG( rating ) AS avg_rating
FROM
	ratings
WHERE
	hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getHashValueArtistTrack( arguments.artist, arguments.name )#">
;
</cfquery>