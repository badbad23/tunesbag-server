<cfquery name="q_select_search_plists_artists" datasource="mytunesbutleruserdata">
SELECT
	playlist_items.playlistkey,
	mediaitems.mb_artistid
FROM
	playlist_items
LEFT JOIN
	mediaitems ON (mediaitems.entrykey = playlist_items.mediaitemkey)
WHERE
	mediaitems.mb_artistid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.artist_ids#" list="true">)
LIMIT
	100
;
</cfquery>