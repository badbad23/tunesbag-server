<!---

	Select result from skreemr

--->

<cfquery name="q_select_skreemr_result" datasource="mytunesbutlerlogging">
SELECT
	entrykey,
	skreemr_id,
	artist,
	album,
	name,
	href,
	duration,
	year,
	host,
	filename,
	hashvalue,
	dt_created,
	frequency,
	bitrate
FROM
	skreemr_results
WHERE
	hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_str_item_hash#">
ORDER BY
	id DESC
;
</cfquery>
