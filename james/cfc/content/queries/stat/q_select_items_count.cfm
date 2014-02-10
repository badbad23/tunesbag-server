<!---

	select number of items

--->

<cfquery name="q_select_items_count" datasource="mytunesbutleruserdata">
SELECT
	COUNT(id) AS count_items
FROM
	
	<cfif arguments.type IS 'library'>
		mediaitems
	<cfelse>
		playlists
	</cfif>
	
WHERE
	userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
	
<cfif arguments.type IS 'playlists'>
	AND
	istemporary = 0
</cfif>
;
</cfquery>

<cfquery name="qSelectSize" datasource="mytunesbutleruserdata">
SELECT
	SUM( size ) AS size_total
FROM
	mediaitems
WHERE
	mediaitems.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userkey#">
;
</cfquery>