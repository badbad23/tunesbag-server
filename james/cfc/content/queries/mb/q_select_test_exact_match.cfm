<cfquery name="q_select_test_exact_match" datasource="#application.udf.getMBds()#">
SELECT
	artist.id
FROM
	artist
WHERE
	artist.name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#a_search_string#">
;
</cfquery>