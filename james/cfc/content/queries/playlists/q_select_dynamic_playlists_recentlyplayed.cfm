<!--- <cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.id
FROM
	mediaitems AS mediaitem
LEFT JOIN
	timesaccessed AS timesaccessed ON (timesaccessed.mediaitemkey = mediaitem.entrykey AND timesaccessed.userid = mediaitem.userid)
WHERE
	mediaitem.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
ORDER BY
	timesaccessed.lasttime DESC
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery> --->

<cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.id
FROM
	timesaccessed
LEFT JOIN
	mediaitems AS mediaitem ON (mediaitem.entrykey = timesaccessed.mediaitemkey)
WHERE
	timesaccessed.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
ORDER BY
	timesaccessed.lasttime DESC
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery>