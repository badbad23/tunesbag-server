<!--- 

	select shared items

 --->

<cfquery name="qCollect" datasource="mytunesbutleruserdata">
SELECT
	shareditems.identifier,
	shareditems.dt_created
FROM
	shareditems_autoplist
LEFT JOIN
	shareditems ON (shareditems.entrykey = shareditems_autoplist.sharekey)
WHERE
	(shareditems_autoplist.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
	AND
	(shareditems.itemtype = 1)
	AND
	<!--- not older than 90 days --->
	(shareditems.dt_created > Date_SUB(Now(), INTERVAL 90 DAY))
LIMIT
	#Val( arguments.maxrows )#
;
</cfquery>

<cfquery name="q_select_dynamic_playlist_items" datasource="mytunesbutleruserdata">
SELECT * FROM
	(
SELECT
	mediaitems.id,
	shareditems.dt_created
FROM
	mediaitems
LEFT JOIN
	shareditems ON (shareditems.identifier = mediaitems.entrykey)
WHERE
	mediaitems.entrykey IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ValueList( qCollect.identifier )#" list="true">)
	) AS t1
ORDER BY t1.dt_created
	 DESC
;
</cfquery>