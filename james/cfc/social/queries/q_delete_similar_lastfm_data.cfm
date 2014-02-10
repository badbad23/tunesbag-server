<!---

	delete similar last.fm data

--->

<cfquery name="q_delete_similar_lastfm_data" datasource="mytunesbutlercontent">
DELETE FROM
	lastfm_similar_artists
WHERE
	artist = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.artist#">
;
</cfquery>