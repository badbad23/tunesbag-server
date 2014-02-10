<cfquery name="q_select_search_tracks" datasource="#application.udf.getMBds()#" cachedwithin="#CreateTimeSpan( 0, 5, 0, 0)#">
(SELECT
	id,
	100 as weight
FROM
	track
WHERE
	(name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#%">)
LIMIT
	50
)
UNION
(
SELECT
	trackcust.id,
	0 AS weight
FROM
	mytunesbutlercontent.trackcust
WHERE
	(trackcust.name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#%">)
LIMIT
	20
)
ORDER BY
	weight DESC
;
</cfquery>