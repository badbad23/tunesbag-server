<cfquery name="q_select_cache_item_data" datasource="mytunesbutlerlogging" cachedwithin="#CreateTimeSpan(0,0,3,0)#">
SELECT
	infocache.data
FROM
	infocache
WHERE
	infocache.hashvalue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.hashvalue#">
;
</cfquery>