<!--- TODO CHECK ARTIST --->
<cfquery name="q_select_recent_listeners" datasource="mytunesbutlerlogging">
SELECT
	DISTINCT( users.username ),
	playeditems.mb_artistid,
	playeditems.mb_trackid,
	playeditems.dt_created,
	trackinfo.name AS track_name,
	album.name AS album_name,
	album.id AS mb_albumid
FROM
	playeditems
LEFT JOIN
	mytunesbutleruserdata.users AS users ON (users.entrykey = playeditems.userkey)
LEFT JOIN
	mytunesbutler_mb.track AS trackinfo ON (trackinfo.id = playeditems.mb_trackid)
LEFT JOIN
	mytunesbutler_mb.albumjoin AS albumjoin ON (albumjoin.track = playeditems.mb_trackid)
LEFT JOIN
	mytunesbutler_mb.album AS album ON (album.id = albumjoin.album)
WHERE
	playeditems.dt_created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -arguments.maxagedays, Now() )#">
	AND
	(LENGTH( username ) > 0)
	
	<cfif arguments.artistid GT 0>
		AND
		(playeditems.mb_artistid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artistid#">)
		
		<cfset a_bol_hit = true />
	</cfif>
	
	<cfif Len( arguments.userkeys ) GT 0>
		AND
		(playeditems.userkey IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userkeys#" list="true">)
		
		<cfset a_bol_hit = true />
	</cfif>	
	
	<cfif arguments.albumid GT 0>
		AND
		(playeditems.mb_albumid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.albumid#">)
		
		<cfset a_bol_hit = true />		
	</cfif>	
	
	<cfif arguments.trackid GT 0>
		AND
		(playeditems.mb_trackid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.trackid#">)
		
		<cfset a_bol_hit = true />		
	</cfif>		
	
	<!--- no hit, don't return any items --->
	<cfif NOT a_bol_hit>
		AND
		(1 = 0)
	</cfif>

GROUP BY
	username
ORDER BY
	playeditems.dt_created DESC
LIMIT
	100
;	
</cfquery>