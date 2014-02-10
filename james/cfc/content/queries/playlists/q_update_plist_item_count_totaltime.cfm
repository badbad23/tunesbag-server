<cfquery name="q_select_playlist_items_1" datasource="mytunesbutleruserdata">
SELECT
	playlist_items.mediaitemid
FROM
	playlist_items
WHERE
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>

<cfif q_select_playlist_items_1.recordcount IS 0>
	<cfexit method="exittemplate">
</cfif>

<cfquery name="q_select_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitems.id,
	mediaitems.totaltime
FROM
	mediaitems
/* join order */
LEFT JOIN
	playlist_items ON
		((playlist_items.mediaitemid = mediaitems.id) AND (playlist_items.playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">))
WHERE
	mediaitems.id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList( q_select_playlist_items_1.mediaitemid )#" list="true">)
/* order by given user order */
ORDER BY
	playlist_items.orderno
</cfquery>

<cfquery name="q_select_sum" dbtype="query">
SELECT
	SUM( totaltime ) AS sum_totaltime
FROM
	q_select_playlist_items
;
</cfquery>

<cfquery name="q_update_plist_item_count_totaltime" datasource="mytunesbutleruserdata">
UPDATE
	playlists
SET
	items = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( q_select_playlist_items.id )#">,
	itemscount = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_select_playlist_items.recordcount#">,
	ownitemscount = 0,
	totaltime = <cfqueryparam cfsqltype="cf_sql_integer" value="#Val( q_select_sum.sum_totaltime )#">,
	dt_lastmodified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
WHERE
	entrykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>