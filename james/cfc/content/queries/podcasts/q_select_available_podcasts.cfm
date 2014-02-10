<!---

	select ava podcasts
	
	own + public

--->

<cfquery name="q_select_available_podcasts" datasource="mytunesbutleruserdata">
SELECT
	podcasts.entrykey,
	podcasts.name,
	podcasts.description,
	podcasts.dt_created,
	podcasts.rssurl,
	podcasts.lang_id,
	podcasts.imglink,
	podcasts.category,
	podcasts.userkey,
	podcasts.librarykey,
	podcasts.dt_lastepisode
FROM
	podcasts
WHERE
	(userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
	OR
	(userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#GetPodCastUserUserkey()#">)
ORDER BY
	podcasts.name
;
</cfquery>