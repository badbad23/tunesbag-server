<cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT
	mediaitem.id
FROM
	mediaitems AS mediaitem
WHERE
	mediaitem.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.securitycontext.userid#">
	AND
	mediaitem.dt_created > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd( 'd', -21, Now() )#">
ORDER BY
	mediaitem.dt_created DESC
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery>