<!---

	Keywords
	
	TODO: Optimize SQL
	
	a) collect keys
	b) select
	c) order

--->

<cfquery name="q_select_simple_plist_items_collect" datasource="mytunesbutleruserdata">
SELECT
	playlist_items.mediaitemkey,
	playlist_items.orderno
FROM
	playlist_items
WHERE
	playlist_items.playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
;
</cfquery>


<cfquery name="q_select_simple_plist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.entrykey,
	mediaitems.mb_artistid,
	mediaitems.mb_trackid,
	mediaitems.mb_albumid,
	mediaitems.totaltime,
	playlist_items.orderno,
	
<cfif arguments.bReplaceTrackinfoWithMBInfo>
	/* use musicbrainz information */
	
	mb_artist.name AS artist,
	mb_track.name AS name,
	mb_album.name AS album,
	
<cfelse>

	mediaitems.artist,
	mediaitems.name,
	mediaitems.album,

</cfif>

	'' AS dummy

FROM
	mediaitems
LEFT JOIN
	playlist_items ON ((playlist_items.mediaitemkey = mediaitems.entrykey) AND (playlist_items.playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">))
LEFT JOIN
	mytunesbutler_mb.artist AS mb_artist ON (mb_artist.id = mediaitems.mb_artistid)
LEFT JOIN
	mytunesbutler_mb.track AS mb_track ON (mb_track.id = mediaitems.mb_trackid)
LEFT JOIN
	mytunesbutler_mb.album AS mb_album ON (mb_album.id = mediaitems.mb_albumid)	
WHERE
	mediaitems.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="dummy,#ValueList( q_select_simple_plist_items_collect.mediaitemkey)#" list="true">)
	
<!--- 

	ignore tracks which have no valid musicbrainz ID

 --->
<cfif arguments.bIgnoreUnIdentifiedTracks>
	AND
	(mediaitems.mb_trackid > 0)
	AND
	(mediaitems.mb_trackid < 100000000)
</cfif>	
;
</cfquery>

<!--- do a QoQ --->
<cfquery name="q_select_simple_plist_items" dbtype="query">
SELECT
	*
FROM
	q_select_simple_plist_items
ORDER BY
	orderno DESC
;
</cfquery>