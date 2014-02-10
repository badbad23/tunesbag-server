<cfquery name="q_select_favourite_artists_of_user" datasource="mytunesbutleruserdata">
SELECT 
	mbid,
	dt_created,
	artist.name,
	RAND() AS randdata,
	explicit_fav

FROM
(
	(
		
		<cfloop from="1" to="#iFansListLen#" index="ii">
			(
			SELECT
				#Val( ListGetAt( sArtistFans, ii ))# AS mbid,
				CURRENT_TIMESTAMP AS dt_created,
				1 AS explicit_fav
			)
			
			<cfif ii NEQ iFansListLen>
			UNION
			</cfif>
			
		</cfloop>

	)
	
	<!--- include implicit favorites? --->
	<cfif isQuery( q_select_implicit_fav_artists ) AND q_select_implicit_fav_artists.recordcount GT 0>
		
		<cfloop query="q_select_implicit_fav_artists">
		UNION
			(
				SELECT
					<cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_implicit_fav_artists.mb_artistid#"> AS mbid,
					CURRENT_TIMESTAMP AS dt_created,
			0 AS explicit_fav
			)
		</cfloop>
	
	</cfif>
	
) AS data_ratings
LEFT JOIN
	mytunesbutler_mb.artist AS artist ON (artist.id = data_ratings.mbid)
WHERE
	mbid > 0
GROUP BY
	mbid
ORDER BY
	artist.name
</cfquery>