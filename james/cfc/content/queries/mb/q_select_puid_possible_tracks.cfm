<cfquery name="q_select_puid_possible_tracks" datasource="#application.udf.getMBds()#">
SELECT
	puid.id,
	puidjoin.track,
	track.name,
	track.artist
FROM
	puid
LEFT JOIN
	puidjoin ON (puidjoin.puid = puid.id)
LEFT JOIN
	track ON (track.id = puidjoin.track)
WHERE
	puid.puid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_source_puid#">
;
</cfquery>

<cfquery name="q_select_further_possible_tracks" datasource="#application.udf.getMBds()#">
SELECT
	track.name,
	track.artist,
	track.id,
	puid.puid
FROM
	track
LEFT JOIN
	puidjoin ON (puidjoin.track = track.id)
LEFT JOIN
	puid ON (puid.id = puidjoin.puid)
WHERE
	(1 = 0)
	<cfloop query="q_select_puid_possible_tracks">
		OR
			(
				(track.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_puid_possible_tracks.name#">)
			AND
				(track.artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#q_select_puid_possible_tracks.artist#">)
			)
	</cfloop>
;
</cfquery>