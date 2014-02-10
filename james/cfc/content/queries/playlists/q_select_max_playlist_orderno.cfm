<!---

	set new max number

--->

<cfquery name="q_select_max_playlist_orderno" datasource="mytunesbutleruserdata">
SELECT
	MAX(orderno) AS max_orderno
FROM
	playlist_items
WHERE
	playlistkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.playlistkey#">
;
</cfquery>