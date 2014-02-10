<cfquery name="q_select_search_plists_tracks" datasource="mytunesbutleruserdata">
SELECT
	playlist_items.playlistkey
FROM
	playlist_items
LEFT JOIN
	mediaitems ON (mediaitems.entrykey = playlist_items.mediaitemkey)
WHERE
	mediaitems.mb_trackid IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.track_ids#" list="true">)
LIMIT
	100
;
</cfquery>