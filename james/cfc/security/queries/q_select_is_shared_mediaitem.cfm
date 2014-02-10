<cfquery name="q_select_is_shared_mediaitem" datasource="mytunesbutleruserdata">
SELECT
	COUNT(shareditems_autoplist.id) AS count_id
FROM
	shareditems
LEFT JOIN
	shareditems_autoplist ON (shareditems_autoplist.sharekey = shareditems.entrykey AND shareditems_autoplist.userkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.securitycontext.entrykey#">)
WHERE
	shareditems.identifier = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.entrykey#">
;
</cfquery>