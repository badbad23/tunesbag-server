<cfquery name="q_select_lastkeys" datasource="mytunesbutleruserdata">
SELECT
	libraries.lastkey,
	libraries.entrykey AS librarykey
FROM
	libraries
WHERE
	libraries.entrykey IN (
	<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.librarykeys#" list="true">
	)
;
</cfquery>