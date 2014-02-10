<!--- select items from *all* users --->
<cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.id
FROM
	ratings AS rating
LEFT JOIN
	mediaitems AS mediaitem ON (mediaitem.id = rating.mediaitem_id)
WHERE
	rating.userid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.userid#">
	AND
	rating.rating > 20
	AND NOT
	ISNULL(mediaitem.id)
ORDER BY
	rating.rating DESC,
	rating.dt_created
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery>