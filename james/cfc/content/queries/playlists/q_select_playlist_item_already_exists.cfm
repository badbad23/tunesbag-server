<!---

	check if such an item already exists

--->

<cfquery name="q_select_playlist_item_already_exists" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_exists
FROM
	playlist_items
WHERE
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
	AND
	librarykey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykey#">
	AND
	mediaitemkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mediaitemkey#">
;
</cfquery>