<!---

	delete old search results

--->

<cfquery name="q_delete_old_skreer_results" datasource="mytunesbutlerlogging">
DELETE FROM
	skreemr_results
WHERE
	hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_item_hash#">
;
</cfquery>